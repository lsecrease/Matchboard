//
//  AboutMeCell.swift
//  Matchboard
//
//  Created by Seth Hein on 9/17/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class AboutMeCell: UITableViewCell {

    @IBOutlet weak var aboutMeTextView: AutoTextView!
    
    func configureCellWithAd(currentAd : PFObject)
    {
        // TODO: setup text
        if let user = currentAd[AdColumns.username.rawValue] as? PFObject
        {
            if let aboutMe = user[UserColumns.aboutMe.rawValue] as? String {
                aboutMeTextView.text = aboutMe
            }
            
        }
    }
}
