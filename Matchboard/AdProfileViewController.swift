//
//  AdProfileViewController.swift
//  Matchboard
//
//  Created by lsecrease on 5/26/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Foundation

enum ProfileTableSection : Int {
    case Bio
    case LookingFor
    case AboutMe
    case Links
    case Block
}

enum UserColumns : String {
    case firstName = "first_name"
    case lookingFor = "lookingFor"
    case profileImage = "profileImage"
    case username = "username"
}


class AdProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BioCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var searchedAdsArray = NSMutableArray()
    
    var singleAdArray = NSMutableArray()
    var adProfileModel = String()
    var currentAd : PFObject?
    
    var mainVC: ViewController!
    var faveVC: FavoritesViewController!
    
    var favArray = NSMutableArray()
    var adObj = PFObject(className: "Ad")
    
    override func viewWillAppear(animated: Bool) {
        // Query the selected Ad to get its details
        querySingleAd()
    }

    func querySingleAd() {
        print("SINGLE AD ID: \(adProfileModel)")
        
        let query = PFQuery(className: "Ad")
        query.whereKey("objectId", equalTo: adProfileModel)
        query.includeKey("username")
        query.limit = 1
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    self.singleAdArray.removeAllObjects()
                    for object in objects {
                        self.currentAd = object
                       
                    } }
                // Show Ad details

                if let name = self.currentAd?[UserColumns.firstName.rawValue] as? String
                {
                    self.title = name
                }
                self.tableView.reloadData()
               
                
            } else {
                ParseErrorHandlingController.handleParseError(error!)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.row {
        case ProfileTableSection.Bio.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("BioCell", forIndexPath: indexPath) as! BioCell
            if let currentAd = currentAd {
                cell.configureCellWithAd(currentAd)
            }
            cell.delegate = self
            return cell
            
        case ProfileTableSection.LookingFor.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LookingForCell", forIndexPath: indexPath)
            return cell
            
        case ProfileTableSection.AboutMe.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("AboutMeCell", forIndexPath: indexPath)
            return cell
            
        case ProfileTableSection.Links.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinksCell", forIndexPath: indexPath)
            return cell
            
        case ProfileTableSection.Block.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("BlockCell", forIndexPath: indexPath)
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("BioCell", forIndexPath: indexPath)
            return cell
            
        }
    }
    
    // MARK: - UITableViewDelegate
    
//
//    func showAdDetails() {
//        var classif = PFObject(className: "Ad")
//        classif = singleAdArray[0] as! PFObject
//
//        //Get Profile Name
//        self.profileName.text = "\(classif[createdByLabel]!)'s Profile"
//        
//        
//        //Get Profile First Name
//        profileFirstName.text = "\(classif[createdByLabel]!)"
//        
//        //Get LookingFor Ad
//        lookingForAd.text = "\(classif[lookingForLabel]!)"
//        
//        //Get Profile Image
//        let profilePic = classif[profileImageLabel] as? PFFile
//        profilePic?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
//            if error == nil {
//                if let imageData = imageData {
//                    self.profileImage.image = UIImage(data: imageData)
//                } } }
//       
//        
//        
//        //Query to see if Ad is on the Favorites - HELP
//        favArray.removeAllObjects()
//        let query = PFQuery(className: "Favorites")
//        query.whereKey("username", equalTo: PFUser.currentUser()!)
//        query.whereKey("adPointer", equalTo: adObj)
//        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
//            if error == nil {
//                if let objects = objects as? [PFObject] {
//                    for object in objects {
//                        self.favArray.addObject(object)
//                        print("Fave Array Added")
//                    } }
//                // Show/Hide Favorite Star and shareView
//                self.showFavHeart()
//                print("showFave ran")
//            } else { print("error: \(error!.description)") }
//        }
//        
//    }
//    
//    func showFavHeart() {
//        var favClass = PFObject(className: "Favorites")
//        favClass = singleAdArray[0] as! PFObject
//        if favClass["adPointer"] as! PFObject == adObj  {
//            self.faveIcon.image = UIImage(named: "goldheart")
//            self.faveButton.setTitle("Favorited", forState: .Normal)
//        }
//    }
//
//    
//    
//    
//    
//    
//    
//    
//    
//    @IBAction func messageButtonTapped(sender: AnyObject) {
//        print("Message button Tapped")
//    }
//    
//    @IBAction func favoriteButtonTapped(sender: AnyObject) {
//        print("Fave Button Tapped")
//        let button = sender as! UIButton
//        
//
//        let favClass = PFObject(className: "Favorites")
//        var adClass = adObj
//        adClass = singleAdArray[button.tag] as! PFObject
//        //favClass["userPointer"] = PFUser.currentUser()
//       
//        
//            
//            // ADD THIS AD TO FAVORITES
//            favClass["username"] = PFUser.currentUser()?.username!
//           favClass["adPointer"] = adClass
//           favClass["adUsername"] = profileFirstName.text!
//            // Saving block
//            favClass.saveInBackgroundWithBlock { (success, error) -> Void in
//                if error == nil {
//                    print("Fave Added Successfully")
//                    self.faveIcon.image = UIImage(named: "goldheart")
//                    self.faveButton.setTitle("Favorited", forState: .Normal)
//                    let alert = UIAlertView(title: "Matchboard",
//                        message: "\(self.profileFirstName.text!) has been added to your Favorites List!",
//                        delegate: nil,
//                        cancelButtonTitle: "OK" )
//                    alert.show()
//                } else {
//                    let alert = UIAlertView(title: "Matchboard",
//                        message: "Something went wrong, try again later, or check your internet connection",
//                        delegate: nil,
//                        cancelButtonTitle: "OK" )
//                    alert.show()
//                }
//                
//            } // end Saving block
//            
//            
//        
//    }
    
    
    
//    @IBAction func blockThisUserButtonTapped(sender: AnyObject) {
//        //Action Alert Asking if they are sure they want to block the user
//        print("Block this User Tapped")
//    }
    
    @IBAction func backButtonPressed(sender: AnyObject) {
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
   
    // MARK: - BioCellDelegate
    func messageButtonPressed(sender:AnyObject)
    {
        print("Message button Tapped")
    }
    func favoriteButtonPressed(sender:AnyObject)
    {
        print("Favorite button Tapped")
        // TODO: clean this up
        
//        let button = sender as! UIButton
//        
//        
//        let favClass = PFObject(className: "Favorites")
//        var adClass = adObj
//        adClass = singleAdArray[button.tag] as! PFObject
//        //favClass["userPointer"] = PFUser.currentUser()
//        
//        
//        
//        // ADD THIS AD TO FAVORITES
//        favClass["username"] = PFUser.currentUser()?.username!
//        favClass["adPointer"] = adClass
//        favClass["adUsername"] = profileFirstName.text!
//        // Saving block
//        favClass.saveInBackgroundWithBlock { (success, error) -> Void in
//            if error == nil {
//                print("Fave Added Successfully")
//                self.faveIcon.image = UIImage(named: "goldheart")
//                self.faveButton.setTitle("Favorited", forState: .Normal)
//                let alert = UIAlertView(title: "Matchboard",
//                    message: "\(self.profileFirstName.text!) has been added to your Favorites List!",
//                    delegate: nil,
//                    cancelButtonTitle: "OK" )
//                alert.show()
//            } else {
//                let alert = UIAlertView(title: "Matchboard",
//                    message: "Something went wrong, try again later, or check your internet connection",
//                    delegate: nil,
//                    cancelButtonTitle: "OK" )
//                alert.show()
//            }
//            
//        } // end Saving block
    }
}
