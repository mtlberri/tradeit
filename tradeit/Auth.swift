import Foundation
import Firebase

// Class used as a Service for observing the user sign in status and accessing associated user data

class Auth {
    
    // MARK: Singleton
    // Singleton is used because only once centrla instance of that Auth class is to be used in the App
    
    // class variable (can be called without having to instantiate the class)
    class var sharedInstance: Auth {
        
        // Singleton structure wrapping a constant named instance
        struct Singleton {
            
            // "static" ensures that the instance property only exists once
            // "static" properties are implicitely lazy (instance not created until it's needed)
            static let instance = Auth()
            
        }
        
        // returns the computed type property
        return Singleton.instance
        
    }
    
    
    // MARK: Properties
    
    // Handle to the observer
    private var handle: FIRAuthStateDidChangeListenerHandle?
    // Identity of the user
    var user: FIRUser?
    // ref to the user in FIRDB
    var userRefDB: FIRDatabaseReference?
    

    // MARK: observeUser method
    func observeUser(withBlock: @escaping (_ event: AuthEvent) -> Void) {
        
        // Observe the status of connection of the user
        self.handle = FIRAuth.auth()?.addStateDidChangeListener() { (auth, observedUser) in
            //
            if observedUser != nil {
                // Call the relevant method for use by the sub-class
                self.userObservedSignedIn(observedUser!)
                // Invoke the block with appropriate arguments
                withBlock(.observedSignedIn)
    
            } else {
                // Call the relevant method for use by the sub-class
                self.userObservedSignedOut()
                // Invoke the block with appropriate arguments
                withBlock(.observedSignedOut)
            }
        }
        
        
    }
    
    
    
    // MARK: Supporting Methods
    
    // Method called when user signed in
    func userObservedSignedIn (_ user: FIRUser) -> Void {
        
        // Set the user property
        self.user = user
        print("Auth: User \(user.displayName) Observed Signed In!")
        
        
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
                print("Auth: user details have been successfully udpated in Firebase")
            } else {
                print("Auth: user details have  failed udpate in Firebase with following error: \(error)")
            }
            
        }
        
        
    }
    
    // Method called when user signed out
    func userObservedSignedOut () -> Void {
        print("Auth: User Observed Signed Out!")
        
        // Reset user related properties to nil
        self.user = nil
        self.userRefDB = nil
        
    }
    
    
    
    // MARK: Deinit
    deinit {
        // Remove the observer if any
        if self.handle != nil {
            FIRAuth.auth()?.removeStateDidChangeListener(self.handle!)
        }
    }
    
    
    
}

// Auth Event Types
enum AuthEvent {
    
    case observedSignedIn
    case observedSignedOut
    
    
}


