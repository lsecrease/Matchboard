//
//  EditProfileViewController.swift
//  Matchboard
//
// 
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    func profileSaved(sender: AnyObject, displayName: String, city: String, state: String, age: Int)
    func profileCancelled(sender: AnyObject)
}

class EditProfileViewController: UIViewController {
    var delegate : EditProfileDelegate?
    
    var displayName = ""
    var city = ""
    var state = ""
    var age = 0
    
    override func viewDidLoad() {
//        displayNameField.text = displayName
//        cityField.text = city
//        stateField.text = state
//        ageField.text = "\(age)"
        
        if let user = PFUser.currentUser() {
            if let displayName = user[UserColumns.name.rawValue] as? String {
                displayNameField.text = displayName
            }
            
            if let city = user[UserColumns.city.rawValue] as? String {
                cityField.text = city
            }
            
            if let state = user[UserColumns.state.rawValue] as? String {
                stateField.text = state
            }
            
            if let age = user[UserColumns.age.rawValue] as? Int {
                ageField.text = "\(age)"
            }
        }
    }
    
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var cityField: UITextField!
    @IBOutlet weak var stateField: UITextField!
    @IBOutlet weak var ageField: UITextField!
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.profileCancelled(navigationController!)
    }
    
    @IBAction func textFieldDidEndOnExit(sender: AnyObject) {
        if let textField = sender as? UITextField {
            if textField == displayNameField {
                cityField.becomeFirstResponder()
            } else if textField == cityField {
                stateField.becomeFirstResponder()
            } else if textField == stateField {
                ageField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if let ageString = ageField.text {
            if let ageInt = Int(ageString) {
                
                if let user = PFUser.currentUser() {
                    
                    user[UserColumns.name.rawValue] = displayNameField.text
                    user[UserColumns.city.rawValue] = cityField.text
                    user[UserColumns.state.rawValue] = stateField.text
                    if let ageString = ageField.text {
                        user[UserColumns.age.rawValue] = Int(ageString)
                    }
                    
                    user.saveInBackgroundWithBlock({ (_, _) -> Void in
                        self.delegate?.profileSaved(self.navigationController!, displayName: self.displayNameField.text!, city: self.cityField.text!, state: self.stateField.text!, age: ageInt)
                    })
                }
            }
        } else {
            // TODO: some kind of validation error
        }
    }
}
