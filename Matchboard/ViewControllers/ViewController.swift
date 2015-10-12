//
//  ViewController.swift
//  Matchboard
//
//  Created by lsecrease on 3/29/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit


//var AdsArray: [Ad] = []



class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, AdTableViewCellDelegate, LoginDelegate {

    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var settingsView: UIView!
   
    var isFirstTime = true
    
    var adArray = NSMutableArray()
    var myAdArray = NSMutableArray()
    
    var lookingForTitle = "lookingFor"
    var distanceTitle = "distance"
    var nameTitle = "name"
    var creatorTitle = "first_name"
    
    var originalSearchBarHeight : CGFloat!
    
    var refreshControl: UIRefreshControl!
    
    //Search stuff
    var is_Searching:Bool! = false
    var searchingAdArray:NSMutableArray!
    
    let transitionManager = TransitionManager()
    
    var favoritesVC : FavoritesViewController?
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //searchBox.delegate = self
        
        //Pull to Refresh
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.blueColor()
        tableView.addSubview(refreshControl)
        refreshControl?.addTarget(self, action: "pullToRefreshAds", forControlEvents: UIControlEvents.ValueChanged)
        
        //Segment Control Appearance
        mySegmentedControl.setDividerImage(MatchboardUtils.getImageWithColor(MatchboardColors.DarkBackground.color(), size: CGSizeMake(1.0, 1.0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setDividerImage(MatchboardUtils.getImageWithColor(MatchboardColors.DarkBackground.color(), size: CGSizeMake(1.0, 1.0)), forLeftSegmentState: UIControlState.Selected, rightSegmentState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setDividerImage(MatchboardUtils.getImageWithColor(MatchboardColors.DarkBackground.color(), size: CGSizeMake(1.0, 1.0)), forLeftSegmentState: UIControlState.Normal, rightSegmentState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setBackgroundImage(UIImage(named: "SegCtrl-selected"), forState: UIControlState.Selected, barMetrics: UIBarMetrics.Default)
        mySegmentedControl.setBackgroundImage(UIImage(named: "SegCtrl-normal"), forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)
        let attributes = [NSFontAttributeName: UIFont(name: "Avenir Next", size: 12.0)!]
        mySegmentedControl.setTitleTextAttributes(attributes, forState: .Normal)
        let selectedAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        mySegmentedControl.setTitleTextAttributes(selectedAttributes, forState: .Selected)
        
        // search controller
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        //let searchBarView = UIView()
        //searchBarView.addSubview(searchController.searchBar)
        self.tableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.sizeToFit()
        searchController.searchBar.delegate = self
        
        // other appearance
        tableView.backgroundColor = UIColor.clearColor()
        searchController.searchBar.backgroundColor = UIColor.whiteColor()
        searchController.searchBar.setImage(UIImage(named: "SearchIcon"), forSearchBarIcon: UISearchBarIcon.Search, state: UIControlState.Normal)
        searchController.searchBar.setBackgroundImage(MatchboardUtils.getImageWithColor(UIColor.whiteColor(), size: CGSizeMake(1.0, 1.0)), forBarPosition: UIBarPosition.Any, barMetrics: UIBarMetrics.Default)
        searchController.searchBar.scopeBarBackgroundImage = UIImage()
        searchController.searchBar.scopeButtonTitles = ["Ad Search", "Profile Search"]
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchResultsUpdater = self
        
        self.definesPresentationContext = false
    }
    
    //Check to see if User is logged in; If not, head over to login
    override func viewDidAppear(animated: Bool) {

        self.storyboard?.instantiateViewControllerWithIdentifier("ViewController")
    
        originalSearchBarHeight = searchController.searchBar.frame.height
        
        //Loading Indicator
        if isFirstTime {
            refreshAds(nil)
            isFirstTime = false
        }
    }
    
    //Passing Data - PrepareForSegue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showProfile" {
            var adClass = PFObject(className: "Ad")
            if let navVC = segue.destinationViewController as? UINavigationController
            {
                if let adVC  = navVC.topViewController as? AdProfileViewController
                {
                    if let indexPath = self.tableView.indexPathForSelectedRow
                    {
                        if indexPath.section == 0
                        {
                            adClass = myAdArray[indexPath.row] as! PFObject
                        } else {
                            adClass = adArray[indexPath.row] as! PFObject
                        }
                        
                        
                        adVC.adProfileModel = adClass.objectId!
                        adVC.mainVC = self
                        adVC.transitioningDelegate = transitionManager
                    }
                }
            }

        } else if segue.identifier == "login" {
            let loginVC = segue.destinationViewController as! LoginViewController
            
            loginVC.delegate = self
        } else if segue.identifier == "FavoritesSegue" {
            if let favVCObject = segue.destinationViewController as? FavoritesViewController
            {
                favoritesVC = favVCObject
            }
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
            favoritesVC?.queryFavAds()
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
        return 2
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0
        {
            return myAdArray.count
        }
        
        return adArray.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        //let thisAd: AnyObject = adArray[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier("AdCell") as? AdTableViewCell
        {
        
            if indexPath==0 {
                currentUser()
                
                cell.backgroundColor = UIColor.clearColor()
                
                var adClass = PFObject(className: "Ad")
                adClass = adArray[indexPath.row] as! PFObject
                //var user = PFObject(className: "User")
                
                cell.questionLabel.text = "What are you looking for?"
                cell.adLabel.text = "\(adClass[lookingForTitle]!)"
                cell.nameLabel.text = "\(adClass[creatorTitle]!)"
                cell.distanceLabel.text = "10 miles"
                cell.categoryLabel.setTitle("Paid Service", forState: UIControlState.Normal)
                
                
                // Get image
                if let user = adClass[AdColumns.username.rawValue] as? PFUser
                {
                    let imageFile = user[UserColumns.profileImage.rawValue] as? PFFile
                    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.profileImageView.image = UIImage(data:imageData)
                            } } }
                    
                }
                cell.delegate = self
                
                return cell
                
            } else {
                

                
                cell.backgroundColor = UIColor.clearColor()
                
                var adClass = PFObject(className: "Ad")
                if (indexPath.section == 0)
                {
                    adClass = myAdArray[indexPath.row] as! PFObject
                } else {
                    adClass = adArray[indexPath.row] as! PFObject
                }
                
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
                if let user = adClass[AdColumns.username.rawValue] as? PFUser
                {
                    let imageFile = user[UserColumns.profileImage.rawValue] as? PFFile
                    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.profileImageView.image = UIImage(data:imageData)
                            } } }
                    
                }
                
