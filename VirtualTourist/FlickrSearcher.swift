//
//  FlickrSearcher.swift
//  flickrSearch
//
//  Created by Richard Turton on 31/07/2014.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//let apiKey = "f4af49a216cf5a63f64dfcebbaa976ba"
//let perPage = 20
//let pageNumber = 1 //convert to RANDOM # b/w 1 - Last Page# In callback or get rid of this parameter in the callback



struct FlickrSearchResults {
//    let searchTerm : String
    let lat : NSNumber
    let lon : NSNumber
//    let searchResults : [FlickrPhoto]
}

//class FlickrPhoto : Equatable {
//    var thumbnail : UIImage?
//    var largeImage : UIImage?
//    let photoID : String
//    let farm : Int
//    let server : String
//    let secret : String
//    let latitude : Double
//    let longitude : Double

//    init (photoID:String,farm:Int, server:String, secret:String) {
////    init (photoID:String,farm:Int, server:String, secret:String, latitude: Double, longitude: Double) {
//        self.photoID = photoID
//        self.farm = farm
//        self.server = server
//        self.secret = secret
////        self.latitude = latitude
////        self.longitude = longitude
//
////        "id":"23108065722",
////        "owner":"44192512@N00",
////        "secret":"c59cd4e710",
////        "server":"595",
////        "farm":1,
////        "title":"Lost in Austin",
////        "ispublic":1,
////        "isfriend":0,
////        "isfamily":0
//        
//    }
    
//    func flickrImageURL(size:String = "m") -> NSURL {
//        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
//    }
    
//    func loadLargeImage(completion: (flickrPhoto:FlickrPhoto, error: NSError?) -> Void) {
//        let loadURL = flickrImageURL("b")
//        let loadRequest = NSURLRequest(URL:loadURL)
//        let loadSession = NSURLSession.sharedSession()
//        
//        let task = loadSession.dataTaskWithRequest(loadRequest, completionHandler: {data, response, error in
//            
//            if error != nil {
//                completion(flickrPhoto: self, error: error)
//                return
//            }
//            
//            if data != nil {
//                let returnedImage = UIImage(data: data!)
//                self.largeImage = returnedImage
//                completion(flickrPhoto: self, error: nil)
//                return
//            }
//            
//            completion(flickrPhoto: self, error: nil)
//        })
//        task.resume()
//    }
    
//    func sizeToFillWidthOfSize(size:CGSize) -> CGSize {
//        if thumbnail == nil {
//            return size
//        }
//        
//        let imageSize = thumbnail!.size
//        var returnSize = size
//        
//        let aspectRatio = imageSize.width / imageSize.height
//        
//        returnSize.height = returnSize.width / aspectRatio
//        
//        if returnSize.height > size.height {
//            returnSize.height = size.height
//            returnSize.width = size.height * aspectRatio
//        }
//        
//        return returnSize
//    }
//    
//}

//func == (lhs: FlickrPhoto, rhs: FlickrPhoto) -> Bool {
//    return lhs.photoID == rhs.photoID
//}

