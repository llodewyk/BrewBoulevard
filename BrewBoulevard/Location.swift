//
//  Location.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/3/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import Foundation
import CoreLocation

class Location: NSObject {
    
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees
    var locationManager = CLLocationManager()
    
    override init() {
        self.latitude = 0.0
        self.longitude = 0.0
        super.init()
        //println("get current!")
    }
    
    func getCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
        //println("here1")
        if CLLocationManager.locationServicesEnabled() {
            //println("here2")
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        
        //NOTE: ASK TA ABOUT THIS SOMETIME
        //while (locationManager.didUpdateLocations: == false){
        //    sleep(1)
        //}
        
        if let currLocation = locationManager.location {
            //println("here3")
            //println("Location: \(locationManager.location)")
            self.latitude = currLocation.coordinate.latitude
            self.longitude = currLocation.coordinate.longitude
        }
        else{
            //println("here4")
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        self.latitude = aDecoder.decodeDoubleForKey("Latitude") as CLLocationDegrees
        self.longitude = aDecoder.decodeDoubleForKey("Longitude") as CLLocationDegrees
        super.init()
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeDouble(self.latitude, forKey: "Latitude")
        aCoder.encodeDouble(self.longitude, forKey: "Longitude")
    }
    
    func locationManager(manager:CLLocationManager!, didUpdateLocations: [AnyObject!]){
        CLGeocoder().reverseGeocodeLocation(manager.location, completionHandler: { (placemarks, error) -> Void in
            if (error != nil){
                println("Error" + error.localizedDescription)
                return
            }
            
            if placemarks.count > 0{
                let pm = placemarks[0] as! CLPlacemark
                //self.displayLocationInfo(pm)
            }
            })
    }
    
}

