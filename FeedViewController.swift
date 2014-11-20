//
//  FeedViewController.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 29/10/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import UIKit
import MobileCoreServices
import CoreData
import MapKit


class FeedViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate , CLLocationManagerDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var feedArray: [AnyObject] = []
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    
    var locationManager: CLLocationManager!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let backgroundImage = UIImage(named: "AutumnBackground")
        self.view.backgroundColor = UIColor(patternImage: backgroundImage!)
        
        self.locationManager = CLLocationManager()
        
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestAlwaysAuthorization()
        
        self.locationManager.distanceFilter = 100.0
        self.locationManager.startUpdatingLocation()
        

        
        
    }
    
    override func viewDidAppear(animated: Bool) {
       
        super.viewDidAppear(animated)
        
        let request = NSFetchRequest(entityName: "FeedItem")
        
        let context = self.appDelegate.managedObjectContext!
        
        // executeFetchRequest doesn't know type. therefore, specify AnyObject as array element.
        self.feedArray = context.executeFetchRequest(request, error: nil)!
        
        println(self.feedArray.count)
        
        self.collectionView.reloadData()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: IBActions
    
    @IBAction func profileTapped(sender: UIBarButtonItem) {
        
        self.performSegueWithIdentifier("profileSegue", sender: self)
        
        
    }
    
    
    
    @IBAction func snapBarButtonItemTapped(sender: UIBarButtonItem) {
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            
           var cameraController = UIImagePickerController()
            cameraController.delegate = self
            cameraController.sourceType = UIImagePickerControllerSourceType.Camera
            
            // kUTTypeImage is a cfstring identifier for image data
            let mediaTypes:[AnyObject] = [kUTTypeImage]
            
            cameraController.mediaTypes = mediaTypes
            
            cameraController.allowsEditing = false
            
            self.presentViewController(cameraController, animated: true, completion: nil)
            
            
            
        }
        
        else if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) {
            
            var photoLibraryController = UIImagePickerController()
            
            photoLibraryController.delegate = self
            photoLibraryController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            let mediaTypes: [AnyObject] = [kUTTypeImage]
            
            photoLibraryController.mediaTypes = mediaTypes
            
            photoLibraryController.allowsEditing = false
            
            self.presentViewController(photoLibraryController, animated: true, completion: nil)
            
        }
        
        else {
            
            var alertView = UIAlertController(title: "Alert", message: "Your device does not support the camera or photo library", preferredStyle: .Alert)
            
            alertView.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            
            self.presentViewController(alertView, animated: true, completion: nil)

            
            
        }
        
    }
    
    //MARK: image picker delegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        let image = info[UIImagePickerControllerOriginalImage]  as UIImage
        
       let imageData = UIImageJPEGRepresentation(image, 1.0)
        
        // create thumbnail with high compression rate!
        let thumbnailData = UIImageJPEGRepresentation(image, 0.1)
        
        let mangedObjectContext = self.appDelegate.managedObjectContext //optional
        
        let entityDescription = NSEntityDescription.entityForName("FeedItem", inManagedObjectContext: mangedObjectContext!)
        
        let feedItem = FeedItem(entity: entityDescription!, insertIntoManagedObjectContext: mangedObjectContext!)
        
        feedItem.thumbnail = thumbnailData!
        feedItem.image = imageData!
        feedItem.caption = "test caption"

       
        if let latitude = self.locationManager.location?.coordinate.latitude {
            
            feedItem.latitude = self.locationManager.location!.coordinate.latitude

            
        }
        
        else if let longitude = self.locationManager.location?.coordinate.longitude {
            
              feedItem.longitude = self.locationManager.location!.coordinate.longitude
            
        }
        
        
        // generate a unique id
        let uuId = NSUUID().UUIDString
        feedItem.uniqueID = uuId
        feedItem.filtered = false
        
        self.appDelegate.saveContext()
        
        self.feedArray.append(feedItem)
    
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
        self.collectionView.reloadData()
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: UICollectionView data source and delegate 
    
    func numberOfSectionsInCollectionView(collectionView:UICollectionView) -> Int {
        
        return 1
        
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.feedArray.count
        
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cell:FeedCell = self.collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as FeedCell
    
        
        let thisFeedItem: FeedItem = self.feedArray[indexPath.row] as FeedItem
  
        if thisFeedItem.filtered == true {
            
            let returnedImage = UIImage(data: thisFeedItem.image)!
            
            let image = UIImage(CGImage: returnedImage.CGImage, scale: 1.0, orientation: UIImageOrientation.Up)
            
            cell.imageView.image = image
            
        }
        
        else {
            
            cell.imageView.image = UIImage(data: thisFeedItem.image)!
            
        }
        

        
        cell.captionLabel.text = thisFeedItem.caption
        
                  
        return cell
        
    }
    
    
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        let thisItem = self.feedArray[indexPath.row] as FeedItem
        
        var filterVC = FilterViewController()
        
        filterVC.thisFeedItem = thisItem
        
        self.navigationController?.pushViewController(filterVC, animated: false)
        
    }
    
    //MARK: CLLocation manager delegate
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        println("location updated")
        
        println(self.locationManager.location.coordinate.latitude)
        println(self.locationManager.location.coordinate.longitude)
        
        println("locations = \(locations)")
        
        
    }


}
