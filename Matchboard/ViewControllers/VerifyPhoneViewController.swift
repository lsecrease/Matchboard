//
//  VerifyPhoneViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/20/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class VerifyPhoneViewController: UIViewController {
    
    @IBOutlet weak var verifyButton: DesignableButton!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var verifyActivityIndicator: UIActivityIndicatorView!
    
    var validationId : String?
    var dialingNumber : String?
    let service = CheckMobileServiceClient()
    
    var phoneNumber : String? {
        didSet {
            if let phoneNumber = phoneNumber
            {
                service.callService("validation", method: "request", data: ["number":"1\(phoneNumber)", "type":"cli"], httpMethod: "POST", callBack: { (data) -> Void in
                    print(data)
                    
                    if let returnId = data["id"] as? String {
                        self.validationId = returnId
                    }
                    
                    if let phoneNumber = data["dialing_number"] as? String {
                        self.dialingNumber = phoneNumber
                    }
                    
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.verifyLabel.text = "To verify your phone number, you will need to call \(self.dialingNumber!). You will hear a busy tone. Hang up, and come back to this app."
                    })
                })
            }
        }
    }
    
    var displayName : String?
    var userImage : UIImage?
    
    override func viewWillAppear(animated: Bool) {
        
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserverForName("AppDidBecomeActive", object: nil, queue: NSOperationQueue.mainQueue()) { (notification) -> Void in
            
            let defaults = NSUserDefaults.standardUserDefaults()
            if let validationProcess = defaults.objectForKey("validationProcess") as? String
            {
                if validationProcess == "validating"
                {
                    defaults.setObject("", forKey: "validationProcess")
                    defaults.synchronize()
                    self.checkIfPhoneWasValidated()
                }
            }
        }
    }
    
    override func viewDidLoad() {
    }
    
    @IBAction func verifyPressed(sender: AnyObject) {
        verifyActivityIndicator.startAnimating()
        verifyButton.enabled = false
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("validating", forKey: "validationProcess")
        defaults.synchronize()
        
        // make the phone call
        if let url = NSURL(string: "tel://\(dialingNumber!)") {
            UIApplication.sharedApplication().openURL(url)
        }
    }
    
    func checkIfPhoneWasValidated() {
        service.callService("validation", method: "status/\(validationId!)", data: nil, httpMethod: "GET", callBack: { (data) -> Void in
            print(data)
            
            if let validatedBool = data["validated"] as? Bool {
                if validatedBool == true
                {
                    self.doLogin(self.phoneNumber!, code: 0)
                } else {
                    self.showAlert("Validation Error", message: "Your phone number was not validated. Please try again.")
                    
                    self.enableVerifyButton()
                }
            }
        })
    }
    
    //*********************Login Function***********************//
    func doLogin(phoneNumber: String, code: Int) {
        self.editing = false
        let params = ["phoneNumber": phoneNumber/*, "codeEntry": code*/] as [NSObject:AnyObject]
        
        // call the send code function first
        PFCloud.callFunctionInBackground("sendCode", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            
            // get the login code
            print(response)
            
            guard let code = response?["code"] as? Int else {
                self.editing = true
                self.showAlert("Login Error", message: "Something went wrong.  Please try again.")
                self.enableVerifyButton()
                return
            }
            
            let params = ["phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
            
            
            PFCloud.callFunctionInBackground("logIn", withParameters: params) {
                (response: AnyObject?, error: NSError?) -> Void in
                if let description = error?.description {
                    self.editing = true
                    self.enableVerifyButton()
                    return self.showAlert("Login Error", message: description)
                }
                if let token = response as? String {
                    PFUser.becomeInBackground(token) { (user: PFUser?, error: NSError?) -> Void in
                        if let _ = error {
                            self.showAlert("Login Error", message: "Something happened while trying to log in.\nPlease try again.")
                            self.enableVerifyButton()
                            return
                        }
                        //**************Save Photo & Display Name*************//
                        self.savePhoto()
                        self.saveData()
                        self.performSegueWithIdentifier("welcomeSegue", sender: self)
                    }
                } else {
                    self.editing = true
                    self.showAlert("Login Error", message: "Something went wrong.  Please try again.")
                    self.enableVerifyButton()
                    return
                }
            }
        }
    }
    
    //*********************Save Photo***********************//
    func savePhoto() {
        
        let user = PFUser.currentUser()!
        guard let profilePic = self.userImage else {
            return
            
        }
        let imageData = UIImagePNGRepresentation(profilePic)!
        let profileImage = PFFile(name: "image.png", data: imageData)
        print("\(profileImage.name)")
        user["profileImage"] = profileImage
        
        user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success == false{
                self.displayAlert("Could not Save User Image", error: "Please try again later")
            } else {
                print("ProfileImage has been saved successfully!")
            }
        })
        
    }
    
    func saveData() {
        let user = PFUser.currentUser()!
        user["name"] = self.displayName
        
        user.saveInBackgroundWithBlock({ (success, error) -> Void in
            if success == false{
                self.displayAlert("Could not Save name", error: "Please try again later")
            } else {
                print("Display Name has been saved successfully!")
            }
        })
    }
    
    //**********************UI Alert**********************//
    func showAlert(title: String, message: String) {
        return UIAlertView(title: title, message: message, delegate: nil, cancelButtonTitle: "OK").show()
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
    
    func enableVerifyButton() {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.verifyButton.enabled = true
            self.verifyActivityIndicator.stopAnimating()
        })
    }
}
