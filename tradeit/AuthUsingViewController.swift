import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI


// Auth Using class that is used to gather general behaviour for any view controller wanting to use Auth from Firebase (those view controllers would then sub-class present AuthUsing class)

// Would use the inherited user property, and extend the methods observing if user signed in or out

class AuthUsingViewController: UIViewController, FUIAuthDelegate {

    // MARK: Properties
    // Firebase Auth UI instance
    let authUI = FUIAuth.defaultAuthUI()
    // Handle to the observer
    var handle: FIRAuthStateDidChangeListenerHandle?
    
    // Array of providers used (for configuration)
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]
    // Identity of the user
    var user: FIRUser?
    // ref to the user in FIRDB
    var userRefDB: FIRDatabaseReference?
    
    
    // MARK: Methods
    override func viewDidLoad() {
        
        // Configure Firebase Auth UI:
        
        authUI?.delegate = self
        self.authUI?.providers = providers
        // Terms Of Service (Can be customized later!)
        let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!
        authUI?.tosurl = kFirebaseTermsOfService
        
        
    }
    
    // Set the user sign in status observer in the view will appear (recommended practice)
    override func viewWillAppear(_ animated: Bool) {
    
        // Observe the status of connection of the user
        self.handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, observedUser) in
            //
            if observedUser != nil {
                // Call the relevant method for use by the sub-class
                self.userObservedSignedIn(observedUser!)
            } else {
                // Call the relevant method for use by the sub-class
                self.userObservedSignedOut()
            }
            
        }
        
    }
    
    // Remove the user sign in status observer in the view did disappear (recommended practice)
    override func viewDidDisappear(_ animated: Bool) {
        
        if self.handle != nil {
            FIRAuth.auth()?.removeStateDidChangeListener(self.handle!)
        }
        
    }
    
    
    // Method called when user signed in
    func userObservedSignedIn (_ user: FIRUser) -> Void {
        
        // Set the user property
        self.user = user
        print("User \(user.displayName) Observed Signed In!")

        
        // Update the user in Firebase
        self.userRefDB = FIRDatabase.database().reference().child("users/\(user.uid)")
        
        // Create dictionary for update
        let userDetails: [String: String] = ["displayName": user.displayName ?? "",
                           "email": user.email ?? "",
                           "photoURL": user.photoURL?.absoluteString ?? "",
                           "profileDescription": "Hi! my name is \(user.displayName ?? "")."
        ]
        // Update User details in Firebase
        self.userRefDB!.updateChildValues(userDetails) { (error: Error?, ref: FIRDatabaseReference) -> Void in
            // Completion block
            if error == nil {
                print("user details have been successfully udpated in Firebase")
            } else {
                print("user details have  failed udpate in Firebase with following error: \(error)")
            }
            
        }
        
        
    }
    
    // Method called when user signed out
    func userObservedSignedOut () -> Void {
 
        // Set the user property
        self.user = nil
        print("User Observed Signed Out!")
        
        
    }
    
    // Called when sign in complete (implementation of protocol FUIAuthDelegate)
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // handle user and error as necessary
        print("authUI called: sign in process completed")
        
    }
    
    
    
}
