import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI

class ProfileViewController: UIViewController, FUIAuthDelegate {

    // Mark: Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    
    // MARK: Properties
    // Firebase Auth UI instance
    let authUI = FUIAuth.defaultAuthUI()
    // Array of providers used (for configuration)
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    // Identity of the user
    var user: FIRUser?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configure Firebase Auth UI:
        
        authUI?.delegate = self
        self.authUI?.providers = providers
        // Terms Of Service (Can be customized later!)
        let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!
        authUI?.tosurl = kFirebaseTermsOfService
        
        // Observe the status of commection of the user
        let handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, user) in
            //
            if user != nil {
                print("User is connected!")
                // Set the user property
                self.user = user
                print("And his name is \(user?.displayName)")
                // Display the name in the view
                self.userName.text = user!.displayName
                // Hide the Sign In Button, show Sign Out
                self.signInButton.isHidden = true
                self.signOutButton.isHidden = false
                
            } else {
                print("Please Sign In")
                
                // Set the user property back to nil
                self.user = nil
                // Display the name in the view
                self.userName.text = "No User Signed In"
                
                // Hide the Sign Out Button, show Sign In
                self.signInButton.isHidden = false
                self.signOutButton.isHidden = true
            }
            
        }
        
        
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

    // Called when sign in complete (implementation of protocol FUIAuthDelegate)
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // handle user and error as necessary
        print("authUI called: sign in process completed")
        
    }

}
