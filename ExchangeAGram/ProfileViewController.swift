//
//  ProfileViewController.swift
//  ExchangeAGram
//
//  Created by Dominik Butz on 02/11/14.
//  Copyright (c) 2014 Duoyun. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController, FBLoginViewDelegate {

    
    @IBOutlet weak var profileImageView: UIImageView!
    
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var fbLoginView: FBLoginView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.fbLoginView.delegate = self
        self.fbLoginView.readPermissions = ["public_profile", "publish_actions"]
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    //MARK: FB delegate functions
    
    func loginViewShowingLoggedInUser(loginView: FBLoginView!) {
        
        self.profileImageView.hidden = false
        self.nameLabel.hidden = false
        
        
        
        
    }
    
    
    func loginViewFetchedUserInfo(loginView: FBLoginView!, user: FBGraphUser!) {
        
        //called after successful login and user info fetched
        
        println(user)
        
        self.nameLabel.text = user.name
        
        let userimageURL = "https://graph.facebook.com/\(user.objectID)/picture?type=small"
        
        let url = NSURL(string: userimageURL)
        
        let imageData = NSData(contentsOfURL: url!)
        
        
        let image = UIImage(data: imageData!)
        
        self.profileImageView.image = image
        
        
        
    }
    
    func loginViewShowingLoggedOutUser(loginView: FBLoginView!) {
        
        self.profileImageView.hidden = true
        self.nameLabel.hidden = true
        
        
    }
    
    
    func loginView(loginView: FBLoginView!, handleError error: NSError!) {
        
        println("Error: \(error.localizedDescription)")
        
        
    }

    //MARK:
    
    @IBAction func mapViewButtonTapped(sender: UIButton) {
        
        self.performSegueWithIdentifier("mapSegue", sender: sender)
        
    }
    
}
