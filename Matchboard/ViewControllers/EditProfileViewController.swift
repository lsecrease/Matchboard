//
//  EditProfileViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/2/15.
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
        displayNameField.text = displayName
        cityField.text = city
        stateField.text = state
        ageField.text = "\(age)"
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
                delegate?.profileSaved(navigationController!, displayName: displayNameField.text!, city: cityField.text!, state: stateField.text!, age: ageInt)
            }
        } else {
            // TODO: some kind of validation error
        }
    }
}
