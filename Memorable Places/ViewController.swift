//
//  ViewController.swift
//  Memorable Places
//
//  Created by IMCS2 on 8/10/19.
//  Copyright © 2019 patelashish797. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
import MapKit
var storingPlace: [String] = []
var storingLat: [String] = []
var storingLong: [String] = []
class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    var savedLat: String = ""
    var savedLong: String = ""
    var savedPlaces: String = ""
    var savLatLongCore = [NSManagedObject]()
    var locationManager = CLLocationManager()
    @IBOutlet weak var map: MKMapView!
    @IBAction func listTapped(_ sender: Any) {
        fetchcoreData()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        map.delegate = self
        let uiLongPress = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressAction(gustureRecognizer:)))
        uiLongPress.minimumPressDuration = 0.5
        map.addGestureRecognizer(uiLongPress)
        fetchcoreData()
    }
    @objc func longPressAction(gustureRecognizer: UIGestureRecognizer) {
        let touchPoint = gustureRecognizer.location(in: self.map)
        let coordinates = map.convert(touchPoint, toCoordinateFrom: self.map)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates
        map.addAnnotation(annotation)
        let alert = UIAlertController(title: "Enter Name of Place", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = " "
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            let addedPlace = (textField!.text)!
            annotation.title = addedPlace
            storingPlace.append(addedPlace)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let latVarStr: String = String(format: "%0.02f", Float((view.annotation?.coordinate.latitude)!))
        storingLat.append(latVarStr)
        let lonVarStr: String = String(format: "%0.02f", Float((view.annotation?.coordinate.longitude)!))
        storingLong.append(lonVarStr)
        self.save(savinPlace:storingPlace,savingLatitude:storingLat,savingLongitude:storingLong)
    }
    override func viewDidAppear(_ animated: Bool) {
        let myDouble = Double(savedLat)
        let mydouble = Double(savedLong)
        if mydouble == nil && myDouble == nil{
            print("Nil")
        }else{
            let latitudes: CLLocationDegrees = myDouble!
            let longitudes: CLLocationDegrees = mydouble!
            let latDeltas: CLLocationDegrees = 0.05
            let LongDeltas: CLLocationDegrees = 0.05
            let coordinatess = CLLocationCoordinate2D(latitude: latitudes, longitude: longitudes)
            let span = MKCoordinateSpan(latitudeDelta: latDeltas, longitudeDelta: LongDeltas)
            
            let regions = MKCoordinateRegion(center: coordinatess, span: span)
            map.setRegion(regions, animated: true)
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinatess
            annotation.title = savedPlaces
            map.addAnnotation(annotation)
        }
    }
    func save(savinPlace:[String],savingLatitude:[String],savingLongitude:[String]) {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "Memorable",
                                       in: managedContext)!
        let blog = NSManagedObject(entity: entity,
                                   insertInto: managedContext)
        blog.setValue(savingLatitude, forKeyPath: "latitude")
        blog.setValue(savingLongitude, forKeyPath: "longitude")
        blog.setValue(savinPlace, forKeyPath: "place")
        do {
            try managedContext.save()
            savLatLongCore.append(blog)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    func fetchcoreData() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Memorable")
        do {
            savLatLongCore = try managedContext.fetch(fetchRequest)
            for blog in savLatLongCore{
                storingLat = (blog.value(forKeyPath:"latitude") as? [String])!
                storingLong = (blog.value(forKeyPath:"longitude") as? [String])!
                storingPlace = (blog.value(forKeyPath:"place") as? [String])!
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
}

