    //
//  ViewController.swift
//  Matchboard
//
//  Created by lsecrease on 3/29/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Foundation
import CoreLocation
import Atlas


class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, AdTableViewCellDelegate, LoginDelegate {

    var layerClient: LYRClient!
    let searchController = UISearchController(searchResultsController: nil)
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mySegmentedControl: UISegmentedControl!
    @IBOutlet weak var favoritesView: UIView!
    @IBOutlet weak var messagesView: UIView!
    @IBOutlet weak var categoriesView: UIView!
    @IBOutlet weak var settingsView: UIView!
   
    var messagesVC : ConversationListViewController?
    
    var isFirstTime = true
    var locationManager: CLLocationManager!
    
    var currentLocation: PFGeoPoint?
    
    var adArray: [PFObject] = []
    var myAdArray = []
    
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
    var categoriesVC: CategoryViewController?
    
    
    //MARK: - Change Status Bar to White
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            self.layerClient = appDelegate.layerClient
            messagesVC?.layerClient = self.layerClient
        }
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //searchBox.delegate = self
        /*
        locationManager = CLLocationManager()
        locationManager.delegate = self
        if locationManager.respondsToSelector("RequestAlwaysAuthorization") {
            locationManager.requestAlwaysAuthorization()
        }
        
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            // Fallback on earlier versions
        }
    */
        let myAd = AvocarrotInstream.init(controller: self, minHeightForRow: 100, tableView: tableView)
        myAd.apiKey = "229cd8a7babe7e0615b66a2ecb85f10c290ad303"
        myAd.sandbox = true
        myAd.setLogger(true, withLevel: "ALL")
        
        //myAd.loadAdForPlacement("a18ed0973f0e4b84b5e845bc596ffe4f0d500e26")
        
        //Pull to Refresh
        refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = UIColor.whiteColor()
        refreshControl.tintColor = UIColor.blueColor()
        tableView.addSubview(refreshControl)
        refreshControl?.addTarget(self, action: "pullToRefreshAds", forControlEvents: UIControlEvents.ValueChanged)
        
        mySegmentedControl.backgroundColor = MatchboardColors.NavBar.color()
        
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
        searchController.searchResultsUpdater = self
        
        self.definesPresentationContext = false
        
        //Set timer for location refresh
        
        
    }
    
    /*
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            currentLocation = PFGeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
    }
   
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        NSLog("Location manager failed with error: \(error)")
    }
    
*/
    //Check to see if User is logged in; If not, head over to login
    override func viewDidAppear(animated: Bool) {
        self.storyboard?.instantiateViewControllerWithIdentifier("ViewController")
    
        originalSearchBarHeight = searchController.searchBar.frame.height
       
        if let user = PFUser.currentUser() {
            self.loginLayer()
        } else {
            // No user found, show login page
            //self.performSegueWithIdentifier("login", sender: self)
        }
        //Loading Indicator
        if isFirstTime {
            refreshAds(nil)
            isFirstTime = false
        }
        
    }
    
    // MARK: - Navigation
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if PFUser.currentUser() == nil && identifier == "showProfile" {
            performSegueWithIdentifier("login", sender: self)
            return false
        }
        return true
    }
    
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
        } else if segue.identifier == "MessagesSegue" {
            guard let safeMessagesVC = segue.destinationViewController as? ConversationListViewController else {
                return
            }
            
            messagesVC = safeMessagesVC
            if self.layerClient != nil {
                messagesVC?.layerClient = self.layerClient
            }
        } else if segue.identifier == "CategorySegue" {
            categoriesVC = segue.destinationViewController as? CategoryViewController
        }
    }
    
    func showMessageNavButtons() {
        if let messagesVC = messagesVC, _ = PFUser.currentUser() {
            let composeItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Compose, target: messagesVC, action: Selector("composeButtonTapped:"))
            self.navigationItem.setRightBarButtonItem(composeItem, animated: false)
        }
    }
    
    func hideMessageNavButtons() {
        self.navigationItem.rightBarButtonItem = nil
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
            hideMessageNavButtons()
        }
        else if(mySegmentedControl.selectedSegmentIndex == 1)
        {
            print("Messages Segment Selected");
            messagesView.hidden = false
            favoritesView.hidden = true
            categoriesView.hidden = true
            settingsView.hidden = true
            showMessageNavButtons()
            
        }
        else if(mySegmentedControl.selectedSegmentIndex == 2)
        {
            print("Home Segment Selected");
            favoritesView.hidden = true
            messagesView.hidden = true
            categoriesView.hidden = true
            settingsView.hidden = true
            hideMessageNavButtons()
        }
        else if(mySegmentedControl.selectedSegmentIndex == 3)
        {
            print("Categories Segment Selected")
            categoriesView.hidden = false
            favoritesView.hidden = true
            messagesView.hidden = true
            settingsView.hidden = true
            hideMessageNavButtons()
        }
        else if(mySegmentedControl.selectedSegmentIndex == 4)
        {
            print("Settings Segment Selected")
            settingsView.hidden = false
            favoritesView.hidden = true
            messagesView.hidden = true
            categoriesView.hidden = true
            hideMessageNavButtons()
        }
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.distanceFilter = kCLDistanceFilterNone
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                // Fallback on earlier versions
            }
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
                            }
                        }
                    }
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
                
                var currentCLLocation :CLLocation? = nil
                if let currentLocation = currentLocation {
                    currentCLLocation = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
                }
                
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
                    if let rowGeoPoint = user.objectForKey("currentLocation") as? PFGeoPoint {
                        let userLocation = CLLocation(latitude: rowGeoPoint.latitude, longitude: rowGeoPoint.longitude)
                        if let currentCLLocation = currentCLLocation {
                            cell.distanceLabel.text = String(format: "%0.1fmi", currentCLLocation.distanceFromLocation(userLocation)/1609.344)
                        }
                    }
                    let imageFile = user[UserColumns.profileImage.rawValue] as? PFFile
                    imageFile?.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                cell.profileImageView.image = UIImage(data:imageData)
                            }
                        }
                    }
                    
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
    
    func refreshAds(var search: String?) {
        ProgressHUD.show("")
        // Near current location or default location (where?)
        PFGeoPoint.geoPointForCurrentLocationInBackground {
            (geoPoint: PFGeoPoint?, error: NSError?) in
            if error == nil {
                NSLog("currentLocation: \(geoPoint)")
                self.currentLocation = geoPoint
                if let user = PFUser.currentUser() {
                    user.setObject(geoPoint!, forKey: "currentLocation")
                    user.saveInBackground()
                }
            }
            else {
                NSLog("\(error)")
            }
            
            let userQuery = PFQuery(className: "_User")
            if let currentLocation = self.currentLocation {
                userQuery.whereKey("currentLocation", nearGeoPoint: currentLocation)
            }
            let query = PFQuery(className: "Ad")
            query.limit = 30
            query.whereKey("username", matchesQuery: userQuery)
            
            query.includeKey("username")
            
            if let search = search {
                if self.searchController.searchBar.selectedScopeButtonIndex == 0
                {
                    query.whereKey("lookingFor", containsString: search)
                } else if self.searchController.searchBar.selectedScopeButtonIndex == 1
                {
                    let aboutQuery = PFQuery(className: "_User")
                    aboutQuery.whereKey("aboutMe", containsString: search)
                    query.whereKey("username", matchesQuery: aboutQuery)
                }
            }
            
            query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
                
                let myId = PFUser.currentUser()?.objectId
                
                if error == nil {
                    self.adArray.removeAll(keepCapacity: true)
                    //self.adArray.removeAllObjects()
                    //self.myAdArray.removeAllObjects()
                    
                    if let objects = objects as? [PFObject] {
                        for object in objects {
                            if let user = object["username"] as? PFUser
                            {
                                if user.objectId == myId
                                {
                                   // self.myAdArray.addObject(object)
                                } else {
                                    self.adArray.append(object)
                                    //self.adArray.addObject(object)
                                }
                            }
                        }
                    }
                    
                    self.adArray.sortInPlace{(left, right) in
                        var leftDistance: Double = 0.0
                        var rightDistance: Double = 0.0
                        if let leftUser = left["username"] as? PFUser {
                            if let leftLocation = leftUser["currentLocation"] as? PFGeoPoint {
                                leftDistance = self.currentLocation!.distanceInMilesTo(leftLocation)
                            }
                        }
                        
                        if let rightUser = right["username"] as? PFUser {
                            if let rightLocation = rightUser["currentLocation"] as? PFGeoPoint {
                                rightDistance = self.currentLocation!.distanceInMilesTo(rightLocation)
                            }
                        }
                        
                        return leftDistance < rightDistance
                    }
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
        
       
    }

    func currentUser() {
        adArray.removeAll(keepCapacity: true)
        //adArray.removeAllObjects()
        let query = PFQuery(className: "Ad")
        query.whereKey("username", equalTo: PFUser.currentUser()!)
        //query.orderByDescending(CLASSIF_UPDATED_AT)
        query.findObjectsInBackgroundWithBlock { (objects, error)-> Void in
            if error == nil {
                if let objects = objects as? [PFObject] {
                    for object in objects as! [Ad] {
                        self.adArray.append(object)
                        //self.adArray.addObject(object)
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
            
            // log in to layer
            self.loginLayer()
        }
    }
    
    // MARK: - Layer Log In
    
    func loginLayer() {
        //SVProgressHUD.show()
        
        // Connect to Layer
        // See "Quick Start - Connect" for more details
        // https://developer.layer.com/docs/quick-start/ios#connect
        self.layerClient.connectWithCompletion { success, error in
            if (!success) {
                print("Failed to connect to Layer: \(error)")
            } else {
                let userID: String = PFUser.currentUser()!.objectId!
                // Once connected, authenticate user.
                // Check Authenticate step for authenticateLayerWithUserID source
                self.authenticateLayerWithUserID(userID, completion: { success, error in
                    if (!success) {
                        print("Failed Authenticating Layer Client with error:\(error)")
                    } else {
                        print("Authenticated")
                        //self.presentConversationListViewController()
                    }
                })
            }
        }
    }

    
    func authenticateLayerWithUserID(userID: NSString, completion: ((success: Bool , error: NSError!) -> Void)!) {
        // Check to see if the layerClient is already authenticated.
        if self.layerClient.authenticatedUserID != nil {
            // If the layerClient is authenticated with the requested userID, complete the authentication process.
            if self.layerClient.authenticatedUserID == userID {
                print("Layer Authenticated as User \(self.layerClient.authenticatedUserID)")
                if completion != nil {
                    completion(success: true, error: nil)
                }
                return
            } else {
                //If the authenticated userID is different, then deauthenticate the current client and re-authenticate with the new userID.
                self.layerClient.deauthenticateWithCompletion { (success: Bool, error: NSError!) in
                    if error != nil {
                        self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError?) in
                            if (completion != nil) {
                                completion(success: success, error: error)
                            }
                        })
                    } else {
                        if completion != nil {
                            completion(success: true, error: error)
                        }
                    }
                }
            }
        } else {
            // If the layerClient isn't already authenticated, then authenticate.
            self.authenticationTokenWithUserId(userID, completion: { (success: Bool, error: NSError!) in
                if completion != nil {
                    completion(success: success, error: error)
                }
            })
        }
    }
    
    func authenticationTokenWithUserId(userID: NSString, completion:((success: Bool, error: NSError!) -> Void)!) {
        /*
        * 1. Request an authentication Nonce from Layer
        */
        self.layerClient.requestAuthenticationNonceWithCompletion { (nonce: String!, error: NSError!) in
            if (nonce.isEmpty) {
                if (completion != nil) {
                    completion(success: false, error: error)
                }
                return
            }
            
            /*
            * 2. Acquire identity Token from Layer Identity Service
            */
            PFCloud.callFunctionInBackground("generateToken", withParameters: ["nonce": nonce, "userID": userID]) { (object:AnyObject?, error: NSError?) -> Void in
                if error == nil {
                    let identityToken = object as! String
                    self.layerClient.authenticateWithIdentityToken(identityToken) { authenticatedUserID, error in
                        if (!authenticatedUserID.isEmpty) {
                            if (completion != nil) {
                                completion(success: true, error: nil)
                            }
                            print("Layer Authenticated as User: \(authenticatedUserID)")
                        } else {
                            completion(success: false, error: error)
                        }
                    }
                } else {
                    print("Parse Cloud function failed to be called to generate token with error: \(error)")
                }
            }
        }
    }
}

