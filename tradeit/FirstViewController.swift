//
//  FirstViewController.swift
//  tradeit
//
//  Created by Joffrey Armellini on 2016-11-12.
//  Copyright © 2016 Joffrey Armellini. All rights reserved.
//

import UIKit
import Firebase

class FirstViewController: UIViewController {

    var myContext = 0
    let testRef: FIRDatabaseReference! = FIRDatabase.database().reference()
    var testItemsArray: ItemsArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.testItemsArray = ItemsArray(withMetadataFromFBRef: testRef)
        
        // Put an observer on the items array "initComplted" key
        testItemsArray.addObserver(self, forKeyPath: "metadataInitCompleted", options: .new, context: &myContext)
        
    }

    //override the observer function
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Observer triggered!")
        
        if context == &myContext {
            print("items array init completed: \(change?[NSKeyValueChangeKey.newKey])")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

