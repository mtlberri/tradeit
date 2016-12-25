import UIKit
import Firebase
import SDWebImage

class ProfileViewController: AuthUsingViewController {

    // Mark: Outlets
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
    let profileCollectionViewCOntroller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "itemsCollectionStoryboardID") as! ItemsCollectionViewController

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Profile View Did Load!")
        
        // Set-up the profile collection view delegate and data source
        self.profileCollectionView.delegate = self.profileCollectionViewCOntroller
        self.profileCollectionView.dataSource = self.profileCollectionViewCOntroller
        
    
        
    }
    
    // Customize the View will appear from the superclass AuthUsingViewController
    override func viewWillAppear(_ animated: Bool) {
        
        // Call the view will appear method from superclass AuthUsingViewController
        super.viewWillAppear(true)

        
        // If the data source array of items is nil, then go init it customize the view upon completion
        if self.profileCollectionViewCOntroller.itemsArray == nil {
            
            self.profileCollectionViewCOntroller.initItemsArray {
                
                self.profileCollectionView.reloadData()
                
                // Set the number of items in the view
                self.numberOfItems.text = String(describing: self.profileCollectionViewCOntroller.itemsArray?.content.count ?? 0)
                
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

    // Custyomize the methods from superclass AuthUsingViewController
    // User Observed Signed In
    override func userObservedSignedIn (_ user: FIRUser) -> Void {
        
        super.userObservedSignedIn(user)
        
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
    
    // User Observed Signed Out
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
        
        
    }
    
    


}




