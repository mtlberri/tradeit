import UIKit
import Firebase
import SDWebImage

class ProfileViewController: AuthUsingViewController {

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
    
    // A ItemsCollectionViewController that will be used as delegate and data source for the profile collection view
    let profileCollectionViewDataSourceAndDelegate = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsCollectionStoryboardID") as! ItemsCollectionViewController

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile View Did Load!")
        
        // Set-up the profile collection view delegate and data source
        self.profileCollectionView.delegate = self.profileCollectionViewDataSourceAndDelegate
        self.profileCollectionView.dataSource = self.profileCollectionViewDataSourceAndDelegate
        
        // set the present view controller as the foreign VC on the delegate
        self.profileCollectionViewDataSourceAndDelegate.foreignViewControllerUsingDataSourceAndDelegate = self
        
    }
    


    
    // MARK: Custyomization of methods from superclass AuthUsingViewController
    // User Observed Signed In (If User Signed In: Invoked at least a first time at View Will Appear)
    override func userObservedSignedIn (_ user: FIRUser) -> Void {
        super.userObservedSignedIn(user)
        
        // set the profileCV data source FIRDB ref to the appropriate location based on the current user (userRefDB will be set at that point by AuthUsingViewController super method just above
        self.profileCollectionViewDataSourceAndDelegate.dbRef = self.userRefDB!.child("userItems")
        // Using the appropriate FIRDBRef: Init Items Array if required (if nil) and reload collection view
        self.initItemsArrayIfRequiredAndReloadCollectionView()
        
        
        // Hide the Sign In Button, show Sign Out
        self.signInButton.isHidden = true
        self.signOutButton.isHidden = false
        
        // Customize the profile view
        
        self.userName.text = user.displayName
        // Go get some profile details of the user from FIRDB and customize the view with it
        self.userRefDB?.observeSingleEvent(of: .value) { (snapshot: FIRDataSnapshot) in
            let value = snapshot.value as? NSDictionary
            let profileDescription = value?["profileDescription"] as? String ?? ""
            self.profileDescription.text = profileDescription
        }
        // Set User Profile photo
        if self.user?.photoURL != nil {
            self.profileImage.sd_setImage(with: self.user?.photoURL!)
        }
        
        
        
        
        
    }
    
    // User Observed Signed Out (If User Signed Out: Invoked at least a first time at View Will Appear)
    override func userObservedSignedOut () -> Void {
        
        super.userObservedSignedOut()
        
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
    
    
        // MARK: Other Methods
    
    
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


    
    


}




