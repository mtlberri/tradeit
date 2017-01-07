import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseGoogleAuthUI
import SDWebImage
import TemporaryAlert

class ProfileViewController: UIViewController, FUIAuthDelegate {

    // MARK: Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var numberOfItemsPosted: UILabel!
    @IBOutlet weak var numberOfHooksReceived: UILabel!
    @IBOutlet weak var profileDescription: UITextView!

    
    @IBOutlet weak var profileCollectionView: UICollectionView!
    
    
    // MARK: Properties
    
    // Properties Identifying the user for which the Profile is being displayed (default to the signed in user, but could be set to another user in order to display a third party profile)
    var presentedUserUID: String?
    var selfIsUserProfile = true
    
    // E-mail property (for use in 'Contact me')
    var userEmail: String?
    
    // Firebase Auth UI instance
    let authUI = FUIAuth.defaultAuthUI()
    // Array of providers used (for configuration)
    let providers: [FUIAuthProvider] = [FUIGoogleAuth()]

    
    // CV Delegate and Data Source
    let profileCollectionViewDataSourceAndDelegate = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsCollectionStoryboardID") as! ItemsCollectionViewController
    
    // MARK: View Did Load
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ProfileVC: Did Load!")
        
        // Set-up the profile collection view delegate and data source
        self.profileCollectionView.delegate = self.profileCollectionViewDataSourceAndDelegate
        self.profileCollectionView.dataSource = self.profileCollectionViewDataSourceAndDelegate
        
        // set the present view controller as the foreign VC on the data source and delegate
        self.profileCollectionViewDataSourceAndDelegate.foreignViewControllerUsingDataSourceAndDelegate = self
        
        // Configure Firebase Auth UI
        authUI?.delegate = self
        self.authUI?.providers = providers
        // Terms Of Service (Can be customized later!)
        let kFirebaseTermsOfService = URL(string: "https://firebase.google.com/terms/")!
        authUI?.tosurl = kFirebaseTermsOfService
        
        // Observe user Sign In Status via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("ProfileVC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
            case .observedSignedIn:
                
                // If self is user profile, then set the presentedUserUID accordingly
                if self.selfIsUserProfile {
                    self.presentedUserUID = Auth.sharedInstance.user?.uid
                }
                
                
                // Customize the Profile View with the user related data
                if let presentedUID = self.presentedUserUID {
                    print("ProfileVC: Presented User UID is \(presentedUID)")
                    
                    let presentedUserRef = Item.refD.child("users/\(presentedUID)")
                    // set the profileCV data source FIRDB ref to the appropriate location based on the presented user
                    self.profileCollectionViewDataSourceAndDelegate.dbRef = presentedUserRef.child("userItems")
                    
                    // Using the appropriate FIRDBRef: Init Items Array if required (if nil) and reload collection view
                    self.initItemsArrayIfRequiredAndReloadCollectionView()
                    
                    // Hide the Sign In Button, show Sign Out
                    self.signInButton.isHidden = true
                    self.signOutButton.isHidden = false
                    
                    // Go get some profile details of the user from FIRDB and customize the view with it
                    presentedUserRef.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
                        let value = snapshot.value as? NSDictionary
                        
                        // Profile Description
                        let profileDescription = value?["profileDescription"] as? String ?? ""
                        self.profileDescription.text = profileDescription
                        
                        // Display Name
                        self.userName.text = value?["displayName"] as? String
                        
                        // E-mail
                        self.userEmail = value?["email"] as? String
                        
                        // Profile photo
                        if let photoURLString = value?["photoURL"] as? String {
                            let photoURL = URL(string: photoURLString)
                            self.profileImage.sd_setImage(with: photoURL) // Profile Photo URL could be nil, resulting in empty Photo
                        }
                        
                    }
                    
