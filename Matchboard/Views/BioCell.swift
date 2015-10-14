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
    func avatarEditButtonPressed(sender: AnyObject)
    func profileEditButtonPressed(sender: AnyObject)
}

class BioCell: UITableViewCell {

    var delegate : BioCellDelegate!
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var favoriteButton: DesignableButton!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var profileEditButton: UIButton!
    @IBOutlet weak var avatarEditButton: UIButton!
    
    override func layoutSubviews() {
        avatarEditButton.setImage(avatarEditButton.imageView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        profileEditButton.setImage(profileEditButton.imageView!.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        
        avatarEditButton.layer.cornerRadius = 3.0
        profileEditButton.layer.cornerRadius = 3.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.cornerRadius = 3.0
    }
    
    // MARK: - Actions
    
    @IBAction func profileEditButtonPressed(sender: AnyObject) {
        delegate.profileEditButtonPressed(sender)
    }
    
    @IBAction func avatarEditButtonPressed(sender: AnyObject) {
        delegate.avatarEditButtonPressed(sender)
    }
    
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
    
    // MARK: - Custom Methods
    
    func configureCellWithAd(currentAd : PFObject, isFavorite : Bool, isMine : Bool)
    {
        avatarEditButton.hidden = (isMine == false)
        profileEditButton.hidden = (isMine == false)
        
        if let name = currentAd[AdColumns.firstName.rawValue] as? String {
            nameLabel.text = name
        }
        
        if let user = currentAd[AdColumns.username.rawValue] as? PFObject
        {
            var locationString = ""
            
            if let city = user[UserColumns.city.rawValue] as? String {
                if locationString.length > 0
                {
                    locationString += ", "
                }
                
                locationString += "\(city)"
            }
            
            if let state = user[UserColumns.state.rawValue] as? String {
                if locationString.length > 0
                {
                    locationString += ", "
                }
                
                locationString += "\(state)"
            }
            
            locationLabel.text = locationString
            
            if let age = user[UserColumns.age.rawValue] as? Int {
                ageLabel.text = "\(age)"
            }
        }
        
        // TODO: add gender
        
        // Profile Image
        favoriteImageView.tintColor = isFavorite ? UIColor.yellowColor() : UIColor.whiteColor()
        favoriteImageView.image = favoriteImageView.image?.imageWithRenderingMode(.AlwaysTemplate)
        
        if let user = currentAd[AdColumns.username.rawValue] as? PFUser
        {
        
            if let profilePic = user[UserColumns.profileImage.rawValue] as? PFFile
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
}
