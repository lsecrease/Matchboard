//
//  SettingsViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 12/20/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, EditProfileDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditProfileSegue" {
            if let navVC = segue.destinationViewController as? UINavigationController {
                if let editProfileVC = navVC.topViewController as? EditProfileViewController {
                    editProfileVC.delegate = self
                }
            }
        }
    }
    
    // MARK: - EditProfileDelegate
    
    func profileSaved(sender: AnyObject, displayName: String, city: String, state: String, age: Int) {
        sender.dismissViewControllerAnimated(true, completion: nil)
    }
    func profileCancelled(sender: AnyObject) {
        sender.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func deletePressed(sender: AnyObject) {
        
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to delete your account? This is not reversible.", preferredStyle: .Alert)
        
        let okayAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK action"), style: .Default) { (_) -> Void in
            if let userId = PFUser.currentUser()?.objectId {
                PFCloud.callFunctionInBackground("deleteUser", withParameters: ["userId":userId], block: { (_, let error) -> Void in
                    if (error == nil) {
                        PFUser.logOut()
                        self.alert("Success", message: "Your account and all ads and favorites have been deleted from our servers. We're sorry to see you go.")
                    } else {
                        self.alert("Error", message: "There was an error deleting your account. Try again?")
                    }
                })
            }
        }
        
        alertController.addAction(okayAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
