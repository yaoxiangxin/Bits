//
//  BodyViewController.swift
//  Bits
//
//  Created by Huanzhong Huang on 1/5/16.
//  Copyright © 2016 Huanzhong Huang. All rights reserved.
//

import UIKit

class BodyViewController: GenericVC, UITextViewDelegate {

    @IBOutlet var textView: UITextView!
    @IBOutlet var bottomLayoutConstraint: NSLayoutConstraint!
    
    var shareButton: UIBarButtonItem!
    var textViewTextModified = false
    
    func verifyShareButtonState() {
        shareButton.enabled = textView.hasText()
    }
    
    // MARK: - DELEGATE: UITextView
    func textViewDidChange(textView: UITextView) {
        textViewTextModified = true
        verifyShareButtonState()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textViewTextModified {
            if let bit = selectedObject as? Bit {
                bit.text = textView.text
                bit.dateModified = NSDate()
                textViewTextModified = false
            }
        }
    }
    
    // MARK: - VIEW
    override func viewDidLoad() {
        super.viewDidLoad()

        shareButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: #selector(share))
        navigationItem.rightBarButtonItem = shareButton
        
        applyPreferredFonts()
        
        registerForApplicationStateTransitionNotifications()
        registerForContentSizeNotification()
        registerForKeyboardNotifications()
    }
    
    func refreshInterface() {
        guard let bit = selectedObject as? Bit else { return }
        textView.text = bit.text
        verifyShareButtonState()
        if !textView.hasText() {
            textView.becomeFirstResponder()
        }
    }
    
    /* viewWillAppear(_:) > decodeRestorableStateWithCoder(_:) > applicationFinishedRestoringState() > viewDidAppear(_:) */
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        refreshInterface()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        if !textView.hasText() {
            if let bit = selectedObject as? Bit {
                bit.managedObjectContext?.deleteObject(bit)
            }
        }
        CDHelper.saveSharedContext()
    }
    
    // MARK: - DEALLOCATION
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - STATE RESTORATION
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        super.encodeRestorableStateWithCoder(coder)
        
        let objectID = segueObject?.objectID
        coder.encodeObject(objectID?.URIRepresentation(), forKey: "kManagedObjectKeyPath")
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        super.decodeRestorableStateWithCoder(coder)
        
        let coordinator = CDHelper.shared.coordinator
        if let objectURI = coder.decodeObjectForKey("kManagedObjectKeyPath") as? NSURL, objectID = coordinator.managedObjectIDForURIRepresentation(objectURI) {
            let object = CDHelper.shared.context.objectWithID(objectID)
            segueObject = object
        }
    }
    
    // MARK: - SHARE
    func share() {
        let activityItems = [textView.text]
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
    }
    
    // MARK: - DYNAMIC TYPE
    func registerForContentSizeNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(applyPreferredFonts), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func applyPreferredFonts() {
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    }
    
    // MARK: - MANAGING KEYBOARD
    func registerForKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let kbSize = notification.userInfo?[UIKeyboardFrameEndUserInfoKey]?.CGRectValue().size {
            bottomLayoutConstraint.constant = kbSize.height
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        bottomLayoutConstraint.constant = 0.0
    }
    
    // MARK: - APPLICATION STATE TRANSITIONS
    func registerForApplicationStateTransitionNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(refreshInterface), name: UIApplicationWillEnterForegroundNotification, object: nil)
    }
    
}
