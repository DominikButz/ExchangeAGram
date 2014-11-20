//
//  FeedItem.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 17/11/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import Foundation
import CoreData

class FeedItem: NSManagedObject {

    @NSManaged var caption: String
    @NSManaged var uniqueID: String
    @NSManaged var image: NSData
    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var thumbnail: NSData
    @NSManaged var filtered: NSNumber

}
