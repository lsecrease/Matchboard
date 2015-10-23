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
    
    var phoneNumber: String = ""
    
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
        
        imageView.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        imageView.layer.borderWidth = 1.0
        imageView.layer.masksToBounds = true
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func cancelButtonPressed(sender: AnyObject) {
        navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func loadImageButtonTapped(sender: AnyObject) {
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .PhotoLibrary
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    override func setEditing(editing: Bool, animated: Bool) {
        nextButton.enabled = editing
        phoneNumberTextField.enabled = editing
        if editing {
            phoneNumberTextField.becomeFirstResponder()
        }
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
        if let pickedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }


}

