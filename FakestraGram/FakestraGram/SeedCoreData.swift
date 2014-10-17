//
//  SeedCoreData.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/14/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import Foundation
import CoreData

class SeedCoreData {
    
    var managedObjectContext : NSManagedObjectContext!
    
    init (moContext: NSManagedObjectContext) {
        self.managedObjectContext = moContext
    }
    
    func seedCoreData() {
        
        let filterFilters = ["CISepiaTone", "CIGaussianBlur", "CIPixellate", "CIGammaAdjust", "CIExposureAdjust", "CIPhotoEffectChrome", "CIPhotoEffectInstant","CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectTonal", "CIPhotoEffectTransfer", "CIGlassDistortion"]
        
        //

        for item in filterFilters {
            var filterEntity = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
            filterEntity.name = item
            
        }
        
        
        
        var error : NSError?
        self.managedObjectContext?.save(&error)
        if error != nil {
            println(error?.localizedDescription)
        }
    }
    
    
}

