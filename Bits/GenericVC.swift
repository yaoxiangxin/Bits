//
//  GenericVC.swift
//  Bits
//
//  Created by Huanzhong Huang on 3/8/16.
//  Copyright © 2016 Huanzhong Huang. All rights reserved.
//

import CoreData
import UIKit

class GenericVC: UIViewController {
    
    var segueObject: NSManagedObject?
    var selectedObject: NSManagedObject? {
        if let object = self.segueObject {
            return object
        }
        self.done() // If the managed object disappears, for example if deleted on another device, then the view is dismissed
        return nil
    }
    
    func done() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func hideKeyboard() {
        view.endEditing(true)
    }
    
    func hideKeyboardWhenBackgroundIsTapped() {
        let tgr = UITapGestureRecognizer(target: self, action:#selector(GenericVC.hideKeyboard))
        view.addGestureRecognizer(tgr)
    }

}
