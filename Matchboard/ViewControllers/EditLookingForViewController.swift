//
//  EditLookingForViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/5/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol EditLookingForDelegate
{
    func lookingForSaved(sender: AnyObject, classifiedString: String, lookingForString: String, images: [UIImage]?)
    func lookingForCancelled(sender: AnyObject)
}

class EditLookingForViewController: UIViewController {

    var delegate : EditLookingForDelegate?
    
    @IBOutlet weak var lookingForTextView: UITextView!
    @IBOutlet weak var classifiedField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.lookingForCancelled(navigationController!)
    }
    @IBAction func saveButtonPressed(sender: AnyObject) {
        delegate?.lookingForSaved(navigationController!, classifiedString: classifiedField.text!, lookingForString: lookingForTextView.text!, images: [])
    }
}
