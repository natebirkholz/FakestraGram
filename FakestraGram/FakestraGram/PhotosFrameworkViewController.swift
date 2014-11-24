//
//  PhotosFrameworkViewController.swift
//  FakestraGram
//
//  Created by Nathan Birkholz on 10/15/14.
//  Copyright (c) 2014 Nate Birkholz. All rights reserved.
//

import UIKit
import Photos

let reuseIdentifier = "FRAMEWORK_CELL"

protocol FrameworkDelegate {
  func didPullAPicture (image : UIImage)
}

class PhotosFrameworkViewController: UICollectionViewController, UICollectionViewDataSource, UICollectionViewDelegate {

// ---------------------------------------
// MARK: Properties
// ---------------------------------------

  var assetFetchResults : PHFetchResult!
  var assetCollection : PHAssetCollection!
  var imageManager : PHCachingImageManager!
  var assetCellSize: CGSize!
  var delegate : FrameworkDelegate?
  var flowLayout : UICollectionViewFlowLayout!

// ---------------------------------------
// MARK: Lifecycle
// ---------------------------------------

  override func viewDidLoad() {
    super.viewDidLoad()
    self.imageManager = PHCachingImageManager()
    self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
    var scale = UIScreen.mainScreen().scale
    var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
    var cellSize = flowLayout.itemSize
    self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
    self.flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
    var pinch = UIPinchGestureRecognizer(target: self, action: "didPinch:")
    self.collectionView.addGestureRecognizer(pinch)
  }

// ---------------------------------------
// MARK: CollectionView
// ---------------------------------------

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return 1
  }
  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.assetFetchResults.count
  }

  override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath) as PhotosFrameworkCell
    var asset = self.assetFetchResults[indexPath.row] as PHAsset
    var currentTag = cell.tag + 1
    cell.tag = currentTag
    self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
      if cell.tag == currentTag {
        cell.outGoing.image = image
      }
    }
    return cell
  }

  override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    println("Selected")
    var phAsset = self.assetFetchResults[indexPath.row] as PHAsset!
    var imageIs : UIImage!
    self.imageManager.requestImageDataForAsset(phAsset, options: nil) { (data, string, orientation, info) -> Void in
      imageIs = UIImage(data: data)
      self.delegate?.didPullAPicture(imageIs!)
    }

    self.dismissViewControllerAnimated(true, completion: nil)
  }

  func didPinch (pinch : UIPinchGestureRecognizer) {
    if pinch.state == UIGestureRecognizerState.Ended {
      println(pinch.velocity)
      self.collectionView.performBatchUpdates({ () -> Void in
        if pinch.velocity > 0 {
          if self.flowLayout.itemSize.width > 200 {
            println("Too big")
          } else {
            self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 2, height: self.flowLayout.itemSize.height * 2)
          }
        } else {
          if self.flowLayout.itemSize.width < 60 {
            println("Too small")
          } else {
            self.flowLayout.itemSize = CGSize(width: self.flowLayout.itemSize.width * 0.5, height: self.flowLayout.itemSize.height * 0.5)
          }
        }
        }, completion: nil )
    }
  }

} // End
