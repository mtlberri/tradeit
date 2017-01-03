import UIKit
import Firebase

class ItemDisplayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
    // MARK: Properties
    var itemToDisplay: Item?
    
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
        
        
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("ItemDisplayVC:: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending is user signed in or not)
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
