//
//  Photo+CoreDataProperties.swift
//  VirtualTourist
//
//  Created by Travis Gillespie on 11/11/15.
//  Copyright © 2015 Travis Gillespie. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
//import UIKit

extension Photo {

    @NSManaged var title: String?
    @NSManaged var url: String
    @NSManaged var location: Pin?

}
