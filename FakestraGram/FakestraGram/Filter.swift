//
//  Filter.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/14/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var name: String
    @NSManaged var favorited: NSNumber

}
