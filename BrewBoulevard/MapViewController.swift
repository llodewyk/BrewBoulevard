//
//  MapViewController.swift
//  BrewBoulevard
//
//  Created by Laura Lodewyk on 12/3/15.
//  Copyright (c) 2015 Laura Lodewyk. All rights reserved.
//

import UIKit
import MapKit


class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let location = Location()
    var search: Search?


    override func viewDidLoad() {
        super.viewDidLoad()
        var initialLocation = CLLocation(latitude: 0.0, longitude: 0.0)
        if let searched = search {
            let first = search!.resultArray[0]
            initialLocation = CLLocation(latitude: first.latitude, longitude: first.longitude)
        }
        else{
            location.getCurrentLocation()
            initialLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            dropPin.title = "You Are Here"
            mapView.addAnnotation(dropPin)
        }
        centerMapOnLocation(initialLocation)
        if let searched = search {
            dropBrewPins()
        }

    }
    
    let regionRadius: CLLocationDistance = 4000
    
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dropBrewPins(){
        for result in search!.resultArray{
            let dropPin = MKPointAnnotation()
            dropPin.coordinate = CLLocationCoordinate2D(latitude: result.latitude, longitude: result.longitude)
            dropPin.title = result.name
            dropPin.subtitle = result.address
            mapView.addAnnotation(dropPin)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTable"{
                let showTable:SearchViewController = segue.destinationViewController as! SearchViewController
            if var test = self.search{
                showTable.search = self.search!
            }
            
        }
    }

}
