//
//  LookingForCell.swift
//  Matchboard
//
//  Created by Seth Hein on 9/17/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

class LookingForCell: UITableViewCell {

    @IBOutlet weak var lookingForTextView: AutoTextView!
    @IBOutlet weak var imageView1: DesignableImageView!
    @IBOutlet weak var imageView2: DesignableImageView!
    @IBOutlet weak var imageView3: DesignableImageView!
    @IBOutlet weak var imageView4: DesignableImageView!
    
    func configureCellWithAd(currentAd : PFObject)
    {
        if let lookingFor = currentAd[AdColumns.lookingFor.rawValue] as? String {
            lookingForTextView.text = lookingFor
        }
        
        // TODO: setup images
    }
}
