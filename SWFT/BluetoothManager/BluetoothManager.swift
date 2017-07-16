//
//  BluetoothManager.swift
//  SWFT
//
//  Created by Dynek, Patryk on 29/06/2017.
//  Copyright © 2017 Qualcomm Technology Limited Ltd. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothManagerDelegateMulticast <T> {
    
    private var delegates = [WeakWrapper]()
    
    func addDelegate(_ delegate: T) {
        if Mirror(reflecting: delegate).subjectType is AnyClass {
            delegates.append(WeakWrapper(value: delegate as AnyObject))
        } else {
            fatalError("MulticastDelegate does not support value types")
        }
    }
    
    func removeDelegate(_ delegate: T) {
        if type(of: delegate).self is AnyClass {
            delegates.remove(WeakWrapper(value: delegate as AnyObject))
        }
    }

    
    func invokeDelegate(_ invocation: (T) -> ()) {
        for (index, delegate) in delegates.enumerated() {
            if let delegate = delegate.value {
                invocation(delegate as! T)
            } else {
                delegates.remove(at: index)
            }
        }
    }
    
}

private class WeakWrapper: Equatable {
    weak var value: AnyObject?
    
    init(value: AnyObject) {
        self.value = value
    }
}

private func ==(lhs: WeakWrapper, rhs: WeakWrapper) -> Bool {
    return lhs.value === rhs.value
}

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    @discardableResult
    mutating func remove(_ element : Iterator.Element) -> Iterator.Element? {
        if let index = self.index(of: element) {
            return self.remove(at: index)
        }
        return nil
    }
}

protocol BluetoothManagerDelegate: class {
    
    func didDiscoverPeripherals(peripheral:CBPeripheral, advertisementData:[String : AnyObject], RSSI:NSNumber)
    func didConnectPeripheral(peripheral:CBPeripheral)
    func didDiconnectPeripheral(peripheral:CBPeripheral)
    func didDiscoverServices(peripheral:CBPeripheral, services:[CBService])
    func didDiscoverCharacteristics(peripheral:CBPeripheral, service:CBService, characteristics:[CBCharacteristic])
    func didUpdateCharacteristicValue(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error: Error)
    func didWriteCharacteristicValue(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error:Error)
    func didDiscoverDescriptors(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error:Error)
    
    @available(iOS 10.0, *)
    func centralManagerDidUpdateState(state:CBManagerState)
    
}

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var delegates = BluetoothManagerDelegateMulticast<BluetoothManagerDelegate>()
    
    var centralManager: CBCentralManager!
    var connectedPeripherals = NSMutableArray()
    var isScanning:Bool = false
    
    static let sharedInstance = BluetoothManager()
    
    override init() {
        super.init()
        powerOnCentralManager()
    }
    
    func powerOnCentralManager() {
        powerOffCentralManager()
        self.centralManager = CBCentralManager.init(delegate: self, queue: nil, options:nil)
    }
    
    func powerOffCentralManager() {
        if self.centralManager != nil {
            self.centralManager = nil
        }
    }
    
    func startScanning(serviceUUIDs: [CBUUID]?) {
        
        if (self.centralManager.state == .poweredOn) {
            print("start scanning")
            self.centralManager.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            self.isScanning = true
            
        }
        
    }
    
    func stopScanning() {
        if (self.centralManager.state == .poweredOn) {
            print("stop scanning")
            self.centralManager.stopScan()
            self.isScanning = false
        }
    }
    
    // MARK: - CoreBluetooth methods
    
    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        delegates.invokeDelegate {
            $0.didDiscoverPeripherals(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
        
    }
    
    internal func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        delegates.invokeDelegate {
            $0.didConnectPeripheral(peripheral: peripheral)
        }
        
    }
    
    internal func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        delegates.invokeDelegate {
            $0.didDiconnectPeripheral(peripheral: peripheral)
        }
        
    }
    
    // MARK: - CBPeripheral delegate methods
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    internal func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    //    func didDiscoverPeripherals()
    //    func connectPeripheral(peripheral:CBPeripheral)
    //    func diconnectPeripheral(peripheral:CBPeripheral)
    
    internal func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch centralManager.state {
            
        case .poweredOn:
            print("CBCentral powered ON")
            
        case .poweredOff:
            print("CBCentral powered OFF")
            
        case .resetting:
            print("CBCentral resetting")
            
        case .unknown:
            print("Unknown")
            
        case .unsupported:
            print("Unsupported")
            
        default:
            break
            
        }
        
    }
    
}
