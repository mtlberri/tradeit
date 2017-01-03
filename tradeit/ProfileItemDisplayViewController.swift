import UIKit
import Firebase

class ProfileItemDisplayViewController: UIViewController {
    
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
        
        self.itemDescription.text = self.itemToDisplay?.description
        
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("ProfileItem VC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                print("ProfileItem VC: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
            case .observedSignedOut:
                print("ProfileItem VC: user is signed out \(Auth.sharedInstance.user) ")
            }
            
            
        }
        
        
        print("ProfileItem VC: Start loading of item image")
        let downloadTask = self.itemToDisplay?.downloadImage(kind: .original) { error in
            // completion block
            if error == nil {
                print("ProfileItem VC: item image downloaded successfully!")
                print("ProfileItem VC: set the image in the view! (and hide progress bar)")
                self.itemImage.image = self.itemToDisplay?.image
                self.progressView.isHidden = true
            } else {
                print("ProfileItem VC: item image download failed with error: \(error)")
            }
            
        }
        
        // Monitoring download progress
        downloadTask?.observe(.progress, handler: { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
                print("ProfileItem VC: Upload progressed: percent complete = \(percentComplete)")
            }
        })
        
        
    }
    

    
    
}
