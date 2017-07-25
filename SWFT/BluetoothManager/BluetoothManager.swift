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
    
    fileprivate let delegates: NSHashTable<AnyObject>
    
    init(strongReferences: Bool = false) {
        self.delegates = strongReferences ? NSHashTable<AnyObject>(): NSHashTable<AnyObject>.weakObjects()
    }
    
    func addDelegate(_ delegate: T) {
        self.delegates.add(delegate as AnyObject)
    }
    
    func removeDelegate(_ delegate: T) {
        self.delegates.remove(delegate as AnyObject)
    }

    
    func invokeDelegates(_ invocation: (T) -> ()) {
        for delegate in self.delegates.allObjects {
            invocation(delegate as! T)
        }
    }
    
}

protocol BluetoothManagerDelegate: class {
    
    func didDiscoverPeripherals(peripheral:CBPeripheral, advertisementData:[String : Any], RSSI:NSNumber)
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
    
    var delegateArray = BluetoothManagerDelegateMulticast<BluetoothManagerDelegate>()
    
    var centralManager: CBCentralManager?
    var connectedPeripherals = NSMutableArray()
    var isScanning:Bool = false
    
    static let sharedInstance = BluetoothManager()
    
    override init() {
        super.init()
        powerOnCentralManager()
    }
    
    func addDelegate(_ delegate: AnyObject) {
        self.delegateArray.addDelegate(delegate as! BluetoothManagerDelegate)
    }
    
    func removeDelegate(_ delegate: AnyObject) {
        self.delegateArray.removeDelegate(delegate as! BluetoothManagerDelegate)
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
        
        if (self.centralManager?.state == .poweredOn) {
            print("start scanning")
            self.centralManager?.scanForPeripherals(withServices: serviceUUIDs, options: [CBCentralManagerScanOptionAllowDuplicatesKey : true])
            self.isScanning = true
            
        }
        
    }
    
    func stopScanning() {
        if (self.centralManager?.state == .poweredOn) {
            print("stop scanning")
            self.centralManager?.stopScan()
            self.isScanning = false
        }
    }
    
    // MARK: - CoreBluetooth methods
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        self.delegateArray.invokeDelegates {
            $0.didDiscoverPeripherals(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
        }
        
    }
    
//    private func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
//        
//        delegates.invokeDelegate {
//            $0.didDiscoverPeripherals(peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI)
//        }
//        
//    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
       self.delegateArray.invokeDelegates {
            $0.didConnectPeripheral(peripheral: peripheral)
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        self.delegateArray.invokeDelegates {
            $0.didDiconnectPeripheral(peripheral: peripheral)
        }
        
    }
    
    // MARK: - CBPeripheral delegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        
    }
    
    
    //    func didDiscoverPeripherals()
    //    func connectPeripheral(peripheral:CBPeripheral)
    //    func diconnectPeripheral(peripheral:CBPeripheral)
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        if (self.centralManager != nil) {
            
            switch centralManager!.state {
                
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
    
}
