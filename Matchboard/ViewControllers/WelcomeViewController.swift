//
//  WelcomeViewController.swift
//  Matchboard
//
//  Created by lsecrease on 6/15/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController, UITextViewDelegate, UIAlertViewDelegate {

    @IBOutlet weak var adTextView: UITextView!
    
    @IBOutlet weak var charRemainingLabel: UILabel!
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    
    @IBOutlet weak var label3: UILabel!
    
    @IBOutlet weak var label4: UILabel!
    
    @IBOutlet weak var textView1: UITextView!
    @IBOutlet weak var textView2: UITextView!
    @IBOutlet weak var textView3: UITextView!
    
    
    let user = PFUser.currentUser()
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        adTextView.delegate = self
    
        
    }

    @IBAction func nextButtonTapped(sender: AnyObject) {
        print("Next Button Tapped")
        
        let lookingFor = PFObject(className:"Ad")
        let user = PFUser.currentUser()!
        lookingFor["lookingFor"] = adTextView.text
        lookingFor["username"] = PFUser.currentUser()
        if let fullname = PFUser.currentUser()!.username {
            lookingFor["createdBy"] = fullname
            
            // get first name of user
            let fullname_arr = fullname.componentsSeparatedByString(" ")
            lookingFor["first_name"] = fullname_arr.first ?? "n/a"
        }
        
        lookingFor["profileImage"] = user["profileImage"]
        lookingFor.saveInBackgroundWithBlock {
            (success: Bool, error: NSError?) -> Void in
            if (success) {
                print("Looking For has been saved!")
                self.performSegueWithIdentifier("welcomeToCategorySegue", sender: self)
            } else {
                print("There was a problem saving")
                self.displayAlert("Could not Save Looking For", error: "Please try again later")
            }
        }
//        user["lookingFor"] = adTextView.text
//        
//        user.saveInBackgroundWithBlock({ (success, error) -> Void in
//            if success == false{
//                self.displayAlert("Could not Save Looking For", error: "Please try again later")
//            } else {
//                println("Looking For has been saved successfully!")
//            }
//        })
    }
   
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!)
    {
        if segue.identifier == "welcomeToCategorySegue"
        {
            let targetVC = segue.destinationViewController as! CategoryViewController
            targetVC.fromWelcomeVC = true
        }
    }

    
    @IBAction func skipButtonTapped(sender: AnyObject) {
        print("Skip Button Tapped")
        ProgressHUD.showSuccess("We’ll fill in your profile to say you’re “Just Browsing” and classify it as such. Now have fun browsing!", interaction: true)
        //displayAlert("Skip It Then!", error: "We’ll fill in your profile to say you’re “Just Browsing” and classify it as such. Now have fun browsing!")
        self.performSegueWithIdentifier("adSegue", sender: self)
       
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
    }
    
    func textViewDidBeginEditing(view: UITextView) {
        label3.hidden = true
        label4.hidden = true
        textView1.hidden = true
        textView2.hidden = true
        textView3.hidden = true
    }
    
    func textViewDidEndEditing(view: UITextView) {
        label3.hidden = false
        label4.hidden = false
        textView1.hidden = false
        textView2.hidden = false
        textView3.hidden = false
    }
    
    // **************** FUNCTION: Send Error Alert ****************************
    func displayAlert(title: String, error: String) {
        // add alert
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertControllerStyle.Alert)
        // add action to alert
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { action in
            self.dismissViewControllerAnimated(true, completion: nil)
        }))
        //show alert
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    // **************** FUNCTION: Text Remaining ****************************
    func textView(textView: UITextField!,
         shouldChangeCharactersInRange range: NSRange,
        replacementText text: String!) -> Bool{
            let newLength:Int = textView.text!.characters.count + text.characters.count - range.length
            let remainingChar:Int = 100 - newLength
            
            charRemainingLabel.text = "\(remainingChar)"
            
            return (newLength > 100) ? false : true
    }


}
