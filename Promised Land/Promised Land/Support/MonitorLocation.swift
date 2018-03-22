//
//  MonitorLocation.swift
//  Promised Land
//
//  Created by Dai Pham on 3/20/18.
//  Copyright © 2018 Dai Pham. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

let CURRENT_REGION = "CURRENT_REGION"

class MonitorLocation: NSObject {
    
    // MARK: - api
    func startMonitoring() {
        isEnteringRegion = false
        // 1
        if !CLLocationManager.isMonitoringAvailable(for: CLCircularRegion.self) {
            print("Geofencing is not supported on this device!")
            return
        }
        // 2
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            print("Your geotification is saved but will only be activated once you grant Geotify permission to access the device location.")
        }
        // 3
        if let region = clCircularRegions.first {
        // 4
            print("START GEOFENCE")
            locationManager.startMonitoring(for: region)
        } else {
            print("No Region have not registed yet")
        }
    }
    
    func stopMonitoring() {
        for region in locationManager.monitoredRegions {
            guard let circularRegion = region as? CLCircularRegion, circularRegion.isEqual(currentCircularRegionTracking) else { continue }
            locationManager.stopMonitoring(for: circularRegion)
            print("STOP TRACKING")
        }
    }
    
    func getPlaceMark(from coordinate:CLLocationCoordinate2D, completion:((CLPlacemark?)->Void)? = nil) {
        let ceo = CLGeocoder()
        let loc = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        ceo.reverseGeocodeLocation(loc) {(placemarks, err) in
            if let placeMark = placemarks?.first {
                completion?(placeMark)
            } else {
                completion?(nil)
            }
        }
    }
    
    // MARK: - action
    func handleEvent(forRegion region: CLRegion!) {
        print("Geofence triggered!")
    }
    
    // MARK: - init
    private override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestLocation()
    }
    
    // MARK: - closures
    var onCurrentLocation:((CLLocation)->Void)?
    var onDidEnterRegion:(()->Void)?
    var onDidExitRegion:(()->Void)?
    var isEnteringRegion:Bool = false
    
    // MARK: - properties
    var clCircularRegions = [CLCircularRegion]()
    var currentCircularRegionTracking:CLCircularRegion?
    static let shared = MonitorLocation()
    let locationManager = CLLocationManager()
}

// MARK: -
extension MonitorLocation:CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            locationManager.requestLocation()
        } else {
            print("cant request location. Please check permission and make sure authorized Always.")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Error ranging geofencing: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Error geofencing: \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        do {
            currentCircularRegionTracking = region as? CLCircularRegion
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let local = locations.first {
            self.onCurrentLocation?(local)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard currentCircularRegionTracking != nil else { return }
        if region is CLCircularRegion && region.identifier == CURRENT_REGION {
            isEnteringRegion = true
            self.onDidEnterRegion?()
            print("enter region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard currentCircularRegionTracking != nil else { return }
        if region is CLCircularRegion && region.identifier == CURRENT_REGION {
            isEnteringRegion = false
            self.onDidExitRegion?()
            print("exit region")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error:: \(error)")
    }
}
