//
//  CDTableViewController.swift
//  Bits
//
//  Created by Huanzhong Huang on 3/8/16.
//  Copyright © 2016 Huanzhong Huang. All rights reserved.
//

import CoreData
import UIKit

class CDTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    // MARK: - INITIALIZATION
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - CELL CONFIGURATION
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        // Use self.frc.objectAtIndexPath(indexPath) to get an object specific to a cell in the subclasses
        print("Please override configureCell in \(#function)!")
    }
    
    // MARK: - OVERRIDE
    var entity = "MyEntity"
    var sort = [NSSortDescriptor(key: "myAttribute", ascending: true)]
    
    // MARK: OPTIONALLY OVERRIDE
    var context = CDHelper.shared.context
    var filter: NSPredicate? = nil
    var cacheName: String? = nil
    var sectionNameKeyPath: String? = nil
    var fetchBatchSize = 0 // 0 = No Limit
    var cellIdentifier = "Cell"
    
    // MARK: FETCHED RESULTS CONTROLLER
    lazy var frc: NSFetchedResultsController = {
        let request = NSFetchRequest(entityName: self.entity)
        request.sortDescriptors = self.sort
        request.fetchBatchSize = self.fetchBatchSize
        if let _filter = self.filter {
            request.predicate = _filter
        }
        let newFRC = NSFetchedResultsController(fetchRequest: request, managedObjectContext: self.context, sectionNameKeyPath: self.sectionNameKeyPath, cacheName: self.cacheName)
        newFRC.delegate = self
        return newFRC
    }()
    
    // MARK: - FETCHING
    func performFetch() {
        frc.managedObjectContext.performBlock {
            do {
                try self.frc.performFetch()
            } catch {
                print("\(#function) FAILED : \(error)")
            }
            self.tableView.reloadData()
        }
    }
    
    // MARK: - VIEW
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Force fetch when notified of significant data changes
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CDTableViewController.performFetch), name: "SomethingChanged", object: nil)
    }
    
    // MARK: - DEALLOCATION
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "SomethingChanged", object: nil)
    }
    
    // MARK: - DATA SOURCE: UITableView
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return frc.sections?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return frc.sections![section].numberOfObjects ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return frc.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return frc.sections![section].name ?? ""
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return frc.sectionIndexTitles
    }
    
    // MARK: - DELEGATE: NSFetchedResultsController
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
        case .Delete:
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .None)
        default:
            break
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
        case .Delete:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
        case .Update:
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
        case .Move:
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .None)
        }
    }

}
