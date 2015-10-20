//
//  RegisterViewController.swift
//  Matchboard
//
//  Created by lsecrease on 6/15/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var navigationLabel: UILabel!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var displayNameTextField: DesignableTextField!
    
    @IBOutlet weak var profilePhotoLabel: UILabel!
    @IBOutlet weak var nextButton: DesignableButton!
    @IBOutlet weak var imageView: UIImageView!
    
    
    let imagePicker = UIImagePickerController()
    
    var phoneNumber: String
    
    
    required init?(coder aDecoder: NSCoder) {
        phoneNumber = ""
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        phoneNumber = ""
        
        // colors and layout
        phoneNumberTextField.layer.cornerRadius = MatchboardUtils.cornerRadius()
        phoneNumberTextField.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        phoneNumberTextField.layer.borderWidth = 1.0
        
        displayNameTextField.layer.cornerRadius = MatchboardUtils.cornerRadius()
        displayNameTextField.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        displayNameTextField.layer.borderWidth = 1.0
    }
    
    override func shouldPerformSegueWithIdentifier(identifier: String, sender: AnyObject?) -> Bool {
        if identifier == "VerifyPhoneSegue"
        {
            // validation stuff
            if phoneNumberTextField.text!.characters.count != 10 {
                showAlert("Phone Login", message: "You must enter a 10-digit US phone number including area code.")
                return false
            }
            
            if displayNameTextField.text!.characters.count == 0 {
                showAlert("Display Name", message: "You must enter a display name.")
                return false
            }
        }
        
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "VerifyPhoneSegue"
        {
            if let verifyVC = segue.destinationViewController as? VerifyPhoneViewController
            {
                verifyVC.phoneNumber = phoneNumberTextField.text
                verifyVC.displayName = displayNameTextField.text
                verifyVC.userImage = imageView.image
            }
        }
    }
    
    func step1() {
        phoneNumber = ""
        nextButton.enabled = true
    }
    
    
    // todo: refactor this
    func step2() {
        phoneNumber = phoneNumberTextField.text!
        phoneNumberTextField.text = ""
        phoneNumberTextField.placeholder = "1234"
        navigationLabel.text = "Registration Verification"
        displayNameTextField.hidden = true
        profilePhotoLabel.hidden = true
        imageView.hidden = true
        nextButton.enabled = true
        nextButton.setTitle("Finish Registration", forState: .Normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loadImageButtonTapped(sender: AnyObject) {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    @IBAction func registerButtonTapped(sender: AnyObject) {
        
        
        if phoneNumber == "" {
            if phoneNumberTextField.text!.characters.count != 10 {
                showAlert("Phone Login", message: "You must enter a 10-digit US phone number including area code.")
                return step1()
            }
            ProgressHUD.show("Signing in...", interaction: false)
            self.editing = false
            
            // TODO: update to CheckMobi
            //let params = ["phoneNumber" : phoneNumberTextField.text!]
            
            //var url = NSURL(string: "https://api.checkmobi.com/v1/validation/request")
            
            
            let service = CheckMobileServiceClient()
            service.callService("validation", method: "request", data: ["number":"15734808191", "type":"cli"], callBack: { (data) -> Void in
                print(data)
            })
            // OLD TWILIO STUFF
//            PFCloud.callFunctionInBackground("sendCode", withParameters: params) {
//                (response: AnyObject?, error: NSError?) -> Void in
//                self.editing = true
//                if let error = error {
//                    var description = error.description
//                    if description.characters.count == 0 {
//                        description = "There was a problem with the service.\nTry again later."
//                    } else if let message = error.userInfo["error"] as? String {
//                        description = message
//                    }
//                    self.showAlert("Login Error", message: description)
//                    return self.step1()
//                }
//                ProgressHUD.showSuccess("Code Sent")
//                return self.step2()
//            }
        } else  {
            if let text = phoneNumberTextField?.text {
                if let code = Int(text) {
                if text.characters.count == 4 {
                    return doLogin(phoneNumber, code: code)
                }
            }
            
            showAlert("Code Entry", message: "You must enter the 4 digit code texted to your phone number.")
            }
        }
    }
    
        

    
    
    
    //*********************Login Function***********************//
    func doLogin(phoneNumber: String, code: Int) {
        self.editing = false
        let params = ["phoneNumber": phoneNumber, "codeEntry": code] as [NSObject:AnyObject]
        PFCloud.callFunctionInBackground("logIn", withParameters: params) {
            (response: AnyObject?, error: NSError?) -> Void in
            if let description = error?.description {
                self.editing = true
                return self.showAlert("Login Error", message: description)
            }
            if let token = response as? String {
                PFUser.becomeInBackground(token) { (user: PFUser?, error: NSError?) -> Void in
                    if let error = error {
                        self.showAlert("Login Error", message: "Something happened while trying to log in.\nPlease try again.")
                        self.editing = true
                        return self.step1()
                    }
                    //**************Save Photo & Display Name*************//
                    self.savePhoto()
                    self.saveData()
                    self.performSegueWithIdentifier("successSegue", sender: self)
                    //return self.dismissViewControllerAnimated(true, completion: nil)
                }
            } else {
                self.editing = true
                self.showAlert("Login Error", message: "Something went wrong.  Please try again.")
                return self.step1()
            }
        }
    }
    
    
    
    
    override func setEditing(editing: Bool, animated: Bool) {
        nextButton.enabled = editing
        phoneNumberTextField.enabled = editing
        if editing {
            phoneNumberTextField.becomeFirstResponder()
        }
    }
    
    
     //*********************Save Photo***********************//
    func savePhoto() {
        
                let user = PFUser.currentUser()!
               let profilePic = self.imageView.image!
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
        let name = self.displayNameTextField.text
        print("\(name)")
        user["name"] = name
        
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
    
    //**********************Dismisses Keyboard when View Touched*********//
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.endEditing(true)
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

    
    //***********************UIImagePickerController Delegates***********//
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}

