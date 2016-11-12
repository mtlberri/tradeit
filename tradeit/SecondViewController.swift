//
//  SecondViewController.swift
//  tradeit
//
//  Created by Joffrey Armellini on 2016-11-12.
//  Copyright © 2016 Joffrey Armellini. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {
    
    // Outlet reference to the "Log +1 in Firebase!" button
    @IBOutlet weak var log1InFirebase: UIButton!

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
        // Do something
        print("'Log +1 in Firebase!' button pressed")
    }

}

