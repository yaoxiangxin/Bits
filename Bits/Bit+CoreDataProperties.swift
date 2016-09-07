//
//  Bit+CoreDataProperties.swift
//  Bits
//
//  Created by Huanzhong Huang on 3/8/16.
//  Copyright © 2016 Huanzhong Huang. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Bit {

    @NSManaged var text: String?
    @NSManaged var dateModified: NSDate?

}
