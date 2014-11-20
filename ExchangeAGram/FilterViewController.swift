//
//  FilterViewController.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 30/10/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import UIKit

class FilterViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    var thisFeedItem: FeedItem!
    var collectionView: UICollectionView!
    
    let kIntensity = 0.7
    
    var context:CIContext = CIContext(options: nil)
    var filters: [CIFilter] = []
    
    let placeholderImage = UIImage(named: "Placeholder")
    
    let tmp = NSTemporaryDirectory()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.itemSize = CGSize(width: 150.10, height: 150.0)
        
        self.collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.whiteColor()
        
        // the .self in Swift is equivalent to [FilterCell class] in objectiveC!
        self.collectionView.registerClass(FilterCell.self, forCellWithReuseIdentifier: "MyCell")
        
        
        self.view.addSubview(self.collectionView)
        
        
        self.filters = photoFilters()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: UICollectionView data source
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.filters.count
        
    }
    

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
     
        let filterCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("MyCell", forIndexPath: indexPath) as FilterCell

        
        // with the image cacheing, no need to check if the filterCell.imageView.image property is nil
            
            // set placeholder image
            filterCell.imageView.image = self.placeholderImage
            
            // create a dispatch queue to be able to run the filter processing on a background thread
            let filterQueue: dispatch_queue_t  = dispatch_queue_create("filter queue", nil)
            
            dispatch_async(filterQueue, { () -> Void in
                
             //   let filteredImage =   self.filteredImageFromImage(self.thisFeedItem.thumbnail, filter: self.filters[indexPath.row])
                let filteredImage = self.getCachedImage(indexPath.row)
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    filterCell.imageView.image = filteredImage
                    
                })
                
            })
            
        
        
        return filterCell

    }
    

    
    // if the user tap on one of the filtered images, it will be saved as image.
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
       
        self.createUIAlertController(indexPath)
        
        
        
        
        
        
    }
    
    
    //MARK: Helper functions
    
    func photoFilters() -> [CIFilter] {
        
        let blur = CIFilter(name: "CIGaussianBlur")
        let instant = CIFilter(name: "CIPhotoEffectInstant")
        let noir = CIFilter(name: "CIPhotoEffectNoir")
        let transfer = CIFilter(name: "CIPhotoEffectTransfer")
        let unsharpen = CIFilter(name: "CIUnsharpMask")
        let monochrome = CIFilter(name: "CIColorMonochrome")
        
        let colorControls = CIFilter(name: "CIColorControls")
        colorControls.setValue(0.5, forKey: kCIInputSaturationKey)
        
        let sepia = CIFilter(name: "CISepiaTone")
        sepia.setValue(kIntensity, forKey: kCIInputIntensityKey)
        
        let colorClamp = CIFilter(name: "CIColorClamp")
        colorClamp.setValue(CIVector(x: 0.9, y: 0.9, z: 0.9, w: 0.9), forKey: "inputMaxComponents")
        colorClamp.setValue(CIVector(x: 0.2, y: 0.2, z: 0.2, w: 0.2), forKey: "inputMinComponents")
        
        let composite = CIFilter(name: "CIHardLightBlendMode")
        composite.setValue(sepia.outputImage, forKey: kCIInputImageKey)
        
        let vignette = CIFilter(name: "CIVignette")
        vignette.setValue(composite.outputImage, forKey: kCIInputImageKey)
        
        vignette.setValue(kIntensity * 2, forKey: kCIInputIntensityKey)
        vignette.setValue(kIntensity * 30, forKey: kCIInputRadiusKey)

        
        return [blur, instant, noir, transfer, unsharpen, monochrome, colorControls, sepia, colorClamp, composite, vignette]
        
    }
    
    
    
    func filteredImageFromImage(imageData: NSData, filter:CIFilter) ->UIImage {
        
        // convert image data into CIImage
        let unfilteredImage = CIImage(data: imageData)
        
        // apply filter
        filter.setValue(unfilteredImage, forKey: kCIInputImageKey)
        
        
        // get back the filtered Image
        let filteredImage: CIImage = filter.outputImage
        
            // extent() is a CGRect
        let extent = filteredImage.extent()
        
        // convert to CGimage
        let cgImage: CGImageRef = self.context.createCGImage(filteredImage, fromRect: extent)
        
        //convert to UIImage. It is possible to convert CIImage directly to UIImage (  let finalImage = UIImage(CIImage: filteredImage)! but the conversion time takes much longer, blocking the UI! therefore convert to CGImage first! 
        let finalImage = UIImage(CGImage: cgImage, scale:1.0, orientation: UIImageOrientation.Up)!
        
      
        
        return finalImage
        
    }
    
    // UIAlert helpers
    
    func createUIAlertController(indexPath: NSIndexPath) {
        
        
        let alert = UIAlertController(title: "photo options", message: "Please choose an option", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            
            textField.placeholder = "Add caption"
            textField.secureTextEntry = false
            
            
            
        }
        
        var text: String
        // grab text field entry from alert controller (there is only 1 text field, so index is 0
        let textField = alert.textFields![0] as UITextField
        
       
        // add alert action - works like a button in the UIAlertController window. destructive means the button's text is red
        let photoAction = UIAlertAction(title: "Post photo to Facebook with caption", style: UIAlertActionStyle.Destructive) { (UIAlertAction) -> Void in
            
            self.shareToFacebook(indexPath)
            
            
            var text = textField.text
            self.saveFilterToCoreData(indexPath, caption: text)
            
            
            
            //add posting to FB
            
        }
        //add the action
        alert.addAction(photoAction)
        
        
        
        let saveFilterAction = UIAlertAction(title: "Save filter without posting on Facebook", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
            
            var text = textField.text
            
            
            self.saveFilterToCoreData(indexPath, caption: text)
            
            
        }
        
        alert.addAction(saveFilterAction)
        
        
        let cancelAction = UIAlertAction(title: "Select another filter", style: UIAlertActionStyle.Cancel) { (UIAlertAction) -> Void in
            
        }
        
        alert.addAction(cancelAction)
        
        
        self.presentViewController(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    func saveFilterToCoreData (indexPath: NSIndexPath, caption: String) {
        
        let filterImage = self.filteredImageFromImage(thisFeedItem.image, filter: self.filters[indexPath.row])
        
        //convert UIImage to data
        let imageData = UIImageJPEGRepresentation(filterImage, 1.0)
        
        self.thisFeedItem.image = imageData
        
        let thumbnailData = UIImageJPEGRepresentation(filterImage, 0.1)
        
        self.thisFeedItem.thumbnail = thumbnailData
        
        self.thisFeedItem.caption = caption
        
        self.thisFeedItem.filtered = true
        
        (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
        
        self.navigationController?.popViewControllerAnimated(true)

        
    }
    
    
    func shareToFacebook(indexPath:NSIndexPath) {
        
        let filterImage = self.filteredImageFromImage(thisFeedItem.image, filter: self.filters[indexPath.row])
        
        let photos:NSArray = [filterImage]
        
        var params = FBPhotoParams()
        
        
        params.photos = photos
        
        FBDialogs.presentShareDialogWithPhotoParams(params, clientState: nil) { (call, result, error) -> Void in
            
            if result? != nil {
                
                println(result)
            }
            
            else {
                println(error)
                
                
            }
            
        }
        
        
    }
    
    
    //MARK: Cacheing functions
    
    
    func cacheImage(imageNumber: Int) {
        
        
        let fileName = "\(self.thisFeedItem.uniqueID)_\(imageNumber)"
        
        println(fileName)
        
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            
            let data = self.thisFeedItem.thumbnail
            let filter = self.filters[imageNumber]
            let thumbnail = self.filteredImageFromImage(data, filter: filter)
            
            UIImageJPEGRepresentation(thumbnail, 1.0).writeToFile(uniquePath, atomically: true)
            
            
            
            
        }
        
    }
    
    
    func getCachedImage (imageNumber: Int) -> UIImage {
        
         let fileName = "\(self.thisFeedItem.uniqueID)_\(imageNumber)"
        
        let uniquePath = self.tmp.stringByAppendingPathComponent(fileName)
        
        var image: UIImage
        
        if NSFileManager.defaultManager().fileExistsAtPath(uniquePath) {
            
           var returnedImage = UIImage(contentsOfFile:  uniquePath)!
            // rotate image (otherwise wrong orientation on device)
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!
        }
        
        else {
            
            self.cacheImage(imageNumber)
            
            var returnedImage = UIImage(contentsOfFile:  uniquePath)!
              // rotate image (otherwise wrong orientation on device)
            image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)!

        }
        
        return image
        
    }
    
    

}
