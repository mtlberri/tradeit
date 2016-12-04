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
class SecondViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    // MARK: Properties
    // Create and initialized the item object
    let itemToBeLogged = Item()
    // Firebase database ref
    var dbRef: FIRDatabaseReference! = FIRDatabase.database().reference()
    // Firebase storage reference
    let imagesRef = FIRStorage.storage().reference(forURL: "gs://tradeit-99edf.appspot.com/").child("images")
    // Image Picker of the view controller
    let imagePicker = UIImagePickerController()    
    
    // MARK: Outlets
    // Outlet reference to the "Post item!" button
    @IBOutlet weak var postItemButton: UIButton!
    // Outlet reference to the item descirption text field
    @IBOutlet weak var itemDescription: UITextView!
    // Outlet reference to the image of the item being posted
    @IBOutlet weak var imageOfItem: UIImageView!
    // progress view
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: Methods
    // Method posting the item to be logged in firebase
    func postItemInFirebase (_ item: Item) {
        
        item.key = dbRef.childByAutoId().key
        print("Item key is set to \(item.key!)")
        
        // Create the Dictionary for transfer to Firebase DB
        let itemDictionary: [String: Any] = [
            "key": item.key!,
            "description": item.description ?? "",
            "imagePath": "",
            "tags": item.tags ?? ["items"]
        ]
        // Create the child item that will be updated in the DB
        let childUpdate = ["\(item.key!)": itemDictionary]
        
        // Push a NSDictionary entry in Firebase
        dbRef.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            print("Loading of item in Firebase DB completed! At reference key: \(ref.key)...")
        })
        
        // Upload the image to Google Storage
        // If the image is not nil...
        if let image = item.image {
            
            // Create a ref to the exact location where to upload the picture
            item.imagePath = "\(item.key!).jpg"
            let itemToBeLoggedImageRef = imagesRef.child(item.imagePath!)
            print("...corresponding image will be stored at: \(item.imagePath!)")
            
            // ...Then convert the image into a Data? object...
            let imageData: Data? = UIImageJPEGRepresentation(image, 1.0)
            
            
            
            // ...Then if Data? is not nil, launch the Google Upload
            if let data = imageData {
                
                // Get the optimized version of the image data
                let optimizedData = optimizeImageData(data);
                
                let uploadTask = itemToBeLoggedImageRef.put(optimizedData!, metadata: nil) { metadata, error in
                    if (error != nil) {
                        // Uh-oh, an error occured!
                        print("error occured when trying to upload...")
                    } else {
                        print("image uploaded successfully!")
                        
                        self.dbRef.updateChildValues(["\(item.key!)/imagePath": item.imagePath!], withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
                            if error != nil {
                                print("Oops error during Firbase update of imagePath for key: \(ref.key)")
                            } else {
                               print("Update of item in Firebase DB completed! At reference key: \(ref.key), for imagePath \(item.imagePath!)")
                            }
                            
                        })
                        
                    }
                }
                
                // Upload Task observer and status bar update
                uploadTask.observe(.progress, handler: { snapshot in
                    if let progress = snapshot.progress {
                        let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                        self.progressView.progress = Float(percentComplete)
                        print("Upload progressed: percent complete = \(percentComplete)")
                    }
                })
                
            }
        }
        
    }
    
    // Function optimizing the compression of the image data depending on its size
    func optimizeImageData(_ originalImageData: Data) -> Data? {
        let optimizedImageData: Data?
        let originalSize: Float = Float(originalImageData.count) / 1024.0
        print("Original Image data size: \(originalSize)")
        var optimizedSize = originalSize
        
        // if size < 1000KB
        if originalSize < 1000.0 {
            optimizedImageData = originalImageData
            print("Image data size kept as-is: \(originalSize)")
        } else {
            // Compress at 0.1
            optimizedImageData = UIImageJPEGRepresentation(UIImage(data: originalImageData)!, 0.1)
            optimizedSize = Float(optimizedImageData!.count) / 1024.0
            print("Image data size optimized by compression ratio 0.1: \(optimizedSize)")
        }
        return optimizedImageData
    }
    
    // MARK: override of View Controller basic functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the present class as the delegate for the image picker
        imagePicker.delegate = self
        // Set the present class as the delegate for the ui text view for item description
        itemDescription.delegate = self
        
        // Define border for the text view
        let myBorderColor = UIColor.lightGray
        itemDescription.layer.borderColor = myBorderColor.cgColor
        itemDescription.layer.borderWidth = 1.0
        itemDescription.layer.cornerRadius = 5.0
        
        // Set a default image for the item
        self.itemToBeLogged.image = imageOfItem.image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UIImagePickerControllerDelegate Methods
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // Get the image itself
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // imageOfItem is the outlet to the view!
            self.imageOfItem.contentMode = .scaleAspectFit
            self.imageOfItem.image = pickedImage
            
            
            
            //set the image in the item to be logged object
            self.itemToBeLogged.image = pickedImage
            
        }
        
        
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: UITextViewDelegate Methods
    func textViewDidChange(_ textView: UITextView) {
        // set the text from the text view into the item description
        self.itemToBeLogged.description = textView.text
        print("text view did change!")
    }
    
    // MARK: Actions
    // Action called when the "Choose image button is pressed"
    @IBAction func chooseImagePressed(_ sender: UIButton) {
        // No editing will be allowed
        imagePicker.allowsEditing = false
        // Select the source to be the Photo Library
        imagePicker.sourceType = .photoLibrary
        
        // Present the image picker
        present(imagePicker, animated: true, completion: nil)
    }
    
    // Action called when "Post item button pressed"
    @IBAction func postItemButtonPressed(_ sender: UIButton) {
        // Print message when button pressed
        print("'Post item!' button pressed")
        postItemInFirebase(itemToBeLogged)
      
    }

    

}

