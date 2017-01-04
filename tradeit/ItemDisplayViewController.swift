import UIKit
import Firebase

class ItemDisplayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var hookButton: UIButton!
    @IBOutlet weak var numberHooks: UILabel!
    @IBOutlet weak var nameOfHooksSenders: UILabel!
    
    // MARK: Properties
    var itemToDisplay: Item?
    var itemHooks: HooksArray?
    // Hooks related properties
    var numberOfHooks = 0 {
        didSet {
            print("ItemDisplayVC: number of hooks did set to value \(numberOfHooks)")
            let hookWithOrWithoutS = self.numberOfHooks < 2 ? "hook" : "hooks"
            // Set the number of hooks on the dedicated label
            self.numberHooks.text = "\(self.numberOfHooks) " + hookWithOrWithoutS
        }
    }
    var hookSenders: [(UID: String, DisplayName: String)] = [] {
        didSet {
            print("ItemDisplayVC: hookSenders array did set to value \(hookSenders)")
            // Populate the names of hook senders on the dedicated label
            self.populateNamesOfHookSendersLabel(withArray: self.hookSenders)
        }
    }
    var userAlreadyHookedItemToDisplay = false {
        didSet {
            print("ItemDisplayVC: user already hooked item did set: \(userAlreadyHookedItemToDisplay)")
            // Switc the color of the button depending if user already hooked item or not
            if userAlreadyHookedItemToDisplay {
                self.hookButton.titleLabel?.textColor = UIColor.green
            } else {
                self.hookButton.titleLabel?.textColor = UIColor.blue
            }
        }
    }

    // MARK: View Did Load Method
    
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
                
                // Block executed for each event on the hooks array:
                
                // Refresh the number of hooks
                self.numberOfHooks = self.itemHooks?.content.count ?? 0
                // Refresh the array of hook senders names
                self.hookSenders = self.itemHooks?.makeHookSendersUIDAndDisplayNamesArray() ?? []
                // Check if the current user (if any) is one of the hook senders (i.e. check if he already hooked that item)
                if let user = Auth.sharedInstance.user {
                    self.userAlreadyHookedItemToDisplay = self.hookSenders.contains { hookSender in
                        return hookSender.UID == user.uid
                    }
                }
                
              }
            
        } else {
            print("ItemDisplayVC: Could not get the item key. Error.")
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


    // MARK: Other methods
    
    // Poulate the name of hook senders
    func populateNamesOfHookSendersLabel (withArray array: [(UID: String, DisplayName: String)]) -> Void {
        
        // Reset the label of nameOfHooksSenders to empty
        self.nameOfHooksSenders.text = ""
        // Re-populate the names of the hooks senders based on the complete array of hooks
        if let unwrappedHooksArray = self.itemHooks?.content {
            for hook in unwrappedHooksArray {
                
                // For the first name, don't introduce any space or coma
                if self.nameOfHooksSenders.text == "" {
                    self.nameOfHooksSenders.text = "\(hook.senderUserDisplayName)"
                } else {
                    // Else go append the name to the already started list
                    self.nameOfHooksSenders.text?.append(", \(hook.senderUserDisplayName)")
                }
                
            }
        } else {
            self.nameOfHooksSenders.text = ""
        }
        
    }
    
    
    // Action Called when the hook button is pressed
    @IBAction func hookButtonPressed(_ sender: UIButton) {
        print("hook button pressed!")
        
        // Check that the itemToDisplay is not nil (shoud not be per design), and that there is a current user signed in
        if let item = self.itemToDisplay, let signedInUser = Auth.sharedInstance.user {
            
            
            // Check if the user did not already hook that item
            if self.userAlreadyHookedItemToDisplay == false {
                
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
                // The user already hooked that item - so go ahead and remove it (unhook)
                
                // Retrieve the specific hook from current user
                // Get the hook index
                let indexOfHookFromCurrentUser = self.itemHooks?.content.index { hook in
                    return hook.senderUserUID == signedInUser.uid
                }
                // Remove the hook (index should not be nil because the user already hooked item so his hook index should be found in the array of hooks
                if indexOfHookFromCurrentUser != nil {
                    self.itemHooks?.content[indexOfHookFromCurrentUser!].removeMetadata { error in
                        if error == nil {
                            print("Item Display VC: Successfully removed hook after user request to do so")
                        } else {
                            print("Item Display VC: Failed removal of hook after user request to do so")
                        }
                    }
                    
                }
                
            }

            
        } else {
            print("Item Display VC: either item is nil or user not signed in")
        }
        
        
        
    }

}
