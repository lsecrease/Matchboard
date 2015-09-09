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
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoritesArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FaveCell", forIndexPath: indexPath) as! FavoritesCell
        cell.backgroundColor = UIColor.clearColor()
        
        var favClass = PFObject(className: "Favorites")
        favClass = favoritesArray[indexPath.row] as! PFObject
        // Get Ads as a Pointer
        let adPointer = favClass["adPointer"] as! PFObject
        
        cell.userNameLabel.text = "\(adPointer[usernameTitle]!)"
        cell.lookingForLabel.text = "\(adPointer[lookingForTitle]!)"
        
        // Get image
        let imageFile = adPointer[profileImageTitle] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.userProfileImage.image = UIImage(data:imageData)
                } } }
        

        
        return cell
    
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let imageView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
        let image = UIImage(named: "BkgrdBlur")
        imageView.image = image
        
        if indexPath.row % 2 != 0 {
            cell.backgroundView = UIView()
            cell.backgroundView?.addSubview(imageView)
        }
        
    }
    
    
    
    
    
    //UITableViewDelagate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var favClass = PFObject(className: "Favorites")
        favClass = favoritesArray[indexPath.row] as! PFObject
        // Get favorite Ads as a Pointer
        let adPointer = favClass["adPointer"] as! PFObject
        
        let showAdVC = self.storyboard?.instantiateViewControllerWithIdentifier("showProfile") as! AdProfileViewController
        // Pass the Ad ID to the Controller
        showAdVC.adProfileModel = adPointer.objectId!
        self.navigationController?.pushViewController(showAdVC, animated: true)
        
        //performSegueWithIdentifier("showProfile", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }
    
    
    func queryFavAds()  {
        favoritesArray.removeAllObjects()
        
        let query = PFQuery(className: "Favorites")
        query.whereKey("username", equalTo: PFUser.currentUser()!.username!)
        query.includeKey("adPointer")
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.favoritesArray.addObject(object)
                    } }
                // Show details (or reload a TableView)
                self.faveTableView.reloadData()
                
            } else {
                let alert = UIAlertView(title: "Matchboard",
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: self,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
        }
        
    }


}
