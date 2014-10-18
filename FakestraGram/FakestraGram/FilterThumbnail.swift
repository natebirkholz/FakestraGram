//
//  FilterThumbnail.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/14/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class FilterThumbnail {
    
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var filter : CIFilter?
    var filterName : String
    
    init(name: String, thumbnail : UIImage, queue : NSOperationQueue, ciContext : CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = ciContext
    }
    
    func generateThumbnail(completionHandler : (image : UIImage) -> Void) {
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            if imageFilter.name() != nil {
                switch imageFilter.name() {
                case "CIPixellate" :
                    imageFilter.setValue(3.0, forKey: kCIInputScaleKey)
                    
                case "CIGaussianBlur" :
                    imageFilter.setValue(2.0, forKey: kCIInputRadiusKey)
                    println("gbkur")
                    
                case "CIGammaAdjust" :
                    imageFilter.setValue(2.5, forKey: "inputPower" )
                    
                case "CIExposureAdjust" :
                    imageFilter.setValue(1.5, forKey: kCIInputEVKey)
                    
                case "CIGlassDistortion" :
                    var imageDistortBase = UIImage(named: "glasstex", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
                    var imageFor = CIImage(image: imageDistortBase)
                    imageFilter.setValue(imageFor, forKey: "inputTexture")
                    imageFilter.setValue(200.0, forKey: kCIInputScaleKey)
                    
                default :
                    println("default")
                    
                }
            }
            
            
            
//            if imageFilter.name() == "CIPixellate" {
//                imageFilter.setValue(3.0, forKey: kCIInputScaleKey)
//            } else if imageFilter.name() == "CIGaussianBlur" {
//                imageFilter.setValue(2.0, forKey: kCIInputRadiusKey)
//            }
            
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            
            self.filter = imageFilter
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: self.filteredThumbnail!)
            })
        })
    }
    
    
}

