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
    case Block
    case Links
}

enum UserColumns : String {
    case aboutMe = "aboutMe"
}

enum AdColumns : String {
    case firstName = "first_name"
    case lookingFor = "lookingFor"
    case profileImage = "profileImage"
    case username = "username"
}

class AdProfileViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BioCellDelegate, AboutMeCellDelegate, LookingForCellDelegate, BlockUserDelegate, EditAboutMeDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var editButton: UIBarButtonItem?
    
    var searchedAdsArray = NSMutableArray()
    
    var adProfileModel = String()
    var currentAd : PFObject?
    var favoriteObj : PFObject?
    var isMine = false
    
    var mainVC: ViewController!
    var faveVC: FavoritesViewController!
    
    var favArray = NSMutableArray()
    
    override func viewWillAppear(animated: Bool) {
        // Query the selected Ad to get its details
        querySingleAd()
        editButton = navigationItem.rightBarButtonItem
        navigationItem.rightBarButtonItem = nil
    }

    // MARK: - Actions
    
    @IBAction func editButtonPressed(sender: AnyObject) {
        print("edit button pressed")
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditAboutMeSegue"
        {
            if let editAboutMeVC = segue.destinationViewController as? EditAboutMeViewController
            {
                editAboutMeVC.delegate = self
                
                // setup text
                if let user = currentAd?[AdColumns.username.rawValue] as? PFObject
                {
                    if let aboutMe = user[UserColumns.aboutMe.rawValue] as? String {
                        editAboutMeVC.configureWithAboutMeText(aboutMe)
                    }
                    
                }
            }
        }
    }
    
    // MARK: - Custom
    
    func querySingleAd() {
        print("SINGLE AD ID: \(adProfileModel)")
        
        let query = PFQuery(className: "Ad")
        query.whereKey("objectId", equalTo: adProfileModel)
        query.includeKey("username")
        query.limit = 1
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    
                    for object in objects {
                        self.currentAd = object
                        
                        // if we have a current user
                        if let user = PFUser.currentUser()
                        {
                            // if this ad is mine, show the edit button
                            if object[AdColumns.username.rawValue]?.objectId == user.objectId {
                                self.isMine = true
                            }
                            
                            let favQuery = PFQuery(className: "Favorites")
                            favQuery.whereKey("adPointer", equalTo: object)

                            favQuery.whereKey("userPointer", equalTo:user)
                            favQuery.limit = 1
                            favQuery.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                                if error == nil {
                                    if let objects = objects as? [PFObject] {
                                        
                                        for object in objects
                                        {
                                            self.favoriteObj = object
                                        }
                                        
                                    } else {
                                        self.favoriteObj = nil
                                    }
                                } else {
                                    self.favoriteObj = nil
                                }
                                
                                self.tableView.reloadData()
                            })
                        } else {
                            self.tableView.reloadData()
                        }
                    }
                }
                
                // Show Ad details
                if let name = self.currentAd?[AdColumns.firstName.rawValue] as? String
                {
                    self.title = name
                }
                
            } else {
                ParseErrorHandlingController.handleParseError(error!)
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        switch indexPath.row {
        case ProfileTableSection.Bio.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("BioCell", forIndexPath: indexPath) as! BioCell
            if let currentAd = currentAd {
                cell.configureCellWithAd(currentAd, isFavorite: favoriteObj != nil, isMine: isMine)
            }
            cell.delegate = self
            return cell
            
        case ProfileTableSection.LookingFor.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LookingForCell", forIndexPath: indexPath) as! LookingForCell
            if let currentAd = currentAd {
                cell.configureCellWithAd(currentAd, isMine: isMine)
            }
            cell.delegate = self
            return cell
            
        case ProfileTableSection.AboutMe.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("AboutMeCell", forIndexPath: indexPath) as! AboutMeCell
            if let currentAd = currentAd {
                cell.configureCellWithAd(currentAd, isMine: isMine)
            }
            cell.delegate = self
            return cell
            
        case ProfileTableSection.Links.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("LinksCell", forIndexPath: indexPath)
            return cell
            
        case ProfileTableSection.Block.rawValue:
            let cell = tableView.dequeueReusableCellWithIdentifier("BlockUserCell", forIndexPath: indexPath) as! BlockUserCell
            cell.delegate = self
            return cell
            
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("BioCell", forIndexPath: indexPath)
            return cell
            
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        switch indexPath.row {
        case ProfileTableSection.Bio.rawValue:
            return 118.0
            
        case ProfileTableSection.LookingFor.rawValue:
            return 270.0
            
        case ProfileTableSection.AboutMe.rawValue:
            return 140.0
            
        case ProfileTableSection.Links.rawValue:
            return 100.0
            
        case ProfileTableSection.Block.rawValue:
            return 100.0
            
        default:
            return 90.0
            
        }
    }
    
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
    
    // // MARK: - BlockUserDelegate
    
    func blockUserPressed()
    {
        print("block user")
    }
   
    // MARK: - BioCellDelegate
    
    func messageButtonPressed(sender:AnyObject)
    {
        print("Message button Tapped")
    }
    
    func favoriteButtonPressed(sender:AnyObject)
    {
        print("Favorite button Tapped")
        
        // favorite something
        if favoriteObj == nil
        {
            let favClass = PFObject(className: "Favorites")
            favClass["userPointer"] = PFUser.currentUser()
            
            // figure out if it's a favorite already or not
            
            // ADD THIS AD TO FAVORITES
            favClass["username"] = PFUser.currentUser()?.username!
            favClass["adPointer"] = currentAd
            if let name = currentAd?[AdColumns.firstName.rawValue] as? String {
                favClass["adUsername"] = name
            }
            
            // Saving block
            favClass.saveInBackgroundWithBlock { (success, error) -> Void in
                if error == nil {
                    if let objectId = favClass.objectId
                    {
                        self.favoriteObj = favClass
                        print("Fave Added Successfully \(objectId)")
                    }
                    
                } else {
                    print ("Fave add failed")
                }
                
            } // end Saving block
        }

        // unfavorite something
        else {
            
            if let favoriteObj = favoriteObj
            {
                favoriteObj.deleteInBackgroundWithBlock({ (success, error) -> Void in
                    print("delete in background \(success)")
                    self.favoriteObj = nil
                })
            }
        }
    }
    
    func avatarEditButtonPressed(sender: AnyObject) {
        print("avatar edit button pressed")
    }
    
    func profileEditButtonPressed(sender: AnyObject) {
        print("profile edit button pressed")
    }

    // MARK: - LookingForCellDelegate
    
    func editLookingForPressed(sender: AnyObject) {
        print("looking for edit pressed")
    }
    
    // MARK: - AboutMeCellDelegate
    
    func aboutEditButtonPressed(sender: AnyObject) {
        print("about me edit pressed")
    }
    
    // MARK: - EditAboutMeDelegate
    func aboutMeSaved(aboutMeString: String) {

        if let user = currentAd?[AdColumns.username.rawValue] as? PFObject
        {
            user[UserColumns.aboutMe.rawValue] = aboutMeString
            let indexPath = NSIndexPath(forRow: ProfileTableSection.AboutMe.rawValue, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            user.saveInBackground()
        }
        
        navigationController?.popViewControllerAnimated(true)
    }
}
