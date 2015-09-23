//
//  LoginViewController.swift
//  Matchboard
//
//  Created by lsecrease on 6/4/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

protocol LoginDelegate {
    func userLoggedIn(sender: LoginViewController)
}

class LoginViewController: UIViewController {

    var delegate : LoginDelegate!
   
    @IBOutlet weak var loginView: DesignableView!
    
    @IBOutlet weak var phoneNumberButton: SpringButton!
    
    @IBOutlet weak var facebookButton: SpringButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func phoneRegisterButtonTapped(sender: SpringButton) {
        
        print("Phone Number Button Tapped")
        phoneNumberButton.animation = "pop"
        phoneNumberButton.animate()
        self.performSegueWithIdentifier("phoneSegue", sender: self)
    }
    
    @IBAction func facebookRegisterButtonTapped(sender: SpringButton) {
        
        print("Facebook Button Tapped")
        facebookButton.animation = "pop"
        facebookButton.animate()
        ProgressHUD.show("Signing in...", interaction: false)
        let permissions = [ "public_profile", "email", "user_friends" ]
        
        
        
        PFFacebookUtils.logInInBackgroundWithReadPermissions(permissions,  block: {  (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                    self.performSegueWithIdentifier("welcomeSegue", sender: self)
                    self.collectFacebook()
                    

                } else {
                    print("User logged in through Facebook!")
                    self.userLoggedIn(user)
                }
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
                ProgressHUD.dismiss()
            }
        })
    }
    
    func userLoggedIn(user: PFUser) {
        ProgressHUD.showSuccess("Welcome Back!")
        delegate.userLoggedIn(self)
    }
    

    override func viewDidAppear(animated: Bool) {
        if PFUser.currentUser() != nil {
            delegate.userLoggedIn(self)
        }
    }
    
    func collectFacebook() {
        var user =  PFUser.currentUser()!
        
        // -------------------- Load and save user Information -------------------------------------
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            if ((error) != nil)
            {
                // Process error
                print("Error: \(error)")
            }
            else
            {
                if let userName: NSString = result.valueForKey("name") as? NSString {
                    print("User Name is: \(userName)")
                    user["username"] = userName
                } else {print("No username fetched")}
                if let firstName : NSString = result.valueForKey("first_name") as? NSString {
                    print("First Name is: \(firstName)")
                    user["name"] = firstName
                } else {print("No first name fetched")}
                if let userEmail : NSString = result.valueForKey("email") as? NSString {
                    print("User Email is: \(userEmail)")
                    user["email"] = userEmail
                } else  {print("No email address fetched")}
                if let userGender : NSString = result.valueForKey("gender") as? NSString {
                    print("User Gender is: \(userGender)")
                    user["gender"] = userGender
                } else {print("No gender fetched") }
                
                user.saveInBackgroundWithBlock({ (success, error) -> Void in
                    if success == false{
                        self.displayAlert("Could not Save User Info", error: "Please try again later")
                    } else {
                        print("User Information has been saved successfully!")
                    }
                })
            }
        })
        
        // ------------------- Load and Save user Profile Picture  -------------------------------
        let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
        pictureRequest.startWithCompletionHandler({
            (connection, result, error: NSError!) -> Void in
            if error == nil {
                if let profilePicURL : String  = (result.valueForKey("data")!).valueForKey("url") as? String {
                    //println("The profile picture url is: \(profilePicURL)")
                    
                    let url = NSURL(string: profilePicURL)
                    let urlRequest = NSURLRequest(URL: url!)
                    NSURLConnection.sendAsynchronousRequest(urlRequest, queue: NSOperationQueue.mainQueue(), completionHandler: {
                        (response, data, error) in
                        
                        let image = UIImage(data: data!)
                        //self.profilePic.image = image
                        print( "Success")
                        
                        
                        // ------------------ save image as png in Parse --------------------
                        let imageData = UIImagePNGRepresentation(image!)
                        let imageFile = PFFile(name: "image.png", data: imageData!)
                        user["profileImage"] = imageFile
                        
                        user.saveInBackgroundWithBlock({ (success, error) -> Void in
                            if success == false{
                                self.displayAlert("Could not Save User Image", error: "Please try again later")
                            } else {
                                print("ProfileImage has been saved successfully!")
                            }
                        })
                    })
                } else { print("No profile pic URL fetched") }
            } else {
                print("\(error)")
            }
        })

        
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


}


