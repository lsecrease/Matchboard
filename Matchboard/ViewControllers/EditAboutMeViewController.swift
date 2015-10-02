//
//  EditAboutMeViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/2/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol EditAboutMeDelegate {
    func aboutMeSaved(aboutMeString: String)
}

class EditAboutMeViewController: UIViewController {
    
    var delegate : EditAboutMeDelegate?
    var aboutMeText = ""
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBAction func saveButtonPressed(sender: AnyObject) {
        delegate?.aboutMeSaved(aboutMeTextView.text)
    }
    
    override func viewDidLoad() {
        aboutMeTextView.text = aboutMeText
        aboutMeTextView.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        aboutMeTextView.layer.borderWidth = 1.0
    }
    
    func configureWithAboutMeText(aboutMeString: String)
    {
        aboutMeText = aboutMeString
    }
}
