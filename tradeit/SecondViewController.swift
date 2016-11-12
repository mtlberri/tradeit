//
//  SecondViewController.swift
//  tradeit
//
//  Created by Joffrey Armellini on 2016-11-12.
//  Copyright © 2016 Joffrey Armellini. All rights reserved.
//

import UIKit
import Firebase

class SecondViewController: UIViewController {
    
    // Outlet reference to the "Log +1 in Firebase!" button
    @IBOutlet weak var log1InFirebase: UIButton!
    // Outlet reference to the item descirption text field
    @IBOutlet weak var itemDescription: UITextField!

    // Firebase database ref
    var ref: FIRDatabaseReference! = FIRDatabase.database().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

