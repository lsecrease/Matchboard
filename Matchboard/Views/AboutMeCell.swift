//
//  AboutMeCell.swift
//  Matchboard
//
//  Created by Seth Hein on 9/17/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol AboutMeCellDelegate {
    func aboutEditButtonPressed(sender: AnyObject)
}

class AboutMeCell: UITableViewCell {

    var delegate : AboutMeCellDelegate!
    
    @IBOutlet weak var aboutMeTextView: AutoTextView!
    @IBOutlet weak var aboutEditButton: UIButton!
    
    @IBAction func aboutEditButtonPressed(sender: AnyObject) {
        delegate.aboutEditButtonPressed(sender)
    }
    
    override func layoutSubviews() {
        aboutEditButton.setImage(aboutEditButton.imageView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        
        aboutEditButton.layer.cornerRadius = 3.0
    }
    
    func configureCellWithAd(currentAd : PFObject, isMine : Bool)
    {
        aboutEditButton.hidden = !isMine
        
        // setup text
        if let user = currentAd[AdColumns.username.rawValue] as? PFObject
        {
            if let aboutMe = user[UserColumns.aboutMe.rawValue] as? String {
                aboutMeTextView.text = aboutMe
            }
            
        }
    }
}
