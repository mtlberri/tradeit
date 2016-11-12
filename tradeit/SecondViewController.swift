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
        
        // Push a "+1 added!" entry in Firebase
        ref.childByAutoId().setValue("+1 added!")
        
    }

}

