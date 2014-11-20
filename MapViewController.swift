//
//  MapViewController.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 04/11/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {
    
    
    @IBOutlet weak var mapView: MKMapView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let request: NSFetchRequest = NSFetchRequest(entityName: "FeedItem")
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        let context = appDelegate.managedObjectContext!
        
        var error: NSError? = nil
        
        
        let itemArray = context.executeFetchRequest(request, error: &error)
        
        if error != nil {
            println(error)
            
        }
        
        if itemArray!.count > 0 {
            
            
            for item in itemArray! {
                
                let location = CLLocationCoordinate2DMake(Double(item.latitude), Double(item.longitude))
                
                let span = MKCoordinateSpanMake(0.05, 0.05)
                
                let region = MKCoordinateRegionMake(location, span)
                
                self.mapView.setRegion(region, animated: true)
                
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(location)
                annotation.title = item.caption
                
                self.mapView.addAnnotation(annotation)
                
                
            }
        }
        
        // static example : how to use Core Location and mapkit
        
//        let location = CLLocationCoordinate2D(latitude: 48.868639224587, longitude: 2.37119161036255)
//        
//        // these lines of code determine how large the map displayed will be (zoom)
//        let span = MKCoordinateSpanMake(0.05, 0.05)
//        let region = MKCoordinateRegionMake(location, span)
//        self.mapView.setRegion(region, animated: true)
//        
//        let annotation = MKPointAnnotation()
//        annotation.setCoordinate(location)
//        annotation.title = "Canal Saint-Martin"
//        annotation.subtitle = "Paris"
//        
//        self.mapView.addAnnotation(annotation)
//        
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    



}