                    // Observe (Listener) the number of Hooks Received by the user and keep view updated accordingly
                    presentedUserRef.child("hooksReceived").observe(.value, with: { snapshot in
                        print("ProfileVC: hooks received .value event observed")
                        let arrayOfHooksSnapshot = snapshot.value as? NSDictionary
                        if let arrayOfHooks = arrayOfHooksSnapshot {
                            self.numberOfHooksReceived.text = String(arrayOfHooks.count)
                        }
                    })
                    
                    
                    
                    
                }
                
                
                
                
                
                
                
            case .observedSignedOut:
                print("ProfileVC: user is signed out \(Auth.sharedInstance.user) ")
                
                
                // Reset all elements of the view
                
                self.userName.text = "No User Signed In"
                // Hide the Sign Out Button, show Sign In
                self.signInButton.isHidden = false
                self.signOutButton.isHidden = true
                
                self.profileDescription.text = ""
                self.numberOfItemsPosted.text = "0"
                self.numberOfHooksReceived.text = "0"
                self.profileImage.image = nil
                //
                
                self.profileCollectionViewDataSourceAndDelegate.itemsArray = nil
                // Reload the Profile Collection View to wipe out the items that were displayed (data source being empty at that point)
                self.profileCollectionView.reloadData()
                
                
                
            }
            
            
        }
        
        
        
        
    }
    
    
    // MARK: Other Methods
    
    
    // Method checking if the array of items needs to be initialized, and doing so if required (while refreshing the Profile Collection View
    func initItemsArrayIfRequiredAndReloadCollectionView () -> Void {
        
        // If the data source array of items is nil, then go init it and customize the view upon completion
        if self.profileCollectionViewDataSourceAndDelegate.itemsArray == nil {
            
            print("ProfileCV: data source array of items is nil, so go init it.")
            
            self.profileCollectionViewDataSourceAndDelegate.initItemsArray {
                
                print("Profile CV: Reload the View!")
                self.profileCollectionView.reloadData()
                
                // Set the number of items posted in the view
                print("Set the number of items of the user: \(self.profileCollectionViewDataSourceAndDelegate.itemsArray?.content.count ?? 0)")
                self.numberOfItemsPosted.text = String(describing: self.profileCollectionViewDataSourceAndDelegate.itemsArray?.content.count ?? 0)
                
            }
        
        } else {
            print("ProfileCV: data source array of items is not nil, so no need to init it.")
        }
        
    }
    
    // MARK: Button actions
    
    // Sign in button pressed
    @IBAction func signInPressed(_ sender: Any) {
        print("ProfileCV: Sign In button pressed")
        
        // Create a Firebase Auth UI View Controller (default) and present it
        let authViewController = self.authUI?.authViewController()
        self.present(authViewController!, animated: true, completion: nil)
    }
    
    // sign out button pressed
    @IBAction func signOutPressed(_ sender: Any) {
        print("ProfileCV: Sign Out Button pressed!")
        
        do {
            try FIRAuth.auth()?.signOut()
            }
        catch {
            print("ProfileCV: Sign Out did fail")
        }
        
    }

    // Contact me button pressed
    
    @IBAction func contactMePressed(_ sender: UIButton) {
        
        let emailString = "\(userEmail ?? "No user email available")"
        
        let alertController = UIAlertController(title: "E-mail", message: emailString, preferredStyle: .alert)
        // Configure the default action
        let defaultAction = UIAlertAction(title: "Copy to clipboard", style: .default, handler: { alertAction in
            //Do somehting when Copy button pressed
            print("ProfileCV: Go copy e-mail in clipboard!")
            UIPasteboard.general.string = emailString
            
            // Confirm via temporary alert
            TemporaryAlert.Configuration.lifeSpan = 1
            TemporaryAlert.show(image: .checkmark, title: "Copied to clipboard", message: nil)
            
            
        })
        // Add the default action to the alert controller
        alertController.addAction(defaultAction)
        
        // Present the alert controller
        self.present(alertController, animated: true, completion: nil)
        
        
    }
    
    
    
    
    
    // FUIAuthDelegate protocol implementation: Called when sign in is complete
    func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?) {
        // handle user and error as necessary
        print("authUI called: sign in process completed")
        
    }
    
    


}