                cell.delegate = self
                
                return cell
            }
        }
        
        return UITableViewCell()
    }
    


    // MARK: - UITableViewDelegate
    
   func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: - UISearchBarDelegate

    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        refreshAds(searchBar.text)
    }
    
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        self.tableView.contentInset = UIEdgeInsetsMake(searchController.searchBar.isFirstResponder() == true ? 44.0 : 0.0, 0.0, 0.0, 0.0)
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar)
    {
        refreshAds(nil)
    }
    
    // MARK: - Custom Methods
    
    func adTableViewCellDidTouchCategory(cell: AdTableViewCell, sender: AnyObject) {
        // TODO: Implement Categories
    }
    
    func pullToRefreshAds()
    {
        refreshAds(nil)
    }
    
    func refreshAds(search: String?) {
        
        ProgressHUD.show("")
        
        let query = PFQuery(className: "Ad")
        
        query.orderByAscending("updatedAt")
        query.limit = 30
        query.includeKey("username")
        
        if let search = search {
            
            if searchController.searchBar.selectedScopeButtonIndex == 0
            {
                query.whereKey("lookingFor", containsString: search)
            } else if searchController.searchBar.selectedScopeButtonIndex == 1
            {
                let aboutQuery = PFQuery(className: "_User")
                aboutQuery.whereKey("aboutMe", containsString: search)
                query.whereKey("username", matchesQuery: aboutQuery)
            }
        }
        
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            
            let myId = PFUser.currentUser()?.objectId
            
            if error == nil {
                
                self.adArray.removeAllObjects()
                self.myAdArray.removeAllObjects()
                
                if let objects = objects as? [PFObject] {
                    for object in objects {
                        
                        if let user = object["username"] as? PFUser
                        {
                            if user.objectId == myId
                            {
                                self.myAdArray.addObject(object)
                            } else {
                                
                                self.adArray.addObject(object)
                            }
                        }
                    } }
                // Go to Browse Ads VC
                print("\(self.adArray.count)")
                self.tableView.reloadData()
                ProgressHUD.dismiss()
                self.refreshControl?.endRefreshing()
                
            } else {
                ParseErrorHandlingController.handleParseError(error!)
            }
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
                ParseErrorHandlingController.handleParseError(error!)
            }
        }
    }
    
    // MARK: - LoginDelegate
    func userLoggedIn(sender: LoginViewController) {
        sender.dismissViewControllerAnimated(true) { () -> Void in
            self.refreshAds(nil)
        }
    }
}

