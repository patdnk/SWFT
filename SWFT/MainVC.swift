//
//  ViewController.swift
//  SWFT
//
//  Created by Dynek, Patryk on 29/06/2017.
//  Copyright © 2017 Qualcomm Technology Limited Ltd. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource, BluetoothManagerDelegate {

    @IBOutlet weak var scanButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    let databaseManager = DatabaseManager.sharedInstance
    let bluetoothManager = BluetoothManager.sharedInstance
    let bluetoothManagerMulticast = BluetoothManagerDelegateMulticast<BluetoothManagerDelegate>()
    var peripherals = [CBPeripheral]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.bluetoothManagerMulticast.addDelegate(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        self.title = "BLE devices"
        
//        let deadline = DispatchTime.now() + 1
//        
//        DispatchQueue.main.asyncAfter(deadline: deadline) { 
//            self.bluetoothManager.startScanning(serviceUUIDs: nil)
//        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UITableViewDataDelegate methods
    
    // number of rows in table view
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripherals.count
    }
    
    // create a cell for each table view row
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let newDeviceCellIdentifier = "newDeviceCellIdentifier"
        
        let cell:NewDeviceCell = self.tableView.dequeueReusableCell(withIdentifier: newDeviceCellIdentifier) as! NewDeviceCell
        
        cell.deviceNameLabel.text = ""
        cell.deviceUUIDLabel.text = ""
        
        return cell
    }
    
    // method to run when table view cell is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You tapped cell number \(indexPath.row).")
    }
    
    // MARK: - UITableViewDataSource methods
    
    // MARK: - BluetoothManagerDelegate methods
    
    func didDiscoverPeripherals(peripheral:CBPeripheral, advertisementData:[String : AnyObject], RSSI:NSNumber) {
        
        self.peripherals.append(peripheral)
        
    }
    
    func didConnectPeripheral(peripheral: CBPeripheral) {
        
    }
    
    func didDiconnectPeripheral(peripheral:CBPeripheral) {
        
    }
    
    @available(iOS 10.0, *)
    func centralManagerDidUpdateState(state:CBManagerState) {
        
    }
    
    func didDiscoverServices(peripheral:CBPeripheral, services:[CBService]) {
        
    }
    
    func didDiscoverCharacteristics(peripheral:CBPeripheral, service:CBService, characteristics:[CBCharacteristic]) {
        
    }
    
    func didUpdateCharacteristicValue(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error: Error) {
        
    }
    
    func didWriteCharacteristicValue(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error:Error) {
        
    }
    
    func didDiscoverDescriptors(peripheral:CBPeripheral, service:CBService, characteristic:CBCharacteristic, error:Error) {
        
    }
    
    // MARK: - Scan for peripherals
    
    func scanForPeripherals() -> Bool {
        
        
        guard self.bluetoothManager.centralManager?.state == .poweredOn else {
            return false
        }
        
        DispatchQueue.main.async {
            
            self.bluetoothManager.startScanning(serviceUUIDs: nil)
            
        }
        
        return true
        
    }
    
    // MARK: - CoreData testing methods
    
    
    func testCoreDataReading() {
        
        let configFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SWFTConfig")
        
        var mainEntity:SWFTConfig?
        
        do {
            let fetchedConfigs = try DatabaseManager.sharedInstance.persistentContainer.viewContext.fetch(configFetch) as! [SWFTConfig]
            
            if fetchedConfigs.count > 0 {
                
                mainEntity = fetchedConfigs.first
                
            }
            
            
            
        } catch {
            
            fatalError("Failed to fetch employees: \(error)")
        }
        
        print(mainEntity?.versionMajor ?? 0, mainEntity?.versionMinor ?? 0, mainEntity?.versionBuild ?? 0)
        
    }
    
    func testCoreDataWriting() {
        
        var mainEntity:SWFTConfig?
        
        let configFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "SWFTConfig")
        
        do {
            let fetchedConfigs = try DatabaseManager.sharedInstance.persistentContainer.viewContext.fetch(configFetch) as! [SWFTConfig]
            
            if fetchedConfigs.count > 0 {
                
                mainEntity = fetchedConfigs.first
                
            }
            
        } catch {
            
            fatalError("Failed to fetch employees: \(error)")
        }
        
        if mainEntity == nil {
            
            mainEntity = NSEntityDescription .insertNewObject(forEntityName: "SWFTConfig", into: DatabaseManager.sharedInstance.persistentContainer.viewContext) as? SWFTConfig
            
        }
        
        mainEntity?.versionMajor = 1
        mainEntity?.versionMinor = 1
        mainEntity?.versionBuild = 20
        
        databaseManager.saveContext()
        
    }
    
    @IBAction func toggleScanning() {
        
        if self.bluetoothManager.isScanning {
        
            self.scanButton.title = "Start scanning"
            self.bluetoothManager.stopScanning()
            
        } else {
            
            self.scanButton.title = "Stop scanning"
            self.peripherals = []
            self.bluetoothManager.startScanning(serviceUUIDs: nil)
            
            
        }
        
    }


}

