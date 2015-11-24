//
//  Photo.swift
//  VirtualTourist
//
//  Created by Travis Gillespie on 11/11/15.
//  Copyright © 2015 Travis Gillespie. All rights reserved.
//

import Foundation
import CoreData


class Photo: NSManagedObject {
// Insert code here to add functionality to your managed object subclass

    struct Keys {
        static let URL = "url"
        static let Title = "title"
        static let File = "file"
    }
    /// The Flickr URL
//    @NSManaged var url: String
    
    /// The file name in the documents directory
    @NSManaged var file: String
    
    /// The associated pin
    @NSManaged var pin: Pin?
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(imageURL: String, context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        
        url = NSString(string: imageURL) as String
    }

}