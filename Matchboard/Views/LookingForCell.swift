//
//  LookingForCell.swift
//  Matchboard
//
//  Created by Seth Hein on 9/17/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol LookingForCellDelegate {
    func editLookingForPressed(sender: AnyObject)
}

class LookingForCell: UITableViewCell {
    
    var delegate : LookingForCellDelegate!
    
    @IBOutlet weak var lookingForTextView: AutoTextView!
    @IBOutlet weak var imageView1: DesignableImageView!
    @IBOutlet weak var imageView2: DesignableImageView!
    @IBOutlet weak var imageView3: DesignableImageView!
    @IBOutlet weak var imageView4: DesignableImageView!
    @IBOutlet weak var lookingForEditButton: UIButton!
    
    @IBAction func lookingForEditButtonPressed(sender: AnyObject) {
        delegate.editLookingForPressed(sender)
    }
    
    override func layoutSubviews() {
        lookingForEditButton.setImage(lookingForEditButton.imageView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)

        lookingForEditButton.layer.cornerRadius = 3.0
    }
    
    func configureCellWithAd(currentAd : PFObject, isMine: Bool)
    {
        lookingForEditButton.hidden = !isMine
        
        if let lookingFor = currentAd[AdColumns.lookingFor.rawValue] as? String {
            lookingForTextView.text = lookingFor
        }
        
        // TODO: setup images
    }
}
