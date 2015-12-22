//
//  CategoryViewController.swift
//  Matchboard
//
//  Created by lsecrease on 7/1/15.
//  Copyright (c) 2015 ImagineME. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CategoryTableViewCellDelegate, SectionHeaderViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    let SectionHeaderViewIdentifier = "SectionHeaderViewIdentifier"
    var categorySet: Set<String> = Set<String>()

    var fromWelcomeVC: Bool = false
    var categoryArray: [String] = []

    //MARK - Data Source
    lazy var categoryHeaders: [CategoryHeader] = {
        return CategoryHeader.categoryHeaders()
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sectionHeaderNib: UINib = UINib(nibName: "SectionHeaderView", bundle: nil)
        self.tableView.registerNib(sectionHeaderNib, forHeaderFooterViewReuseIdentifier: SectionHeaderViewIdentifier)

        // load
        if fromWelcomeVC {
            let doneButton = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "onDoneButtonClick:")
            self.navigationItem.rightBarButtonItem = doneButton
        } //Otherwise categories from parse
        else if let array = PFUser.currentUser()?.valueForKey("Category") as? NSArray
        {
            let categoryArray: [String] = array as! [String]
            categorySet = Set(categoryArray)
        }

        tableView.backgroundColor = UIColor.clearColor()

    }
    
    //Title of the Section Headers  DONE
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let categoryHeader = categoryHeaders[section]
        return categoryHeader.name
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeaderView: SectionHeaderView! = self.tableView.dequeueReusableHeaderFooterViewWithIdentifier(SectionHeaderViewIdentifier) as! SectionHeaderView
        let sectionInfo = categoryHeaders[section]
        sectionHeaderView.titleLabel.text = sectionInfo.name
        sectionHeaderView.section = section
        sectionHeaderView.delegate = self
        return sectionHeaderView
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40.0
    }
    
    //Number of Sections in the Table View DONE
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return categoryHeaders.count
    }
    
    
    //Number of Rows in each section DONE
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.categoryHeaders.count > 0 {
            let sectionInfo = categoryHeaders[section]
            if sectionInfo.open {
                return sectionInfo.open ? sectionInfo.category.count : 0
            }
        }
        return 0
    }
    
    //What goes in each Table View Cell  DONE
     func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: CategoryTableViewCell = tableView.dequeueReusableCellWithIdentifier("Category") as! CategoryTableViewCell
        
        let categoryHeader = categoryHeaders[indexPath.section]
        let category = categoryHeader.category[indexPath.row]
        cell.categoryLabel.text = category.title
        cell.checkbox.isChecked = categorySet.contains(category.title)
        
        cell.delegate = self
    
        
        return cell
    }
    
    
    
    
//    //??????
//    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
//        var cell: CategoryTableViewCell = tableView.dequeueReusableCellWithIdentifier("Category") as CategoryTableViewCell
//        cell.selectionStyle = UITableViewCellSelectionStyle.None
//        return indexPath == tableView.indexPathForSelectedRow() ? nil : indexPath
//    }
    
    
    //?????????
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //println("Selected")
        var cell: CategoryTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! CategoryTableViewCell
        let categoryHeader = categoryHeaders[indexPath.section]
        let category = categoryHeader.category[indexPath.row]
        cell.checkbox.toggleCheckbox()
        if cell.checkbox.isChecked {
            categorySet.insert(category.title)
        } else {
            categorySet.remove(category.title)
        }

    }
    
    
    //Display of the cells DONE
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let backView = UIImageView(frame: CGRectMake(0, 0, cell.frame.width, cell.frame.height))
        backView.backgroundColor = UIColor.clearColor()
        cell.backgroundView = backView
    }
    
    func onDoneButtonClick(sender: AnyObject) {
        if let user = PFUser.currentUser() {
            saveCategories(forUser: user)
        }
        self.performSegueWithIdentifier("adSegue", sender: self)
    }
    
    func saveCategories(forUser user: PFUser) {
        let categoryArray = NSArray(array: Array(categorySet))
        user.setValue(categoryArray, forKey: "Category")
        user.saveInBackground()
    }
    
    func categoryTableViewCellDidTouchCheckbox(cell: CategoryTableViewCell, sender: AnyObject) {
        if cell.checkbox.isChecked {
            categorySet.insert(cell.categoryLabel.text!)
        } else {
            categorySet.remove(cell.categoryLabel.text!)
        }
        
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionOpened: Int) {
        let sectionInfo = categoryHeaders[sectionOpened]
        let countOfRowsToInsert = sectionInfo.category.count
        sectionInfo.open = true
        
        var indexPathToInsert:[NSIndexPath] = []
        for i in 0..<countOfRowsToInsert {
            indexPathToInsert.append(NSIndexPath(forRow: i, inSection: sectionOpened))
        }
        self.tableView.insertRowsAtIndexPaths(indexPathToInsert, withRowAnimation: .Top)
    }
    
    func sectionHeaderView(sectionHeaderView: SectionHeaderView, sectionClosed: Int) {
        let sectionInfo = categoryHeaders[sectionClosed]
        let countOfRowsToDelete = sectionInfo.category.count
        sectionInfo.open = false
        if countOfRowsToDelete > 0 {
            var indexPathToDelete:[NSIndexPath] = []
            for i in 0..<countOfRowsToDelete {
                indexPathToDelete.append(NSIndexPath(forRow: i, inSection: sectionClosed))
            }
            self.tableView.deleteRowsAtIndexPaths(indexPathToDelete, withRowAnimation: .Top)
        }
    }

}
