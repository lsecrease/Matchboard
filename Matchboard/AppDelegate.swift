//
//  AppDelegate.swift
//  Matchboard
//
//  Created by lsecrease on 3/29/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit
import Parse
import Atlas
import SVProgressHUD
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var layerClient: LYRClient!
    
    // MARK TODO: Before first launch, update LayerAppIDString, ParseAppIDString or ParseClientKeyString values
    // TODO:If LayerAppIDString, ParseAppIDString or ParseClientKeyString are not set, this app will crash"
    let LayerAppIDString: NSURL! = NSURL(string: "layer:///apps/staging/f80e0118-5774-11e5-9c56-e22600005d8e")
    let ParseAppIDString: String = "lsaVahwTjwKvPegYQq9hubP8rj3PfuLSDmIgfpQm"
    let ParseClientKeyString: String = "DFcnbl7hCbht7haLXjWFAmiuLKcvdwXfT3lOy353"
    
    //Please note, You must set `LYRConversation *conversation` as a property of the ViewController.
    var conversation: LYRConversation!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        setupParseAndFB(application, launchOptions: launchOptions)
        setupLayer()
        
        // TODO: pass off the layer client somewhere
        
        // Register for push
        self.registerApplicationForPushNotifications(application)
        
        UINavigationBar.appearance().setBackgroundImage(MatchboardUtils.getImageWithColor(MatchboardColors.NavBar.color(), size: CGSizeMake(1.0, 1.0)), forBarMetrics: .Default)
        UINavigationBar.appearance().backgroundColor = UIColor.clearColor()
        UINavigationBar.appearance().translucent = false
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        


        return true
    }
    
    func application(application: UIApplication,
        openURL url: NSURL,
        sourceApplication: String?,
        annotation: AnyObject) -> Bool {
            return FBSDKApplicationDelegate.sharedInstance().application(application,
                openURL: url,
                sourceApplication: sourceApplication,
                annotation: annotation)
    }
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        let notificationCenter = NSNotificationCenter.defaultCenter()
        
        notificationCenter.postNotificationName("AppDidBecomeActive", object: nil)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // Mark - Push Notification methods
    
    func registerApplicationForPushNotifications(application: UIApplication) {
        // Set up push notifications
        // For more information about Push, check out:
        // https://developer.layer.com/docs/guides/ios#push-notification
        
        // Register device for iOS8
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            if error != nil {
                print("didRegisterForRemoteNotificationsWithDeviceToken")
                print(error)
            }
        }
        
        // Send device token to Layer so Layer can send pushes to this device.
        // For more information about Push, check out:
        // https://developer.layer.com/docs/ios/guides#push-notification
        assert(self.layerClient != nil, "The Layer client has not been initialized!")
        do {
            try self.layerClient.updateRemoteNotificationDeviceToken(deviceToken)
            print("Application did register for remote notifications: \(deviceToken)")
        } catch let error as NSError {
            print("Failed updating device token with error: \(error)")
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if userInfo["layer"] == nil {
            PFPush.handlePush(userInfo)
            completionHandler(UIBackgroundFetchResult.NewData)
            return
        }
        
        let userTappedRemoteNotification: Bool = application.applicationState == UIApplicationState.Inactive
        var conversation: LYRConversation? = nil
        if userTappedRemoteNotification {
            SVProgressHUD.show()
            conversation = self.conversationFromRemoteNotification(userInfo)
            if conversation != nil {
                self.navigateToViewForConversation(conversation!)
            }
        }
        
        let success: Bool = self.layerClient.synchronizeWithRemoteNotification(userInfo, completion: { (changes, error) in
            completionHandler(self.getBackgroundFetchResult(changes, error: error))
            
            if userTappedRemoteNotification && conversation == nil {
                // Try navigating once the synchronization completed
                self.navigateToViewForConversation(self.conversationFromRemoteNotification(userInfo))
            }
        })
        
        if !success {
            // This should not happen?
            completionHandler(UIBackgroundFetchResult.NoData)
        }
    }
    
    func getBackgroundFetchResult(changes: [AnyObject]!, error: NSError!) -> UIBackgroundFetchResult {
        if changes?.count > 0 {
            return UIBackgroundFetchResult.NewData
        }
        return error != nil ? UIBackgroundFetchResult.Failed : UIBackgroundFetchResult.NoData
    }
    
    func conversationFromRemoteNotification(remoteNotification: [NSObject : AnyObject]) -> LYRConversation {
        let layerMap = remoteNotification["layer"] as! [String: String]
        let conversationIdentifier = NSURL(string: layerMap["conversation_identifier"]!)
        return self.existingConversationForIdentifier(conversationIdentifier!)!
    }
    
    func navigateToViewForConversation(conversation: LYRConversation) {
        // navigate to conversation view
        
        print("navigate to conversation view")
        
        let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        let navVC = appDelegate?.window!.rootViewController as? UINavigationController
        if navVC?.viewControllers.count > 1 {
            navVC?.popToRootViewControllerAnimated(true)
        }
        
        if let viewController = navVC?.viewControllers[0] as? ViewController {
            if viewController.messagesVC != nil {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    SVProgressHUD.dismiss()
                    
                    if (viewController.navigationController!.topViewController as? ConversationViewController)?.conversation != conversation {
                        viewController.messagesVC?.presentConversation(conversation)
                    }
                });
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func existingConversationForIdentifier(identifier: NSURL) -> LYRConversation? {
        let query: LYRQuery = LYRQuery(queryableClass: LYRConversation.self)
        query.predicate = LYRPredicate(property: "identifier", predicateOperator: LYRPredicateOperator.IsEqualTo, value: identifier)
        query.limit = 1
        do {
            return try self.layerClient.executeQuery(query).firstObject as? LYRConversation
        } catch {
            // This should never happen?
            return nil
        }
    }

    // MARK: - Setup Methods

    func setupLayer() {
        layerClient = LYRClient(appID: LayerAppIDString)
        layerClient.autodownloadMIMETypes = NSSet(objects: ATLMIMETypeImagePNG, ATLMIMETypeImageJPEG, ATLMIMETypeImageJPEGPreview, ATLMIMETypeImageGIF, ATLMIMETypeImageGIFPreview, ATLMIMETypeLocation) as! Set<NSObject>
    }
    
    func setupParseAndFB(application: UIApplication, launchOptions: [NSObject: AnyObject]?) {
        Parse.enableLocalDatastore()
        Parse.setApplicationId(ParseAppIDString, clientKey:ParseClientKeyString)
        PFSession.getCurrentSessionInBackgroundWithBlock { (session, error) -> Void in
            if let error = error
            {
                ParseErrorHandlingController.handleParseError(error)
            }
        }
        
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }

}

