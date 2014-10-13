//
//  ViewController.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/13/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GalleryDelegate {
    
    
    @IBOutlet weak var imageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
    var image = UIImage(named: "1.jpg")
        println(image.size)
    
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY" {
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        }
    
        
    }
    
    

    @IBAction func photosPressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: "Choose", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
            }
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            
            }
        let imageChooseAction = UIAlertAction(title: "Choose an Image", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            imagePicker.delegate = self
            self.presentViewController(imagePicker, animated: true, completion: nil)
            }
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imageTaker = UIImagePickerController()
            imageTaker.allowsEditing = true
            imageTaker.sourceType = UIImagePickerControllerSourceType.Camera
            imageTaker.delegate = self
            self.presentViewController(imageTaker, animated: true, completion: nil)
            
            }
        
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
            alertController.addAction(cameraAction)
        }
        alertController.addAction(imageChooseAction)
        
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.imageView.image = info[UIImagePickerControllerEditedImage] as UIImage!
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func didTapOnPicture(image: UIImage) {
        println("did tap on picture")
        self.imageView.image = image
    }
    

}



