//
//  IBeaconManager.swift
//  Coronavirus Herd Immunity
//
//  Created by Antonio Romano on 01/03/2020.
//  Copyright © 2020 Coronavirus-Herd-Immunity. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth

// https://developer.apple.com/documentation/corelocation/turning_an_ios_device_into_an_ibeacon_device
// https://www.hackingwithswift.com/example-code/location/how-to-detect-ibeacons
// https://www.raywenderlich.com/632-ibeacon-tutorial-with-ios-and-swift

// https://stackoverflow.com/questions/39977251/a-simple-code-to-detect-any-beacon-in-swift/46448986

class IBeaconManager: NSObject {
    
    // ************************
    // MARK: Variables and Instances
    // ************************

    var peripheralActiveManager : CBPeripheralManager? //bluetooth
    var peripheralInactiveManager : CBPeripheralManager? //bluetooth
    var locationManager: CLLocationManager //location

    // ************************
    // MARK: INIT / SHARED
    // ************************
    
    static let shared = IBeaconManager()

    private override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        self.peripheralActiveManager = CBPeripheralManager(delegate: self, queue: nil)
        self.peripheralInactiveManager = CBPeripheralManager(delegate: self, queue: nil)
//        self.locationManager.requestAlwaysAuthorization() //TODO: should be removed?
    }

    // ************************
    // MARK: Advertising
    // ************************
    
    
    func startAdvertiseDevice() {
        print("[IBeaconManager] asked to advertise")
        
        guard   let activeRegion = createBeaconRegion(beaconType: .active),
                let inactiveRegion = createBeaconRegion(beaconType: .inactive),
                let activeManager = peripheralActiveManager,
                let inactiveManager = peripheralInactiveManager else { return }
        
        let _ = Timer.scheduledTimer(withTimeInterval: 2, repeats: true) {
            timer in

            self.advertiseDevice(peripheralManager: activeManager,
                                 region: activeRegion)

            if let second = Date().second, second < 10 {
                self.advertiseDevice(peripheralManager: inactiveManager,
                                     region: inactiveRegion)
            }
        }
    }
    
    private func advertiseDevice(peripheralManager : CBPeripheralManager, region: CLBeaconRegion) {

        print("[IBeaconManager] gonna advertise")
        
        if peripheralManager.state != .poweredOn {
            print("[IBeaconManager] should not advertise")
            return
        }
        
        if peripheralManager.isAdvertising {
            print("[IBeaconManager] device is already advertising")
            return
        }

        let peripheralData = region.peripheralData(withMeasuredPower: nil)
        peripheralManager.startAdvertising(((peripheralData as NSDictionary) as! [String : Any]))
        
        
        if #available(iOS 13.0, *) {
            #if DEBUG
            NotificationManager.shared.showLocalNotification("START advertising!", subtitle: "", message: "")
            print("[IBeaconManager] START advertise \(Date()) \(region.uuid), \(String(describing: peripheralManager))")
            #endif
        }
        
        let queue = DispatchQueue.global()
        queue.asyncAfter(deadline: .now()+1) {
            peripheralManager.stopAdvertising()
            print("[IBeaconManager] stop advertise. \(Date()) \(String(describing: peripheralManager))")
        }
    }
    
    func registerListener() {
        if !BluetoothManager.shared.isBluetoothUsable() {
            print("[IBeaconManager] bluetooth not usable!")
            return
        }
        print("[IBeaconManager] registering region for iBeacon")
        
        for type in [BeaconType.active, BeaconType.inactive] {
            let region = regionToMonitor(beaconType: type)

            //stop
            locationManager.stopMonitoring(for: region)
            locationManager.stopRangingBeacons(in: region)
            
            //start
            locationManager.startMonitoring(for: region)
            locationManager.startRangingBeacons(in: region)
        }
        

    }
    
    // ************************
    // MARK: ibeacon
    // ************************
    
    enum BeaconType {
           case active
           case inactive //maybe choose a better name?
        
        var uuid: UUID {
            switch self {
            case .active:
                return UUID(uuidString: Constants.Setup.uuidCHIdeviceActive)!
            case .inactive:
                return UUID(uuidString: Constants.Setup.uuidCHIdeviceInactive)!
            }
        }
        
        var identifier: String {
            switch self {
            case .active:
                return Constants.Setup.beaconCHIidentifierActive
            case .inactive:
                return Constants.Setup.beaconCHIidentifierInactive
            }
        }
        
        func major(from deviceIdentifier: Int) -> CLBeaconMajorValue {
            switch self {
            case .active:
                return CLBeaconMajorValue(Utils.getMajorFromInt(deviceIdentifier))
            case .inactive:
                  return CLBeaconMajorValue(Utils.getMajorFromInt(0))
            }
        }
        
        func minor(from deviceIdentifier: Int) -> CLBeaconMinorValue {
            switch self {
            case .active:
                return CLBeaconMajorValue(Utils.getMinorFromInt(deviceIdentifier))
            case .inactive:
                  return CLBeaconMajorValue(Utils.getMinorFromInt(0))
            }
        }
    }
    
    private func createBeaconRegion(beaconType: BeaconType) -> CLBeaconRegion? {
        
        guard let idDevice = StorageManager.shared.getIdentifierDevice() else { return nil }
        
        return CLBeaconRegion(proximityUUID: beaconType.uuid,
                              major: beaconType.major(from: idDevice),
                              minor: beaconType.minor(from: idDevice),
                              identifier: beaconType.identifier)
    }
    
    private func regionToMonitor(beaconType: BeaconType) -> CLBeaconRegion {
        return CLBeaconRegion(proximityUUID: beaconType.uuid,
                              identifier: beaconType.identifier)
    }
}