class Flickr {
    lazy var coreDataStack = CoreDataStack()
    var i = 0
    func searchFlickrForLocationStoreResults(lat: NSNumber, lon: NSNumber, completion : (results: FlickrSearchResults?, error : NSError?) -> Void) {
        
        //change the func name and the parameter
        let searchURL = flickrSearchURLForLocation(lat, lon: lon)
//        print("url \(searchURL)")
        let searchRequest = NSURLRequest(URL: searchURL)
        let searchSession = NSURLSession.sharedSession()
//        print("searchFlickrForLocation-> \(searchSession)")
        
        let task = searchSession.dataTaskWithRequest(searchRequest, completionHandler: {data, response, error in
            if error != nil {
                completion(results: nil,error: error)
                return
            }
            
            do {
                print("searchFlickrForLocation-> nil \nDATA \(data!)\nRESPONSE \(response!)")
                
                //http://stackoverflow.com/questions/32349924/cannot-parse-json-array-as-nsarray-in-swift-2
                //http://stackoverflow.com/questions/27915383/swift-nsjsonserialization-and-nserror
                let resultsDictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: [.AllowFragments, .MutableContainers]) as! NSDictionary
                print("resultsDictionary-> \(resultsDictionary)")
                
//This isn't getting called
                switch (resultsDictionary["stat"] as! String) {
                case "ok":
                    print("Results processed OK")
                case "fail":
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary["message"]!])
                    completion(results: nil, error: APIError)
                    return
                default:
                    let APIError = NSError(domain: "FlickrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                    completion(results: nil, error: APIError)
                    return
                }
                
                
                let photosContainer = resultsDictionary["photos"] as! NSDictionary
                let photosReceived = photosContainer["photo"] as! [NSDictionary]
                
                for flickrPhoto in photosReceived {
//                    print("photos \(flickrPhoto)")
                    let photoID = flickrPhoto["id"] as? String ?? ""
                    let farm = flickrPhoto["farm"] as? Int ?? 0
                    let serverID = flickrPhoto["server"] as? String ?? ""
                    let secret = flickrPhoto["secret"] as? String ?? ""
//                    let photoTitle = flickrPhoto["title"] as? String ?? ""
//                    let photo = Photo(imageURL: photoId!, context: self.coreDataStack.managedObjectContext)
//                    let photo = Photo(imageURL: photoId!, context: self.coreDataStack.managedObjectContext)
                    
                    
//                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
                    let flickrPhoto = self.flickrImageURLAsString(farm, server: serverID, photoID: photoID, secret: secret)
//                    let imageData = NSData(contentsOfURL: flickrPhoto)
//                    NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
//                    var titleN = "\(++self.i)"
                    let photo = Photo(imageURL: flickrPhoto, context: self.coreDataStack.managedObjectContext)
                    print("\nphoto-> \(++self.i): \(photo)")
                    self.coreDataStack.saveMainContext()
//                    print("imageData-> \(imageData)")
//                    let photo
                }
                
                
//                let randomPhotoIndex = Int(arc4random_uniform(UInt32(photosArray.count)))
//                let photoDictionary = photosArray[randomPhotoIndex] as [String: AnyObject]
//                let photoTitle = photoDictionary["title"] as? String /* non-fatal */
                
                
                
//is this flickrPhoto an array that can be stored in cache or directory
//use local store will be quicker
//                let flickrPhotos : [FlickrPhoto] = photosReceived.map {
//                    photoDictionary in
//                    
//                    let photoID = photoDictionary["id"] as? String ?? ""
//                    let farm = photoDictionary["farm"] as? Int ?? 0
//                    let server = photoDictionary["server"] as? String ?? ""
//                    let secret = photoDictionary["secret"] as? String ?? ""
//                    
////                    let imageURL = flickrImageURL(farm, server: server, photoID: photoID, secret: secret)
//                    let photoURL = self.flickrImageURL(farm, server: server, photoID: photoID, secret: secret)
////                    let flickrPhoto = FlickrPhoto(photoID: photoID, farm: farm, server: server, secret: secret)
//                    
//                    let imageData = NSData(contentsOfURL: photoURL)
////                    let photo = Photo(imageURL: photoURL, context: self.coreDataStack.managedObjectContext)
////                    print("imageData \(imageData)")
////                    flickrPhoto.thumbnail = UIImage(data: imageData!)
//                    
////                    let photo = Photo(imageURL: photoID, context: self.coreDataStack.managedObjectContext)
////                    print("photo \(photo)")
////                    return flickrPhoto
//                }
                
                
                dispatch_async(dispatch_get_main_queue(), {
//                    let pin = Pin(annotationLatitude: lat, annotationLongitude: longitude, context: coreDataStack.managedObjectContext)

//                    let photo = Photo(imageURL: photoID, context: coreDataStack.managedObjectContext)
//                    let photo = Photo(dictionary: [photosContainer["photos"] : photosReceived], context: coreDataStack.managedObjectContext)
//                    completion(results:FlickrSearchResults(lat: lat, lon: lon, searchResults: flickrPhotos), error: nil)
//                        (searchTerm: searchTerm, searchResults: flickrPhotos), error: nil)
                })
                
            } catch let JSONError as NSError {
                print("NOPE \(JSONError)")
                completion(results: nil, error: JSONError)
                return
            }
        })
        task.resume()
    }
    
//    func flickrImageURL(farm: Int, server: String, photoID: String, secret: String, size:String = "m") -> NSURL {
//        return NSURL(string: "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg")!
//    }

    func flickrImageURLAsString(farm: Int, server: String, photoID: String, secret: String, size:String = "t") -> String {
        let url = "https://farm\(farm).staticflickr.com/\(server)/\(photoID)_\(secret)_\(size).jpg"
        return url
    }
    
    private func flickrSearchURLForLocation(lat: NSNumber, lon: NSNumber) -> NSURL {
        
        let apiKey = "f4af49a216cf5a63f64dfcebbaa976ba"
        let perPage = 20
        let pageNumber = 1 //convert to RANDOM # b/w 1 - Last Page# In callback or get rid of this parameter in the callback
        let accuracy = 16
        
//        https://www.flickr.com/services/api/explore/flickr.photos.search
        let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&accuracy=\(accuracy)&lat=\(lat)&lon=\(lon)&per_page=\(perPage)&page=\(pageNumber)&format=json&nojsoncallback=1"
        
//        accuracy (Optional)
//        Recorded accuracy level of the location information. Current range is 1-16 :
//        World level is 1
//        Country is ~3
//        Region is ~6
//        City is ~11
//        Street is ~16
        
        
        
        return NSURL(string: url)!
    }
}























