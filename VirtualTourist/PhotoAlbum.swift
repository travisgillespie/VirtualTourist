//
//  PhotoAlbum.swift
//  VirtualTourist
//
//  Created by Travis Gillespie on 11/5/15.
//  Copyright © 2015 Travis Gillespie. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import CoreData

protocol PinPickerDelegate: class{
    func didSelectPin(pin: Pin)
}

//latitude = "30.26239307962591";
//longitude = "-97.74272739301018";

// MARK: - Globals

let BASE_URL = "https://api.flickr.com/services/rest/"
let METHOD_NAME = "flickr.photos.search"
let API_KEY = "f4af49a216cf5a63f64dfcebbaa976ba"
let EXTRAS = "url_m"
let SAFE_SEARCH = "1"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
let BOUNDING_BOX_HALF_WIDTH = 1.0
let BOUNDING_BOX_HALF_HEIGHT = 1.0
let LAT_MIN = -90.0
let LAT_MAX = 90.0
let LON_MIN = -180.0
let LON_MAX = 180.0

class PhotoAlbum: UIViewController, MKMapViewDelegate, UICollectionViewDelegate {
    var selectedPin: Pin!
    var photo: Photo?
    var photos = [Photo]()
    private let reuseIdentifier = "FlickrCell"
    private var searches = [FlickrSearchResults]()
    private let flickr = Flickr()
//    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    @IBAction func buttonDone(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var collectionView: UICollectionView!

    
//    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func buttonNewCollection(sender: UIButton) {
        print("this should call a new search on flickr")
//                collectionView?.reloadData()
        
//        let methodArguments = [
//            "method": METHOD_NAME,
//            "api_key": API_KEY,
//            "bbox": createBoundingBoxString(),
//            "safe_search": SAFE_SEARCH,
//            "extras": EXTRAS,
//            "format": DATA_FORMAT,
//            "nojsoncallback": NO_JSON_CALLBACK
//        ]
//        getImageFromFlickrBySearch(methodArguments)
        print("collectionView-> \(collectionView)")
    }
    
//    var coreDataStack: CoreDataStack!
    lazy var coreDataStack = CoreDataStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        // set initial map location to pin coordinates
//        print("selectedPinPhotoAlbum \(selectedPin)")
        let pinLatitude = selectedPin.latitude as Double
//        print("lat0-> \(selectedPin.latitude)")
        let pinLongitude = selectedPin.longitude as Double
        
        // load coordinate on map
        let initialLocation = CLLocation(latitude: pinLatitude, longitude: pinLongitude)
        let coordinate = CLLocationCoordinate2D(latitude: pinLatitude, longitude: pinLongitude)
        let myAnnotation = MKPointAnnotation()
        myAnnotation.coordinate = coordinate
        mapView.addAnnotation(myAnnotation)
        centerMapOnLocation(initialLocation)
//        textShouldReturn("bananas")
//                print("lat1-> \(pinLatitude)")
        pinShouldReturn(selectedPin.latitude, lon: selectedPin.longitude)
        fetchStoredPhotos()

///////////////////////////////////////////////////////////////////////////////////////////////
        //view a photo
//        let photo = Photo(dictionary: <#T##[String : AnyObject]#>, context: coreDataStack.managedObjectContext)
//        let pin = Pin(annotationLatitude: myMapPoint.latitude, annotationLongitude: myMapPoint.longitude, context: coreDataStack.managedObjectContext)

        
        // call image function
        
    }
    
    
    func fetchStoredPhotos() -> [Photo]{
        let fetchRequest = NSFetchRequest(entityName: "Photo")
        do {
//            if let result = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest) as? [Photo]{
//                    photos = result
//                    print("photo \(photos)")
//                }
//            } catch {
//                print("Error in fetchAllPins(): \(error)")
//            }

            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)
            print("PhotoResults-> \(results as! [Photo])")
            return results as! [Photo]
        } catch let error as NSError {
            print("Error in fetchAllPins(): \(error)")
        }
        return []
        
    }
    
//    func fetchStoredPins() -> [Pin] {
//        //        var i = 0
//        let fetchRequest = NSFetchRequest(entityName: "Pin")
//        do {
//            let results = try coreDataStack.managedObjectContext.executeFetchRequest(fetchRequest)
//            //            for result in results {
//            //                print("\(++i):results \(result)")
//            //            }
//            return results as! [Pin]
//        } catch let error as NSError {
//            print("Error in fectchAllPins(): \(error)")
//        }
//        return []
//    }
    
