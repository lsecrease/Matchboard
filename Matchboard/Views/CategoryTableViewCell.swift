//
//  CategoryTableViewCell.swift
//  Matchboard
//
//  Created by lsecrease on 7/1/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

protocol CategoryTableViewCellDelegate : class {
    func categoryTableViewCellDidTouchCheckbox(cell: CategoryTableViewCell, sender: AnyObject)
}

class CategoryTableViewCell: UITableViewCell {

    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var categoryLabel: UILabel!
   
    
    weak var delegate: CategoryTableViewCellDelegate?


    @IBAction func checkboxTapped(sender: UIButton) {
        self.checkbox.toggleCheckbox()
        

        if self.checkbox.isChecked == false {
            print("Checkbox checked")
            print("\(categoryLabel.text!)")
            //categoryArray.append("\(categoryLabel.text!)")
            //println(categoryArray)
            //delegate?.categoryTableViewCellDidTouchCheckbox(self, sender: sender)
        } else {
            print("Checkbox unchecked")
            print("\(categoryLabel.text!)")
            //var categoryChosen = "\(categoryLabel.text!)"
            //let filter = categoryArray.filter() { $0 != categoryChosen }
            //categoryArray = filter
            //println(categoryArray)
            //delegate?.categoryTableViewCellDidTouchCheckbox(self, sender: sender)
        }
        
        delegate?.categoryTableViewCellDidTouchCheckbox(self, sender: sender)
    }

}
