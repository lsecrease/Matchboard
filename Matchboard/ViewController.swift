//
//  ViewController.swift
//  Matchboard
//
//  Created by lsecrease on 3/29/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Parse


//var AdsArray: [Ad] = []



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, AdTableViewCellDelegate {


    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBox: UISearchBar!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var settingsView: UIView!
   
    var isFirstTime = true
    
    var adArray = NSMutableArray()
    
    var lookingForTitle = "lookingFor"
    var distanceTitle = "distance"
    var nameTitle = "name"
    var creatorTitle = "createdBy"
    
    var refreshControl: UIRefreshControl!
    
    
    //Search stuff
    var is_Searching:Bool! = false
    var searchingAdArray:NSMutableArray!
    
    let transitionManager = TransitionManager()
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //PFUser.currentUser()
        print("\(PFUser.currentUser()?.username)")
        //PFUser.logOut()
        
        searchBox.delegate = self
        
        
        
        //Pull to Refresh
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.blueColor()
        tableView.addSubview(refreshControl)
        refreshControl?.addTarget(self, action: "refreshAds", forControlEvents: UIControlEvents.ValueChanged)
        
        
        adArray.removeAllObjects()
        //var innerQuery = PFQuery(className: "User")
        //innerQuery.whereKeyExists("name")
        let query = PFQuery(className: "Ad")
        //query.whereKey(CLASSIF_CATEGORY, equalTo: categoryStr)
        //query.whereKey("createdBy", matchesQuery: innerQuery)
        query.orderByAscending("updatedAt")
        query.limit = 30
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.adArray.addObject(object)
                    } }
                // Go to Browse Ads VC
                print("\(self.adArray.count)")
                self.tableView.reloadData()
                
            } else {
                let alert = UIAlertView(title: "Matchboard",
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: self,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
        }

        
//        session.saveInBackgroundWithBlock {
//            (success: Bool, error: NSError?) -> Void in
//            if (success) {
//                println("Success")
//            } else {
//                println("Error Occured")
//                PFUser.logOut()
//                self.performSegueWithIdentifier("login", sender: self)
//            }
       //}
        
 

       //Segment Control Appearance
        
        mySegmentedControl.setDividerImage(UIImage(named: "SegCtrl-noneselected"), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setDividerImage(UIImage(named: "SegCtrl-noneselected"), forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setDividerImage(UIImage(named: "SegCtrl-noneselected"), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setBackgroundImage(UIImage(named: "SegCtrl-selected"), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setBackgroundImage(UIImage(named: "SegCtrl-normal"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        let attr = NSDictionary(object: UIFont(name: "Avenir Next", size: 12.0)!, forKey: NSFontAttributeName)
        mySegmentedControl.setTitleTextAttributes(attr as [NSObject : AnyObject], forState: .Normal)
        
        
        tableView.backgroundColor = UIColor.clearColor()
        searchBox.backgroundColor = UIColor.clearColor()
        
        searchBox.setImage(UIImage(named: "SearchIcon"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
  
     
    }
    
    //Check to see if User is logged in; If not, head over to login
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if (PFUser.currentUser() == nil) {
            self.performSegueWithIdentifier("login", sender: self)
        } else if (PFUser.currentUser() != nil) {
            self.storyboard?.instantiateViewControllerWithIdentifier("ViewController")
        }
    
    //Loading Indicator
        if isFirstTime {
            ProgressHUD.showSuccess("Testing")
            isFirstTime = false
        }

//        var session = PFSession()
//        if (session.sessionToken == nil) {
//            println("Error Occured")
//            PFUser.logOut()
//            self.performSegueWithIdentifier("login", sender: self)
//        }
    }
    
   
    
    //Passing Data - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            var adClass = PFObject(className: "Ad")
            let adVC: AdProfileViewController = segue.destinationViewController as! AdProfileViewController
            let indexPath = self.tableView.indexPathForSelectedRow
            adClass = adArray[indexPath!.row] as! PFObject
            adVC.adProfileModel = adClass.objectId!
            adVC.mainVC = self
            adVC.transitioningDelegate = transitionManager
        }
    }

    
    
    @IBAction func mySegmentedControlAction(sender: AnyObject) {
        if(mySegmentedControl.selectedSegmentIndex == 0)
        {
            print("Fave Segment Selected");
            favoritesView.hidden = false
            messagesView.hidden = true
            categoriesView.hidden = true
            settingsView.hidden = true
        }
        else if(mySegmentedControl.selectedSegmentIndex == 1)
        {
            print("Messages Segment Selected");
            messagesView.hidden = false
            favoritesView.hidden = true
            categoriesView.hidden = true
            settingsView.hidden = true
        }
        else if(mySegmentedControl.selectedSegmentIndex == 2)
        {
            print("Home Segment Selected");
            favoritesView.hidden = true
            messagesView.hidden = true
            categoriesView.hidden = true
            settingsView.hidden = true
            
        }
        else if(mySegmentedControl.selectedSegmentIndex == 3)
        {
            print("Categories Segment Selected")
            categoriesView.hidden = false
            favoritesView.hidden = true
            messagesView.hidden = true
            settingsView.hidden = true
        }
        else if(mySegmentedControl.selectedSegmentIndex == 4)
        {
            print("Settings Segment Selected")
            settingsView.hidden = false
            favoritesView.hidden = true
            messagesView.hidden = true
            categoriesView.hidden = true
            
        }
    }
    
   
    
    
    //UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 4
        
             return self.adArray.count
        
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let thisAd: AnyObject = adArray[indexPath.row]
        let cell:AdTableViewCell! = tableView.dequeueReusableCellWithIdentifier("AdCell") as! AdTableViewCell
        
         if indexPath==0 {
            currentUser()
            
            cell.backgroundColor = UIColor.clearColor()
            
            var adClass = PFObject(className: "Ad")
            adClass = adArray[indexPath.row] as! PFObject
            var user = PFObject(className: "User")

            cell.questionLabel.text = "What are you looking for?"
            cell.adLabel.text = "\(adClass[lookingForTitle]!)"
            cell.nameLabel.text = "\(adClass[creatorTitle]!)"
            cell.distanceLabel.text = "10 miles"
            cell.categoryLabel.setTitle("Paid Service", forState: UIControlState.Normal)
            
            
            // Get image
            let imageFile = adClass["profileImage"] as? PFFile
            imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        cell.profileImageView.image = UIImage(data:imageData)
                    } } }
            
            
            cell.delegate = self
            
            return cell

        } else {
        
        cell.backgroundColor = UIColor.clearColor()
        
        var adClass = PFObject(className: "Ad")
        adClass = adArray[indexPath.row] as! PFObject
        var user = PFObject(className: "User")
        
        cell.questionLabel.text = "What are you looking for?"
        cell.adLabel.text = "\(adClass[lookingForTitle]!)"
        //cell.distanceLabel.text = ("\(adClass[distanceTitle]!)")
        
        
        //cell.profileImageView.image = thisAd.image
        cell.nameLabel.text = "\(adClass[creatorTitle]!)"
        //cell.categoryLabel.setTitle(thisAd.category, forState: UIControlState.Normal)
        
        
        //cell.profileImageView.image = UIImage(named: "profile1")
        //cell.nameLabel.text = "Lawrence"
        //cell.questionLabel.text = "What are you looking for?"
        //cell.adLabel.text = "Looking for help moving next week!"
        cell.distanceLabel.text = "10 miles"
       cell.categoryLabel.setTitle("Paid Service", forState: UIControlState.Normal)
        
        
        // Get image
        let imageFile = adClass["profileImage"] as? PFFile
        imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    cell.profileImageView.image = UIImage(data:imageData)
                } } }
        
     
        cell.delegate = self
        
        return cell
        }
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
    
    
      performSegueWithIdentifier("showProfile", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
    }

    func adTableViewCellDidTouchCategory(cell: AdTableViewCell, sender: AnyObject) {
        // TODO: Implement Categories
    }
    
    func refreshAds() {
        
        adArray.removeAllObjects()
        //var innerQuery = PFQuery(className: "User")
        //innerQuery.whereKeyExists("name")
        let query = PFQuery(className: "Ad")
        //query.whereKey(CLASSIF_CATEGORY, equalTo: categoryStr)
        //query.whereKey("createdBy", matchesQuery: innerQuery)
        query.orderByAscending("updatedAt")
        query.limit = 30
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.adArray.addObject(object)
                    } }
                // Go to Browse Ads VC
                print("\(self.adArray.count)")
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
                
            } else {
                let alert = UIAlertView(title: "Matchboard",
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: self,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
        }
        

    }
    
    
    //Search Function Delegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String){
        if searchBar.text!.isEmpty{
            is_Searching = false
            tableView.reloadData()
        } else {
            print(" search text %@ ",searchBar.text)
            is_Searching = true
            searchingAdArray.removeAllObjects()
            for var index = 0; index < self.adArray.count; index++
           {
//                var currentString = adArray.objectAtIndex(index) as! String
//                if currentString.lowercaseString.rangeOfString(searchText.lowercaseString)  != nil {
//                    searchingAdArray.addObject(currentString)
//                    
//                }
           }
           tableView.reloadData()
        }
    }

    
   
    
    
    func currentUser() {
        adArray.removeAllObjects()
        let query = PFQuery(className: "Ad")
        query.whereKey("username", equalTo: PFUser.currentUser()!)
        //query.orderByDescending(CLASSIF_UPDATED_AT)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        self.adArray.addObject(object)
                    } }
                // Pupolate the TableView
                self.tableView.reloadData()
                
            } else {
                let alert = UIAlertView(title: "Matchboard",
                    message: "Something went wrong, try again later or check your internet connection",
                    delegate: nil,
                    cancelButtonTitle: "OK" )
                alert.show()
            }
        }

        
    }
    
    


}

