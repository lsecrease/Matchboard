//
//  AdProfileViewController.swift
//  Matchboard
//
//  Created by lsecrease on 5/26/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Foundation


class AdProfileViewController: UIViewController {
    
    @IBOutlet weak var profileName: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var profileFirstName: UILabel!
    @IBOutlet weak var sex: UILabel!
    @IBOutlet weak var age: UILabel!
    @IBOutlet weak var lookingForAd: AutoTextView!
    @IBOutlet weak var aboutMeText: AutoTextView!
    @IBOutlet weak var faveIcon: UIImageView!
    @IBOutlet weak var faveButton: DesignableButton!
    
    var searchedAdsArray = NSMutableArray()
    
    var singleAdArray = NSMutableArray()
    var adProfileModel = String()
    
    var mainVC: ViewController!
    var faveVC: FavoritesViewController!
    
    var favArray = NSMutableArray()
    var adObj = PFObject(className: "Ad")
    
    var createdByLabel = "first_name"
    var lookingForLabel = "lookingFor"
    var profileImageLabel = "profileImage"
    var usernameLabel = "username"
    
    
    override func viewWillAppear(animated: Bool) {
        // Query the selected Ad to get its details
        singleAdArray.removeAllObjects()
        querySingleAd()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
       // singleAdArray.removeAllObjects()
        //querySingleAd()
        
        //self.profileName.text = "Sam's Profile"
        //self.profileImage.image = singleAdArray.image
        //self.profileFirstName.text = adProfileModel.name
        //self.lookingForAd.text = adProfileModel.lookingFor
    }

    
    func querySingleAd() {
        print("SINGLE AD ID: \(adProfileModel)")
        
        let query = PFQuery(className: "Ad")
        query.whereKey("objectId", equalTo: adProfileModel)
        query.includeKey("username")
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.singleAdArray.addObject(object)
                       
                    } }
                // Show Ad details
                self.showAdDetails()
               
                
            } else {
                ParseErrorHandlingController.handleParseError(error!)
            }
        }
        
    }
    
    
    func showAdDetails() {
        var classif = PFObject(className: "Ad")
        classif = singleAdArray[0] as! PFObject

        //Get Profile Name
        self.profileName.text = "\(classif[createdByLabel]!)'s Profile"
        
        
        //Get Profile First Name
        profileFirstName.text = "\(classif[createdByLabel]!)"
//        var user = classif["username"] as! PFUser
//        user.fetchIfNeeded()
//        self.profileFirstName.text = user.username!
        
        
        //Get LookingFor Ad
        lookingForAd.text = "\(classif[lookingForLabel]!)"
        
        //Get Profile Image
        let profilePic = classif[profileImageLabel] as? PFFile
        profilePic?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    self.profileImage.image = UIImage(data: imageData)
                } } }
       
        
        
        //Query to see if Ad is on the Favorites - HELP
        favArray.removeAllObjects()
        let query = PFQuery(className: "Favorites")
        query.whereKey("username", equalTo: PFUser.currentUser()!)
        query.whereKey("adPointer", equalTo: adObj)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.favArray.addObject(object)
                        print("Fave Array Added")
                    } }
                // Show/Hide Favorite Star and shareView
                self.showFavHeart()
                print("showFave ran")
            } else { print("error: \(error!.description)") }
        }
        
    }
    
    func showFavHeart() {
        var favClass = PFObject(className: "Favorites")
        favClass = singleAdArray[0] as! PFObject
        if favClass["adPointer"] as! PFObject == adObj  {
            self.faveIcon.image = UIImage(named: "goldheart")
            self.faveButton.setTitle("Favorited", forState: .Normal)
        }
    }

    
    
    
    
    
    
    
    
    @IBAction func messageButtonTapped(sender: AnyObject) {
        print("Message button Tapped")
    }
    
    @IBAction func favoriteButtonTapped(sender: AnyObject) {
        print("Fave Button Tapped")
        let button = sender as! UIButton
        

        let favClass = PFObject(className: "Favorites")
        var adClass = adObj
        adClass = singleAdArray[button.tag] as! PFObject
        //favClass["userPointer"] = PFUser.currentUser()
       
        
            
            // ADD THIS AD TO FAVORITES
            favClass["username"] = PFUser.currentUser()?.username!
           favClass["adPointer"] = adClass
           favClass["adUsername"] = profileFirstName.text!
            // Saving block
            favClass.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    print("Fave Added Successfully")
                    self.faveIcon.image = UIImage(named: "goldheart")
                    self.faveButton.setTitle("Favorited", forState: .Normal)
                    let alert = UIAlertView(title: "Matchboard",
                        message: "\(self.profileFirstName.text!) has been added to your Favorites List!",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                } else {
                    let alert = UIAlertView(title: "Matchboard",
                        message: "Something went wrong, try again later, or check your internet connection",
                        delegate: nil,
                        cancelButtonTitle: "OK" )
                    alert.show()
                }
                
            } // end Saving block
            
            
        
    }
    
    @IBAction func backButtonTouched(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func blockThisUserButtonTapped(sender: AnyObject) {
        //Action Alert Asking if they are sure they want to block the user
        print("Block this User Tapped")
    }
    

   

}
