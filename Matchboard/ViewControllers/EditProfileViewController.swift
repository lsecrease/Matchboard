//
//  EditProfileViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/2/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol EditProfileDelegate {
    func profileSaved(sender: AnyObject, displayName: String, city: String, state: String, neighborhood: String, age: Int)
    func profileCancelled(sender: AnyObject)
}

class EditProfileViewController: UIViewController {
    var delegate : EditProfileDelegate?
    
    var displayName = ""
    var city = ""
    var state = ""
    var neighborhood = ""
    var age = 0
    
    override func viewDidLoad() {
        displayNameField.text = displayName
        cityField.text = city
        stateField.text = state
        neighborhoodField.text = neighborhood
        ageField.text = "\(age)"
    }
    
    @IBOutlet weak var displayNameField: JVFloatLabeledTextField!
    @IBOutlet weak var cityField: JVFloatLabeledTextField!
    @IBOutlet weak var stateField: JVFloatLabeledTextField!
    @IBOutlet weak var neighborhoodField: JVFloatLabeledTextField!
    @IBOutlet weak var ageField: JVFloatLabeledTextField!
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.profileCancelled(navigationController!)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        if let ageString = ageField.text {
            if let ageInt = Int(ageString) {
                delegate?.profileSaved(navigationController!, displayName: displayNameField.text!, city: cityField.text!, state: stateField.text!, neighborhood: neighborhoodField.text!, age: ageInt)
            }
        } else {
            // TODO: some kind of validation error
        }
    }
}
