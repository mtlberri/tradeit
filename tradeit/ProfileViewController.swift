import UIKit
import Firebase

class ProfileViewController: AuthUsingViewController {

    // Mark: Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numberOfItems: UITextField!
    @IBOutlet weak var numberOfLikes: UITextField!
    @IBOutlet weak var profileDescription: UITextView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        //
        

        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInPressed(_ sender: Any) {
        print("Sign In button pressed")
        
        // Create a Firebase Auth UI View Controller (default) and present it
        let authViewController = self.authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    
    @IBAction func signOutPressed(_ sender: Any) {
        print("Sign Out Button pressed!")
        
        do {
            try FIRAuth.auth()?.signOut()
            }
        catch {
            print("Sign Out did fail")
        }
        
    }

    // Extend the methods from super class AuthUsingViewController
    // User Observed Signed In
    override func userObservedSignedIn (_ user: FIRUser) -> Void {
        
        super.userObservedSignedIn(user)
        
        self.userName.text = user.displayName
        // Hide the Sign In Button, show Sign Out
        self.signInButton.isHidden = true
        self.signOutButton.isHidden = false
        
    }
    
    // User Observed Signed Out
    override func userObservedSignedOut () -> Void {
        
        super.userObservedSignedOut()
        
        self.userName.text = "No User Signed In"
        // Hide the Sign Out Button, show Sign In
        self.signInButton.isHidden = false
        self.signOutButton.isHidden = true
        
    }
    
    


}
