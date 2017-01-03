import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import SDWebImage

class ProfileViewController: UIViewController, FUIAuthDelegate {

    // MARK: Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numberOfItems: UITextField!
    @IBOutlet weak var numberOfLikes: UITextField!
    @IBOutlet weak var profileDescription: UITextView!

    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    
    // MARK: Properties
    
    // Firebase Auth UI instance
    let authUI = FUIAuth.defaultAuthUI()
    // Array of providers used (for configuration)
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]

    
    // A ItemsCollectionViewController that will be used as delegate and data source for the profile collection view
    let profileCollectionViewDataSourceAndDelegate = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsCollectionStoryboardID") as! ItemsCollectionViewController


    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProfileVC: Did Load!")
        
        // Set-up the profile collection view delegate and data source
        self.profileCollectionView.delegate = self.profileCollectionViewDataSourceAndDelegate
        self.profileCollectionView.dataSource = self.profileCollectionViewDataSourceAndDelegate
        
        // set the present view controller as the foreign VC on the delegate
        self.profileCollectionViewDataSourceAndDelegate.foreignViewControllerUsingDataSourceAndDelegate = self
        
        
        
        // Configure Firebase Auth UI
        authUI?.delegate = self
        self.authUI?.providers = providers
        // Terms Of Service (Can be customized later!)
        let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!
        authUI?.tosurl = kFirebaseTermsOfService
        
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("ProfileVC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                print("ProfileVC: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
                
                // Check if the user and userRef are not nil (should never be else since just observed signed in) - still that check is kept for robustness
                if Auth.sharedInstance.user != nil && Auth.sharedInstance.userRefDB != nil {
                    
                    
                    // set the profileCV data source FIRDB ref to the appropriate location based on the current user (userRefDB will be set at that point by AuthUsingViewController super method just above
                    self.profileCollectionViewDataSourceAndDelegate.dbRef = Auth.sharedInstance.userRefDB!.child("userItems")
                    // Using the appropriate FIRDBRef: Init Items Array if required (if nil) and reload collection view
                    self.initItemsArrayIfRequiredAndReloadCollectionView()
                    
                    
                    // Hide the Sign In Button, show Sign Out
                    self.signInButton.isHidden = true
                    self.signOutButton.isHidden = false
                    
                    // Customize the profile view
                    
                    self.userName.text = Auth.sharedInstance.user?.displayName
                    
                    // Go get some profile details of the user from FIRDB and customize the view with it
                    Auth.sharedInstance.userRefDB!.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        let value = snapshot.value as? NSDictionary
                        let profileDescription = value?["profileDescription"] as? String ?? ""
                        self.profileDescription.text = profileDescription
                    }
                    // Set User Profile photo
                    if Auth.sharedInstance.user!.photoURL != nil {
                        self.profileImage.sd_setImage(with: Auth.sharedInstance.user!.photoURL!)
                    }
            
                }
                
                
            case .observedSignedOut:
                print("ProfileVC: user is signed out \(Auth.sharedInstance.user) ")
                
                
                // Reset all elements of the view
                
                self.userName.text = "No User Signed In"
                // Hide the Sign Out Button, show Sign In
                self.signInButton.isHidden = false
                self.signOutButton.isHidden = true
                
                self.profileDescription.text = ""
                self.numberOfItems.text = ""
                self.numberOfLikes.text = ""
                self.profileImage.image = nil
                //
                
                self.profileCollectionViewDataSourceAndDelegate.itemsArray = nil
                // Reload the Profile Collection View to wipe out the items that were displayed (data source being empty at that point)
                self.profileCollectionView.reloadData()
                
                
                
            }
            
            
        }
        
        
        
        
    }
    
    
    // MARK: Methods
    
    
    // Method checking if the array of items needs to be initialized, and doing so if required (while refreshing the Profile Collection View
    func initItemsArrayIfRequiredAndReloadCollectionView () -> Void {
        
        // If the data source array of items is nil, then go init it and customize the view upon completion
        if self.profileCollectionViewDataSourceAndDelegate.itemsArray == nil {
            
            print("ProfileCV: data source array of items is nil, so go init it.")
            
            self.profileCollectionViewDataSourceAndDelegate.initItemsArray {
                
                print("Profile CV: Reload the View!")
                self.profileCollectionView.reloadData()
                
                // Set the number of items in the view
                print("Set the number of items of the user: \(self.profileCollectionViewDataSourceAndDelegate.itemsArray?.content.count ?? 0)")
                self.numberOfItems.text = String(describing: self.profileCollectionViewDataSourceAndDelegate.itemsArray?.content.count ?? 0)
                
            }
        
        } else {
            print("ProfileCV: data source array of items is not nil, so no need to init it.")
        }
        
    }
    
    
    // Sign in button pressed
    @IBAction func signInPressed(_ sender: Any) {
        print("Sign In button pressed")
        
        // Create a Firebase Auth UI View Controller (default) and present it
        let authViewController = self.authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    // sign out button pressed
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




