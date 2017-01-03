import UIKit

class BrowseCitiesViewController: UIViewController{
    
   // MARK: Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("Browse Catgerories VC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending is user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                print("Browse Catgerories VC: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
            case .observedSignedOut:
                print("Browse Catgerories VC: user is signed out \(Auth.sharedInstance.user) ")
            }
            
            
        }
        
    }
    

}

