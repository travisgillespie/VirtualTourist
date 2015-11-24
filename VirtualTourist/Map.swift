//
//  Map.swift
//  VirtualTourist
//
//  Created by Travis Gillespie on 11/4/15.
//  Copyright © 2015 Travis Gillespie. All rights reserved.
//

import UIKit
import MapKit
import CoreData

//protocol PinPickerDelegate: class{
//    func didSelectPin(pin: Pin)
//}

class Map: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!

    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBOutlet weak var toggleBackground: UIView!
    @IBOutlet weak var toggleLabel: UILabel!

    lazy var coreDataStack = CoreDataStack()
//    weak var pickerDelegate: PinPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideUnhide(true, label: true)
        longPressGesture()
        mapView.delegate = self
        mapView.addAnnotations(fetchStoredPins())
    }
    
    override func viewWillAppear(animated: Bool) {
        coreDataStack.saveMainContext()
    }
    
    override func viewWillDisappear(animated: Bool) {
        coreDataStack.saveMainContext()
    }

    func hideUnhide(background: Bool, label: Bool){
        toggleBackground.hidden = background
        toggleLabel.hidden = label
    }
    
    @IBAction func barButtonPressed(sender: UIBarButtonItem) {
        if barButton.title == "Edit" {
            UIView.transitionWithView(toggleBackground, duration: 0.3, options: .TransitionCurlDown, animations: {
                self.hideUnhide(false, label: false)
            }, completion: nil)
            barButton.title = "Done"
        } else {
            UIView.transitionWithView(toggleBackground, duration: 0.3, options: .TransitionCurlUp, animations: {
                    self.hideUnhide(true, label: true)
            }, completion: nil)
            barButton.title = "Edit"
        }
    }
    
    func longPressGesture(){
        let lpg = UILongPressGestureRecognizer(target: self, action: "longPressAction:")
        lpg.minimumPressDuration = 0.5
        mapView.addGestureRecognizer(lpg)
    }
    
    func longPressAction(myLongPress: UILongPressGestureRecognizer){
        if (myLongPress.state == UIGestureRecognizerState.Began){
            //see where the user has clicked
            let myCGPoint = myLongPress.locationInView(mapView)
            let myMapPoint = mapView.convertPoint(myCGPoint, toCoordinateFromView: mapView)

            //create an annotation
            let pin = Pin(annotationLatitude: myMapPoint.latitude, annotationLongitude: myMapPoint.longitude, context: coreDataStack.managedObjectContext)
            mapView.addAnnotation(pin)
            print("addedPin \(pin)")
            coreDataStack.saveMainContext()
        }
    }
    
    func fetchStoredPins() -> [Pin] {
//        var i = 0
        let fetchRequest = NSFetchRequest(entityName: "Pin")
        do {
            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)
//            for result in results {
//                print("\(++i):results \(result)")
//            }
            return results as! [Pin]
        } catch let error as NSError {
            print("Error in fectchAllPins(): \(error)")
        }
        return []
    }
    
    func mapView(mapView: MKMapView, didSelectAnnotationView view: MKAnnotationView) {
        if barButton.title == "Edit" {
            segueToPhotoAlbum(view.annotation)
        } else if barButton.title == "Done" {
            deletePin(view.annotation)
        }
    }
    
    
    func segueToPhotoAlbum(annotation: MKAnnotation?){
        mapView.deselectAnnotation(annotation, animated: false)
        let selectedPin = annotation as! Pin
//        pickerDelegate?.didSelectPin(selectedPin)

        performSegueWithIdentifier("transitionToAlbum", sender: selectedPin)
    }
    
    func deletePin(annotation: MKAnnotation?){
        let selectedPin = annotation as! Pin
        coreDataStack.managedObjectContext.deleteObject(selectedPin)
        mapView.removeAnnotation(selectedPin)
        coreDataStack.saveMainContext()
//        fetchStoredPins()
//        print("selectedPinDelete \(selectedPin)")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "transitionToAlbum" {
            if let photoAlbum = segue.destinationViewController as? PhotoAlbum {
                photoAlbum.selectedPin = sender as? Pin
            }
        }
    }
}