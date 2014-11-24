//
//  FilterImage.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/15/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

class FilterImage {
    
    var originalImage : UIImage
    var filteredImage : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var filter : CIFilter?
    var filterName : String
    
    init(name: String, image : UIImage, queue : NSOperationQueue, ciContext : CIContext) {
        self.filterName = name
        self.originalImage = image
        self.imageQueue = queue
        self.gpuContext = ciContext
    }
    
    func generateFilteredImage(completionHandler : (imageFiltered : UIImage, imageOriginal : UIImage) -> Void) {
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            var image = CIImage(image: self.originalImage)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            switch imageFilter.name() {
            case "CIPixellate" :
                imageFilter.setValue(32.0, forKey: kCIInputScaleKey)
            case "CIGaussianBlur" :
                imageFilter.setValue(20.0, forKey: kCIInputRadiusKey)
                println("gblur")
            case "CIGammaAdjust" :
                imageFilter.setValue(2.5, forKey: "inputPower" )
            case "CIExposureAdjust" :
                imageFilter.setValue(1.5, forKey: kCIInputEVKey)
            case "CIGlassDistortion" :
                var imageDistortBase = UIImage(named: "glasstex", inBundle: NSBundle.mainBundle(), compatibleWithTraitCollection: nil)
                var imageFor = CIImage(image: imageDistortBase)
                imageFilter.setValue(imageFor, forKey: "inputTexture")
                imageFilter.setValue(300.0, forKey: kCIInputScaleKey)
            default :
                println("default")
            }
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filter = imageFilter
            self.filteredImage = UIImage(CGImage: imageRef)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(imageFiltered: self.filteredImage!, imageOriginal: self.originalImage)
            })
        })
    }

} // End