//    override func viewWillDisappear(animated: Bool) {
//        coreDataStack.saveMainContext()
//    }
//
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate, regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
//    func photoForIndexPath(indexPath: NSIndexPath) -> FlickrPhoto{
//        return searches[indexPath.section].searchResults[indexPath.row]
//    }
//    
//}
//
//extension PhotoAlbum: UICollectionViewDataSource {
//    
//    //1
//    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
////        print("searches \(searches.count)")
//        return searches.count
//    }
//    
//    //2
//    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            // if array for pin is empty download flickr photos... else load photos... Vid2 addTestData()
////        print("searches2")
//        return searches[section].searchResults.count
//    }
//    
//    //3
//    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        //vid2 cellForRowAtIndexPath device.valueForKey
//        //1
//        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FlickrCell", forIndexPath: indexPath) as! FlickrPhotoCell
//        //2
//        let flickrPhoto = photoForIndexPath(indexPath)
//        cell.backgroundColor = UIColor.blackColor()
//        //3
//        cell.imageView.image = flickrPhoto.thumbnail
//        
////        print("cell")
//        return cell
//    }
//    
//    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
//        print("this section will prepare to delete image from view, cache and array")
//        
////        if let pinPicker = 
//        //save()
//        //reload view-> self.collectionView?.reloadData()
//        //look at 14min for some ideas https://www.veasoftware.com/tutorials/2015/7/1/collection-view-in-swift-xcode-7-ios-9-tutorial
//        
//    }
}

//extension PhotoAlbum: PinPickerDelegate {
//    func didSelectPin(pin: Pin) {
//        photo?.location = pin
//        print("pin selected: \(photo?.location)")
//    }
//}

//extension PhotoAlbum : UICollectionViewDelegateFlowLayout {
//    //1
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
//            
//            let flickrPhoto =  photoForIndexPath(indexPath)
//            //2
//            if var size = flickrPhoto.thumbnail?.size {
//                size.width += 10
//                size.height += 10
//                return size
//            }
//            return CGSize(width: 100, height: 100)
//    }
//    
//    //3
//    func collectionView(collectionView: UICollectionView,
//        layout collectionViewLayout: UICollectionViewLayout,
//        insetForSectionAtIndex section: Int) -> UIEdgeInsets {
//            return sectionInsets
//    }
//}

extension PhotoAlbum : UITextFieldDelegate {
    
    func pinShouldReturn(lat: NSNumber, lon: NSNumber) -> Bool {
//        print("lat1: \(lat)\nlon1: \(lon)")
//        var pinPicker = PinPickerDelegate.self
//        pinPicker.didSelectPin(Pin) = photo?.location
//        PinPickerDelegate.didSelectPin(Pin)
//        let pinPicker = PinPickerDelegate.self
//        pinPicker.
//        pinPicker = photo?.location
//        PinPickerDelegate.self.didSelectPin(Pin) = photo?.location
        
        flickr.searchFlickrForLocationStoreResults(lat, lon: lon) {
            results, error in
//            print("resulst \(results)")
            
            //2
            //            activityIndicator.removeFromSuperview()
            if error != nil {
                print("Error searching : \(error)")
            }
            
            if results != nil {
                //3
//                print("Found \(results!.searchResults.count) matching \(results!.lat)")
//                print("Found these results -> \(results!)")
                self.searches.insert(results!, atIndex: 0)
                
                //4
                self.collectionView?.reloadData()
            }
        }
        
        //        textField.text = nil
        //        textField.resignFirstResponder()
        return true
    }
    
//    func textShouldReturn(text: String) -> Bool {
//        // 1
////        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
////        textField.addSubview(activityIndicator)
////        activityIndicator.frame = textField.bounds
////        activityIndicator.startAnimating()
//        flickr.searchFlickrForTerm(text) {
//            results, error in
//            
//            //2
////            activityIndicator.removeFromSuperview()
//            if error != nil {
//                print("Error searching : \(error)")
//            }
//            
//            if results != nil {
//                //3
//                print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
//                self.searches.insert(results!, atIndex: 0)
//                
//                //4
//                self.collectionView?.reloadData()
//            }
//        }
//        
////        textField.text = nil
////        textField.resignFirstResponder()
//        return true
//    }
}