//
//  HeadingsViewController.swift
//  Bits
//
//  Created by Huanzhong Huang on 1/4/16.
//  Copyright © 2016 Huanzhong Huang. All rights reserved.
//

import CoreData
import UIKit

class HeadingsViewController: CDTableViewController {
    
    // MARK: - CELL CONFIGURATION
    override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        if let bit = frc.objectAtIndexPath(indexPath) as? Bit {
            cell.textLabel?.text = bit.text
        }
    }
    
    // MARK: - INITIALIZATION
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // CDTableViewController subclass customization
        entity = "Bit"
        sort = [NSSortDescriptor(key: "dateModified", ascending: false)]
    }
    
    // MARK: - VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: #selector(compose))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        performFetch()
    }
    
    // MARK: - DATA SOURCE: UITableView
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            if let object = frc.objectAtIndexPath(indexPath) as? NSManagedObject {
                frc.managedObjectContext.deleteObject(object)
            }
            CDHelper.saveSharedContext()
        default:
            break
        }
    }
    
    // MARK: - ACTION
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showBody", sender: nil)
    }
    
    func compose() {
        performSegueWithIdentifier("compose", sender: nil)
    }
    
    // MARK: - SEGUE
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "compose":
                if let bodyVC = segue.destinationViewController as? BodyViewController {
                    if let bit = NSEntityDescription.insertNewObjectForEntityForName("Bit", inManagedObjectContext: CDHelper.shared.context) as? Bit {
                        bit.dateModified = NSDate()
                        bodyVC.segueObject = bit
                    }
                }
            case "showBody":
                if let bodyVC = segue.destinationViewController as? BodyViewController {
                    if let object = frc.objectAtIndexPath(tableView.indexPathForSelectedRow!) as? NSManagedObject {
                        bodyVC.segueObject = object
                    }
                }
            default:
                break
            }
        }
    }

}
