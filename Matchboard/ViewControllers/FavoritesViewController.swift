//
//  FavoritesViewController.swift
//  Matchboard
//
//  Created by lsecrease on 7/29/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var faveTableView: UITableView!
    
    var favoritesArray = NSMutableArray()
    
    var usernameTitle = "createdBy"
    var lookingForTitle = "lookingFor"
    var profileImageTitle = "profileImage"
    
    override func viewWillAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            queryFavAds()
        } else {
            let alert = UIAlertView(title: "Matchboard",
                message: "You must login/signup into your Account to add Favorites",
                delegate: nil,
                cancelButtonTitle: "OK" )
            alert.show()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        faveTableView.backgroundColor = UIColor.clearColor()
        print("Favorites Array \(favoritesArray.count)")
   
    }

    //Passing Data - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            var favClass = PFObject(className: "Favorites")
            if let navVC = segue.destinationViewController as? UINavigationController
            {
                if let adVC  = navVC.topViewController as? AdProfileViewController
                {
                    if let indexPath = self.faveTableView.indexPathForSelectedRow
                    {
                        favClass = favoritesArray[indexPath.row] as! PFObject
                    }
                    
                    if let adObject = favClass["adPointer"] as? PFObject
                    {
                        adVC.adProfileModel = adObject.objectId!
                    }
                }
            }
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:FavoritesCell = tableView.dequeueReusableCellWithIdentifier("FaveCell", forIndexPath: indexPath) as! FavoritesCell
        cell.backgroundColor = UIColor.clearColor()
        
        var favClass = PFObject(className: "Favorites")
        favClass = favoritesArray[indexPath.row] as! PFObject
        var adClass = PFObject(className:"Ad")
        adClass = favClass["adPointer"] as! PFObject
        // Get Ads as a Pointer
        //let adPointer = favClass["adPointer"] as! PFObject
        
        cell.userNameLabel.text = "\(adClass[usernameTitle]!)"
        cell.lookingForLabel.text = "\(adClass[lookingForTitle]!)"
        
        // Get image
        if let user = adClass[AdColumns.username.rawValue] as? PFUser
        {
            // Make sure we have all the data before loading image.
            user.fetchIfNeededInBackgroundWithBlock({
                (object, error) in
                if (error != nil) {
                    NSLog("Error fetching user: \(user) with error \(error)")
                    // throw?
                }
                if let tempUser = object {
                    let imageFile = tempUser[UserColumns.profileImage.rawValue] as? PFFile
                    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.userProfileImage.image = UIImage(data:imageData)
                            }
                        }
                    }
                }
            })
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
//        let imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
//        let image = UIImage(named: "BkgrdBlur")
//        imageView.image = image
//        
//        if indexPath.row % 2 != 0 {
//            cell.backgroundView = UIView()
//            cell.backgroundView?.addSubview(imageView)
//        }
        
    }
    
    //UITableViewDelagate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // TODO: do this through the "showProfile" segue
//        var favClass = PFObject(className: "Favorites")
//        favClass = favoritesArray[indexPath.row] as! PFObject
//        // Get favorite Ads as a Pointer
//        let adPointer = favClass["adPointer"] as! PFObject
//        
//        let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("showProfile") as! AdProfileViewController
//        // Pass the Ad ID to the Controller
//        showAdVC.adProfileModel = adPointer.objectId!
//        self.navigationController?.pushViewController(showAdVC, animated: true)
//        
//        performSegueWithIdentifier("showProfile", sender: self)
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    func queryFavAds()  {
        favoritesArray.removeAllObjects()
        
        let query = PFQuery(className: "Favorites")
        if let user = PFUser.currentUser()
        {
            query.whereKey("userPointer", equalTo: user)
            query.includeKey("adPointer")
            query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
                if error == nil {
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            self.favoritesArray.addObject(object)
                        }
                    }
                    // Show details (or reload a TableView)
                    self.faveTableView.reloadData()
                    
                } else {
                    ParseErrorHandlingController.handleParseError(error!)
                }
            }
        }
    }
    
}
