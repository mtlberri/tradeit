//
//  SecondViewController.swift
//  tradeit
//
//  Created by Joffrey Armellini on 2016-11-12.
//  Copyright © 2016 Joffrey Armellini. All rights reserved.
//

import UIKit
import Firebase

// That Class implements Protocols as delegate for the UIImagePickerController
// Also required UINavigationController Delgate (related to the image picker popping out the view)
class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: Outlets
    // Outlet reference to the "Log +1 in Firebase!" button
    @IBOutlet weak var log1InFirebase: UIButton!
    // Outlet reference to the item descirption text field
    @IBOutlet weak var itemDescription: UITextField!
    // Outlet reference to the image of the item being posted
    @IBOutlet weak var imageOfItem: UIImageView!

    // MARK: Properties
    // Firebase database ref
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    // Image Picker of the view controller
    let imagePicker = UIImagePickerController()
    
    // MARK: override of View Controller basic functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the present class as the delegate for the image picker
        imagePicker.delegate = self
        
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Actions
    // Action called when the "Choose image button is pressed"
    @IBAction func chooseImagePressed(sender: UIButton) {
        // No editing will be allowed
        imagePicker.allowsEditing = false
        // Select the source to be the Photo Library
        imagePicker.sourceType = .PhotoLibrary
        
        // Present the image picker
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageOfItem.contentMode = .ScaleAspectFit
            imageOfItem.image = pickedImage
        }
        // Dismiss the image picker
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // Do nothing
    }
    
    
    // Action called when "Log +1 in Firebase!" button pressed
    @IBAction func log1InFirebasePressed(sender: UIButton) {
        // Print message when button pressed
        print("'Log +1 in Firebase!' button pressed")

        // Create and initialized the item object
        let itemToBeLogged = Item()
        if let description = itemDescription.text {
            //get the text and use it
            itemToBeLogged.description = description
        }
        
        // Create the NSDictionary for transfer to Firebase
        let itemToBeLoggedDictionary: NSDictionary = [
            "itemDescription": itemToBeLogged.description
        ]
        
        // Push a NSDictionary entry in Firebase
        ref.childByAutoId().setValue(itemToBeLoggedDictionary)
    
    }

}

