//
//  BluetoothManager.swift
//  OspreyOptics
//
//  Created by Andreas Ink on 4/19/24.
//

import CoreBluetooth

class BluetoothManager: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var discoveredPeripheral: CBPeripheral?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            // Start scanning for devices
            centralManager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
        // Check for peripherals that advertise the required service
        guard let serviceUUIDs = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] else { return }
        if serviceUUIDs.contains(serviceUUID) {
            // Save the discovered peripheral
            discoveredPeripheral = peripheral
            // Stop scanning
            centralManager.stopScan()
            // Connect to the peripheral
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // Set the peripheral delegate and discover services
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
    }
        
    let serviceUUID = CBUUID(string: "6C718F42-6085-4FF1-8D50-EF568C3ACA59")
    let characteristicUUID = CBUUID(string: "5ACBBBBD-C46A-4493-A426-5E609BA8B0C5")
        
    func writeValue(toCharacteristic characteristic: CBCharacteristic, value: Data) {
        discoveredPeripheral?.writeValue(value, for: characteristic, type: .withResponse)
    }
}
