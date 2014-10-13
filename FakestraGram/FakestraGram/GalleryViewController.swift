//
//  GalleryViewController.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/13/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit

protocol GalleryDelegate    {
    func didTapOnPicture (image : UIImage)
}

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet weak var galleryView: UICollectionView!
    @IBOutlet weak var imgLabel: UILabel!

    
    
    var imageArray = [UIImage]()
    var delegate : GalleryDelegate?
    var sectionHeader : String?
    var sectionFooter : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.galleryView.dataSource = self
        self.galleryView.delegate = self
        
        var image1 = UIImage(named: "1.jpg")
        var image2 = UIImage(named: "2.jpg")
        var image3 = UIImage(named: "3.jpg")
        var image4 = UIImage(named: "4.jpg")
        var image5 = UIImage(named: "5.jpg")
        
        self.imageArray.append(image1)
        self.imageArray.append(image2)
        self.imageArray.append(image3)
        self.imageArray.append(image4)
        self.imageArray.append(image5)
        
    }
    
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imageArray.count
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        var header : CollectionSectionHeaderView? = nil
        var footer : CollectionSectionFooterView? = nil
        var isKind : UICollectionReusableView?
        var collectionView = collectionView
        
        if (kind == UICollectionElementKindSectionHeader) {
            header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "TITLE_HEADER", forIndexPath: indexPath) as? CollectionSectionHeaderView
            if indexPath.section == 1 {
                header!.sectionHeaderLabel?.text = "Section numero Uno"
            } else {
                header!.sectionHeaderLabel?.text = "Section numero Dos"
            }
            
            
            isKind = header!
            
        } else if kind == UICollectionElementKindSectionFooter { //
            footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "FOOTER_HEADER", forIndexPath: indexPath) as? CollectionSectionFooterView
            footer?.collectionFooterLabel.text = "\(self.imageArray.count) images in section"
            
            isKind = footer!
            
        }
        
        return isKind!
    }
    
    

    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = galleryView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
        
        cell.galleryCellImage.image = self.imageArray[indexPath.row]
        cell.imgLabel.text = self.imageArray[indexPath.row].debugDescription
        
        return cell
    }
    
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        println("selected")
        self.delegate?.didTapOnPicture(self.imageArray[indexPath.row])
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    



}