// ************************
// MARK: BLUETOOTH BASED
// ************************

extension IBeaconManager: CBPeripheralManagerDelegate {

    // ************************
    // MARK: CBPeripheralManagerDelegate
    // ************************

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("[IBeaconManager] did update status", peripheral.state)
        switch peripheral.state {
        case .poweredOff:
            print("[IBeaconManager] off")
            break
        case .poweredOn:
            print("[IBeaconManager] on")
            startAdvertiseDevice()
            break
        case .resetting:
            print("[IBeaconManager] resetting")
            break
        case .unauthorized:
            print("[IBeaconManager] unauth")
            break
        case .unknown:
            print("[IBeaconManager] unknown")
            break
        case .unsupported:
            print("[IBeaconManager] unsupported")
            break
        }
    }
}


// ************************
// MARK: CORE LOCATION BASED
// ************************

extension IBeaconManager: CLLocationManagerDelegate {

    // **************************************
    // MARK: CLLocationManagerDelegate
    // **************************************
        
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        print("[IBeaconManager] did enter region")
        self.registerListener()
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        print("[IBeaconManager] did exit region")
        self.registerListener()
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
      print("[IBeaconManager] Failed monitoring region: \(error.localizedDescription)")
    }
      
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print("[IBeaconManager] IBeacon manager failed: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0{
            print("[IBeaconManager] FOUND iBEACON!", beacons.count)
        }
        for beacon in beacons {
            print("[IBeaconManager] BEACON", beacon.proximityUUID, beacon.accuracy, beacon.major, beacon.minor, beacon.accuracy, beacon.rssi)
            switch beacon.proximity {
            case .far:
                print("[IBeaconManager] far")
                break
            case .immediate:
                print("[IBeaconManager] immediate")
                break
            case .near:
                print("[IBeaconManager] near")
                break
            case .unknown:
                print("[IBeaconManager] unknown")
                break
            }
            if  [CLProximity.immediate, CLProximity.near, CLProximity.far].contains(beacon.proximity) &&
                beacon.proximityUUID == BeaconType.active.uuid {
                //TODO: good ibeacon :D
                #if DEBUG
                print("[IBeaconManager] FOUND ibeacon \(beacon.major)")
                    NotificationManager.shared.showLocalNotification("New active Ibeacon!", subtitle: "Proximity: \(beacon.proximity.rawValue)", message: "UUID: \(beacon.major)")
                #endif

                CoreManager.addIBeacon(beacon)
            } else {
                #if DEBUG
                    print("[IBeaconManager] ignored ibeacon \(beacon.major)")
                    NotificationManager.shared.showLocalNotification("Ibeacon found!", subtitle: "Proximity: \(beacon.proximity.rawValue)", message: "UUID: \(beacon.major)")
                #endif
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
                if CLLocationManager.isRangingAvailable() {
                    print("[IBeaconManager] always authorized, starting region monitoring")
                    registerListener()
                }
            }
        }
    }
    
}
