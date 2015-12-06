//
//  EditAboutMeViewController.swift
//  Matchboard
//
// 
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol EditAboutMeDelegate {
    func aboutMeSaved(sender: AnyObject, aboutMeString: String)
    func aboutMeCancelled(sender: AnyObject)
}

class EditAboutMeViewController: UIViewController {
    
    var delegate : EditAboutMeDelegate?
    var aboutMeText = ""
    
    @IBOutlet weak var aboutMeTextView: UITextView!
    @IBAction func saveButtonPressed(sender: AnyObject) {
        delegate?.aboutMeSaved(navigationController!, aboutMeString: aboutMeTextView.text)
    }
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.aboutMeCancelled(navigationController!)
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
