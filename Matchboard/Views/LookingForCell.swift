//
//  LookingForCell.swift
//  Matchboard
//
//  
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol LookingForCellDelegate {
    func editLookingForPressed(sender: AnyObject)
    func lookingForImageUpdated(name: String, image: UIImage)
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

        lookingForEditButton.layer.cornerRadius = MatchboardUtils.cornerRadius()
        
        imageView1.layer.masksToBounds = true
        imageView2.layer.masksToBounds = true
        imageView3.layer.masksToBounds = true
        imageView4.layer.masksToBounds = true
        
        imageView1.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView2.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView3.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView4.layer.cornerRadius = MatchboardUtils.cornerRadius()
    }
    
    func configureCellWithAd(currentAd : PFObject, isMine: Bool, image01: UIImage?, image02: UIImage?, image03: UIImage?, image04: UIImage?)
    {
        lookingForEditButton.hidden = !isMine
        
        if let lookingFor = currentAd[AdColumns.lookingFor.rawValue] as? String {
            lookingForTextView.text = lookingFor
        }
        
        // setup images
        if let image01 = image01 {
            imageView1.image = image01
        } else {
            getImageWithName(AdColumns.image01.rawValue, currentAd: currentAd, imageView: imageView1)
        }

        if let image02 = image02 {
            imageView2.image = image02
        } else {
            getImageWithName(AdColumns.image02.rawValue, currentAd: currentAd, imageView: imageView2)
        }
        
        if let image03 = image03 {
            imageView3.image = image03
        } else {
            getImageWithName(AdColumns.image03.rawValue, currentAd: currentAd, imageView: imageView3)
        }
        
        if let image04 = image04 {
            imageView4.image = image04
        } else {
            getImageWithName(AdColumns.image04.rawValue, currentAd: currentAd, imageView: imageView4)
        }
    }
    
    func getImageWithName(name: String, currentAd : PFObject, imageView: DesignableImageView) {
        let file = currentAd[name]
        file?.getDataInBackgroundWithBlock({ (imageData: NSData?, error: NSError?) -> Void in
            if error == nil {
                if let imageData = imageData {
                    if let image = UIImage(data:imageData) {
                        imageView.image = image
                        self.delegate?.lookingForImageUpdated(name, image: image)
                    }
                }
            }
        })
    }
}
