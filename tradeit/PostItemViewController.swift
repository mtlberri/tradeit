import UIKit
import Firebase

// That Class implements Protocols as delegate for the UIImagePickerController
// Also required UINavigationController Delgate (related to the image picker popping out the view)
class PostItemViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // MARK: Properties
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
    
    // MARK: override of View Controller basic functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the present class as the delegate for the image picker
        imagePicker.delegate = self
        
        // Define border for the text view
        let myBorderColor = UIColor.lightGray
        itemDescription.layer.borderColor = myBorderColor.cgColor
        itemDescription.layer.borderWidth = 0.5
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("PostItemVC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                print("PostItemVC: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
            case .observedSignedOut:
                print("PostItemVC: user is signed out \(Auth.sharedInstance.user) ")
            }
            
            
        }
        
        
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
        }
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the image picker
        dismiss(animated: true, completion: nil)
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
        print("PostItemVC: 'Post item!' button pressed")

        /////////////////
        
        
        /////////////////
        
        // Check if the user is signed in to enable upload
        if let currentUser = Auth.sharedInstance.user {
            print("PostItemVC: user is connected so the posting process can start")
            
            // Init an item object
            let newItemKey: String = Item.refD.childByAutoId().key
            let newItemOwnerUID: String = currentUser.uid
            let newItem = Item(key: newItemKey, ownerUID: newItemOwnerUID)
            print("PostItemVC: An Item object has juste been created with key \(newItemKey) and ownerUID \(newItemOwnerUID)")
            
            // Customize the item with the elements from the view
            newItem.description = self.itemDescription.text
            newItem.image = self.imageOfItem.image
            
            // Upload the item to be logged (completion block with output erroros of the full upload process)
            //
            let uploadTask = newItem.upload() { (errorsArray) in
                
                //Do some with the array of errors
                print("PostItemVC: Overall upload process has completed with \(errorsArray.count) errors. Errors being:")
                print(errorsArray)
                
                /////////////
                
                let alertController = UIAlertController(title: "Post Complete!", message: "Your item has just been posted", preferredStyle: .alert)
                // Configure the default action
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { alertAction in
                    //Do somehting when OK button pressed
                    print("PostItemVC: Default Action 'OK' has just been pressed")
                    
                    
                    
                })
                // Add the default action to the alert controller
                alertController.addAction(defaultAction)
                
                // Present the alert controller
                self.present(alertController, animated: true, completion: nil)
                
                /////////////
                
                
            }
            
            
            // Upload Task observer and status bar update
            uploadTask?.observe(.progress, handler: { snapshot in
                if let progress = snapshot.progress {
                    let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                    self.progressView.progress = Float(percentComplete)
                    print("PostItemVC: Upload progressed: percent complete = \(percentComplete)")
                }
            })
            //
            
            
            
        } else {
            print("PostItemVC: User is not signed in so cannot post item")
        }
        
        

    }
    
    

}

