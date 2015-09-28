//
//  BioCell.swift
//  Matchboard
//
//  Created by Seth Hein on 9/16/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit

protocol BioCellDelegate
{
    func messageButtonPressed(sender: AnyObject)
    func favoriteButtonPressed(sender: AnyObject)
}

class BioCell: UITableViewCell {

    var delegate : BioCellDelegate!
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var favoriteButton: DesignableButton!
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    @IBAction func messageButtonPressed(sender: AnyObject) {
        delegate.messageButtonPressed(sender)
    }

    @IBAction func favoriteButtonPressed(sender: AnyObject) {
        delegate.favoriteButtonPressed(sender)
        
        if favoriteImageView.tintColor != UIColor.yellowColor()
        {
            favoriteImageView.tintColor = UIColor.yellowColor()
        } else {
            favoriteImageView.tintColor = UIColor.whiteColor()
        }
    }
    
    func configureCellWithAd(currentAd : PFObject, isFavorite : Bool)
    {
        if let name = currentAd[AdColumns.firstName.rawValue] as? String {
            nameLabel.text = name
        }
        
        // TODO: add location
        
        // TODO: add gender
        
        // TODO: add age
        
        // Profile Image
        favoriteImageView.tintColor = isFavorite ? UIColor.yellowColor() : UIColor.whiteColor()
        favoriteImageView.image = favoriteImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        
        if let profilePic = currentAd[AdColumns.profileImage.rawValue] as? PFFile
        {
            profilePic.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.profileImageView.image = UIImage(data: imageData)
                    }
                }
            }
        }
    }
}
