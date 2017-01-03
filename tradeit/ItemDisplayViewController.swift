import UIKit
import Firebase

class ItemDisplayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var hookButton: UIButton!
    @IBOutlet weak var numberHooks: UILabel!
    
    // MARK: Properties
    var itemToDisplay: Item?
    var itemHooks: HooksArray?
    
    // MARK: METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Define border for the text view
        let myBorderColor = UIColor.lightGray
        self.itemDescription.layer.borderColor = myBorderColor.cgColor
        self.itemDescription.layer.borderWidth = 0.5
        
        // Set description
        self.itemDescription.text = self.itemToDisplay?.description
        
        // Download image
        let downloadTask = self.itemToDisplay?.downloadImage(kind: .original) { error in
            // completion block
            if error == nil {
                print("ItemDisplayVC: item image downloaded successfully!")
                self.itemImage.image = self.itemToDisplay?.image
                self.progressView.isHidden = true
            } else {
                print("ItemDisplayVC: item image download failed with error: \(error)")
            }
            
        }
        
        // Monitoring download progress
        downloadTask?.observe(.progress, handler: { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
                print("ItemDisplayVC: Upload progressed: percent complete = \(percentComplete)")
            }
        })
        
        
        // Go get the hooks for that item and observe them
        if let itemKey = self.itemToDisplay?.key {
            // create a ref to the location of the itemToDisplay hooks
            let ref = Item.refD.child("items/\(itemKey)/hooks")
            // initialize the array of hooks at that ref
            self.itemHooks = HooksArray(hooksAtRef: ref)
            
            // Build and observe the array of hooks
            self.itemHooks?.observeFirebaseHooks { eventType in
                
                // Number of hooks
                let numberOfHooks = self.itemHooks?.content.count ?? 0
                let hookWithOrWithoutS = numberOfHooks < 2 ? "hook" : "hooks"
                
                // Set the number of hooks on the dedicated label
                self.numberHooks.text = "\(numberOfHooks) " + hookWithOrWithoutS
                
            }
            
            // If no hooks, set the number of hooks label accordingly
            if self.itemHooks?.content.count == 0 {
                self.numberHooks.text = "0 hook"
            }
            
            
        } else {
            print("Could not get the array of hooks for that item")
        }
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("ItemDisplayVC:: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                print("ItemDisplayVC:: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
                
                
            case .observedSignedOut:
                print("ItemDisplayVC:: user is signed out \(Auth.sharedInstance.user) ")
            }
            
            
        }
        
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Action Called when the hook button is pressed
    @IBAction func hookButtonPressed(_ sender: UIButton) {
        print("hook button pressed!")
        
        // Check that the itemToDisplay is not nil (shoud not be per design), and that there is a current user signed in
        if let item = self.itemToDisplay, let signedInUser = Auth.sharedInstance.user {
            
            // create the hook (via convenience init) and upload it...
            let hook = Hook(item, sentByUser: signedInUser, creationDate: Date())
            hook.uploadMetadata { error in
                
                if error == nil {
                    print("Item Display VC: Successfully uploaded metadata for the hook \(hook.hookKey)")
                } else {
                    print("Item Display VC: Failed to upload metadata for the hook \(hook.hookKey) with error \(error)")
                }
                
            }
            
        } else {
            print("Could not hook item: either item is nil or user not signed in")
        }
        
        
        
    }

}
