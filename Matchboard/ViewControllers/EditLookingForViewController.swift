//
//  EditLookingForViewController.swift
//  Matchboard
//
//  Created by Seth Hein on 10/5/15.
//  Copyright © 2015 ImagineME. All rights reserved.
//

import UIKit
import MobileCoreServices

protocol EditLookingForDelegate
{
    func lookingForSaved(sender: AnyObject, classifiedString: String, lookingForString: String, image01: UIImage?, image02: UIImage?, image03: UIImage?, image04: UIImage?)
    func lookingForCancelled(sender: AnyObject)
    func lookingForImageUpdated(name: String, image: UIImage)
}

class EditLookingForViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    var delegate : EditLookingForDelegate?
    var imageButtonPressed = 0
    
    var imageFile01 : PFFile?
    var imageFile02 : PFFile?
    var imageFile03 : PFFile?
    var imageFile04 : PFFile?
    
    var image01 : UIImage?
    var image02 : UIImage?
    var image03 : UIImage?
    var image04 : UIImage?
    
    var lookingForString = ""
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView1: DesignableImageView!
    @IBOutlet weak var imageView2: DesignableImageView!
    @IBOutlet weak var imageView3: DesignableImageView!
    @IBOutlet weak var imageView4: DesignableImageView!
    @IBOutlet weak var imageButton1: UIButton!
    @IBOutlet weak var imageButton2: UIButton!
    @IBOutlet weak var imageButton3: UIButton!
    @IBOutlet weak var imageButton4: UIButton!
    @IBOutlet weak var lookingForTextView: UITextView!
    @IBOutlet weak var classifiedField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    override func viewWillAppear(animated: Bool) {

        imageView1.layer.masksToBounds = true
        imageView2.layer.masksToBounds = true
        imageView3.layer.masksToBounds = true
        imageView4.layer.masksToBounds = true
        
        imageView1.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView2.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView3.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageView4.layer.cornerRadius = MatchboardUtils.cornerRadius()
        
        imageButton1.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageButton2.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageButton3.layer.cornerRadius = MatchboardUtils.cornerRadius()
        imageButton4.layer.cornerRadius = MatchboardUtils.cornerRadius()
        
        saveButton.layer.cornerRadius = MatchboardUtils.cornerRadius()
        
        lookingForTextView.layer.cornerRadius = MatchboardUtils.cornerRadius()
        lookingForTextView.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        lookingForTextView.layer.borderWidth = 1.0
        
        classifiedField.layer.cornerRadius = MatchboardUtils.cornerRadius()
        classifiedField.layer.borderColor = MatchboardColors.FieldBorder.color().CGColor
        classifiedField.layer.borderWidth = 1.0
        
        imageButton1.setImage(imageButton1.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        imageButton2.setImage(imageButton1.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        imageButton3.setImage(imageButton1.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        imageButton4.setImage(imageButton1.imageView?.image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate), forState: UIControlState.Normal)
        
        if let image01 = image01 {
            imageView1.image = image01
        } else {
            getImageWithName(AdColumns.image01.rawValue, file:imageFile01, imageView: imageView1)
        }
        
        if let image02 = image02 {
            imageView2.image = image02
        } else {
            getImageWithName(AdColumns.image02.rawValue, file:imageFile02, imageView: imageView2)
        }
        
        if let image03 = image03 {
            imageView3.image = image03
        } else {
            getImageWithName(AdColumns.image03.rawValue, file:imageFile03, imageView: imageView3)
        }
        
        if let image04 = image04 {
            imageView4.image = image04
        } else {
            getImageWithName(AdColumns.image04.rawValue, file:imageFile04, imageView: imageView4)
        }
        
        lookingForTextView.text = lookingForString
    }
    
    // MARK: - Actions
    
    @IBAction func cancelButtonPressed(sender: AnyObject) {
        delegate?.lookingForCancelled(navigationController!)
    }
    
    @IBAction func saveButtonPressed(sender: AnyObject) {
        delegate?.lookingForSaved(navigationController!, classifiedString: classifiedField.text!, lookingForString: lookingForTextView.text!, image01: imageView1.image, image02: imageView2.image, image03: imageView3.image, image04: imageView4.image)
    }
    
    @IBAction func cameraButtonPressed(sender: AnyObject) {
        
        if let imageButton = sender as? UIButton {
            if imageButton == imageButton1 {
                imageButtonPressed = 1
            } else if imageButton == imageButton2 {
                imageButtonPressed = 2
            } else if imageButton == imageButton3 {
                imageButtonPressed = 3
            } else if imageButton == imageButton4 {
                imageButtonPressed = 4
            }
        }
        
        // TODO: do action sheet to pick camera or photo library
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.mediaTypes = [kUTTypeImage as String]
            imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            
            self.presentViewController(imagePicker, animated: true, completion: nil)
        }
    }
    
    // MARK: - ImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {

        picker.dismissViewControllerAnimated(true) { () -> Void in
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                
                if self.imageButtonPressed == 1 {
                    self.imageView1.image = image
                    self.delegate?.lookingForImageUpdated(AdColumns.image01.rawValue, image: image)
                } else if self.imageButtonPressed == 2 {
                    self.imageView2.image = image
                    self.delegate?.lookingForImageUpdated(AdColumns.image02.rawValue, image: image)
                } else if self.imageButtonPressed == 3 {
                    self.imageView3.image = image
                    self.delegate?.lookingForImageUpdated(AdColumns.image03.rawValue, image: image)
                } else if self.imageButtonPressed == 4 {
                    self.imageView4.image = image
                    self.delegate?.lookingForImageUpdated(AdColumns.image04.rawValue, image: image)
                }
            }
        }
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    // MARK: - Custom
    func getImageWithName(name: String, file: PFFile?, imageView: DesignableImageView) {
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
