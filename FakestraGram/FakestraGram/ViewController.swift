//
//  ViewController.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/13/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import CoreImage
import OpenGLES
import CoreData
import Photos


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate, UICollectionViewDataSource, UICollectionViewDelegate, FrameworkDelegate {
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var buttonPhotos: UIButton!
    
    

    var ciContext : CIContext?
    var originalThumbnail : UIImage?
    var filters = [Filter]()
    var filterThumbnails = [FilterThumbnail]()
    var imageToFilter : FilterImage?
    var originalImage : UIImage?
    var imageMain : UIImage?
    
    let imageQueue = NSOperationQueue()
    

    override func viewDidLoad() {
        println("CAPTURE")


        super.viewDidLoad()
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let moContext = appDelegate.managedObjectContext as NSManagedObjectContext!
        let seeder = SeedCoreData(moContext: moContext)
        if appDelegate.someValue != true {
            println("seeding")
            seeder.seedCoreData()
        } else {
            println("no seed")
            println("found : \(self.filters.count)")
            self.generateThumbnail()
            self.resetFilterThumbnails()
        }
        
        
        

        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.ciContext = CIContext(EAGLContext: myEAGLContext, options: options)
        
        

        
        
        
        self.imageMain = imageView.image as UIImage!
        self.collectionView.delegate = self
        self.fetchFilters()
        
        
        self.activityIndicator.backgroundColor = UIColor.blackColor()
        self.activityIndicator.opaque = false
        self.activityIndicator.alpha = 0.75
        self.activityIndicator.layer.masksToBounds = true
        self.activityIndicator.layer.cornerRadius = 6.0

        
        self.collectionView.dataSource = self
        
        println(CIFilter.filterNamesInCategories(nil))


    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
    }


    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        } else if segue.identifier == "FRAMEWORK_SEGUE" {
            let destinationVC = segue.destinationViewController as PhotosFrameworkViewController
            destinationVC.delegate = self
        } else if segue.identifier == "FOUNDATION_SEGUE" {
            let destinationVC = segue.destinationViewController as AVFoundationCameraViewController
            destinationVC.delegate = self

        }
        
    
        
    }
    
    func generateThumbnail () {
        let size = CGSize(width: 80, height: 80)
        UIGraphicsBeginImageContext(size)
        self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 80, height: 80))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
    func enterFilterMode() {
        self.buttonPhotos.hidden = true
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 2
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 2
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 2
        self.collectionViewBottomConstraint.constant = 8        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilteringMode")
        self.navigationItem.rightBarButtonItem = doneButton
        
    }
    
    func exitFilteringMode () {
        
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 2
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 2
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 2
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
        self.collectionViewBottomConstraint.constant = -100
        self.buttonPhotos.hidden = false
        
        self.navigationItem.rightBarButtonItem = nil
    }
    

    @IBAction func photosPressed(sender: AnyObject) {
        
        self.generateThumbnail()
        self.resetFilterThumbnails()
        
        let alertController = UIAlertController(title: nil, message: "Choose", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let galleryAction = UIAlertAction(title: "Choose from Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            
            }
        let filterAction = UIAlertAction(title: "Choose a Filter", style: .Default) { (action) -> Void in
            self.enterFilterMode()
        }
        let imageChooseAction = UIAlertAction(title: "Choose a Photo", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        let cameraAction = UIAlertAction(title: "Use the Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imageTaker = UIImagePickerController()
            imageTaker.allowsEditing = true
            imageTaker.sourceType = UIImagePickerControllerSourceType.Camera
            imageTaker.delegate = self
            self.presentViewController(imageTaker, animated: true, completion: nil)
            
            }
        let photosAction = UIAlertAction(title: "Photos Framework", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("FRAMEWORK_SEGUE", sender: self)
        }
        let foundationAction = UIAlertAction(title: "AV FOundation", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("FOUNDATION_SEGUE", sender: self)
        }
        
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            alertController.addAction(cameraAction)
            alertController.addAction(foundationAction)
        }
        alertController.addAction(imageChooseAction)
        alertController.addAction(filterAction)
        alertController.addAction(photosAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as UIImage!
        self.imageMain = self.imageView.image as UIImage!
        self.originalImage = nil
        
        self.dismissViewControllerAnimated(true, completion: nil)
        self.generateThumbnail()
        self.resetFilterThumbnails()
    }
    
    func didTapOnPicture(image: UIImage) {
        println("did tap on picture")
        self.imageView.image = image
        self.imageMain = self.imageView.image as UIImage!
        self.originalImage = nil
        self.generateThumbnail()
        self.resetFilterThumbnails()
    }
    
    func didPullAPicture(image: UIImage) {

        println("did pull a picture")
        self.imageView.image = image
        self.imageMain = image as UIImage!
        
        self.originalImage = nil
        self.generateThumbnail()
        self.resetFilterThumbnails()
        
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.filters.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterThumbnailCell
        
        println("Here")
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        
        if filterThumbnail.filteredThumbnail != nil {
            cell.imageView.image = filterThumbnail.filteredThumbnail
            println("found one")
        } else {
            println("need one")
            cell.imageView.image = filterThumbnail.originalThumbnail
            println(filterThumbnail.originalThumbnail.hashValue)
            filterThumbnail.generateThumbnail({ (image) -> Void in
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterThumbnailCell {
                    cell.imageView.image = image
                }
            })
        }
        if (cell.imageView.image != nil) {
            println("Cell has an image")  }
        else {
            println("Cell has no image")  }
        
        return cell
        
    }
    
    func fetchFilters () {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var error: NSError?
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let moContext = appDelegate.managedObjectContext as NSManagedObjectContext!
        
        
        
        let fetchResults = moContext.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            println("filters: \(filters.count)")
            self.filters = filters
        }
        
        self.generateThumbnail()
        self.resetFilterThumbnails()
        
    }
    
    func resetFilterThumbnails () {
        var newFilters = [FilterThumbnail]()
        for var index = 0; index < self.filters.count; ++index {
            var filter = self.filters[index]
            var filterName = filter.name
            var thumbnail = FilterThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, ciContext: self.ciContext!)
            newFilters.append(thumbnail)
        }
        self.filterThumbnails = newFilters
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("Trying")
        self.applyFilterToMainImage(indexPath)
        
    }
    
    func applyFilterToMainImage(indexPath : NSIndexPath) -> Void {
        self.activityIndicator.startAnimating()
        var name = self.filters[indexPath.row].name
        println("The filter is \(name)")
        
        var filterImage : FilterImage!
        
        if self.originalImage == nil {
            filterImage = FilterImage(name: name, image: self.imageMain!, queue: imageQueue, ciContext: ciContext!)
            
            filterImage.generateFilteredImage { (imageFiltered, imageOriginal) -> Void in
                var image = imageFiltered
                self.imageMain = imageFiltered
                self.originalImage = imageOriginal
                self.imageView.image = self.imageMain
                self.activityIndicator.stopAnimating()
            }

        } else {
            
            var typeInt : Int!
            self.originalOrFiltered({ (imageType) -> Void in
                typeInt = imageType
                
                if typeInt == 0 {
                    filterImage = FilterImage(name: name, image: self.originalImage!, queue: self.imageQueue, ciContext: self.ciContext!)
                } else {
                    filterImage = FilterImage(name: name, image: self.imageMain!, queue: self.imageQueue, ciContext: self.ciContext!)
                }
                
                filterImage.generateFilteredImage { (imageFiltered, imageOriginal) -> Void in
                    var image = imageFiltered
                    self.imageMain = imageFiltered
                    self.imageView.image = self.imageMain
                    self.activityIndicator.stopAnimating()
                }
            })

            
            
        }
        
        


        }
    
    func originalOrFiltered(completionHandler : (imageType : Int) -> Void) {
        var imageTypeIs : Int!
        let alertController = UIAlertController(title: nil, message: "Apply the filter to the original image or to the filtered image?", preferredStyle: UIAlertControllerStyle.Alert)
        let originalAction = UIAlertAction(title: "Original", style: UIAlertActionStyle.Default) { (action) -> Void in
            imageTypeIs = 0
            completionHandler(imageType : imageTypeIs)
            }
        let filteredAction = UIAlertAction(title: "Filtered", style: .Default) { (action) -> Void in
            imageTypeIs = 1
            completionHandler(imageType : imageTypeIs)
            }
        
        alertController.addAction(originalAction)
        alertController.addAction(filteredAction)
        self.presentViewController(alertController, animated: true) { () -> Void in
            
            }

        
        
        }
    



}




