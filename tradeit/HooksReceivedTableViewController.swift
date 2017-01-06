import UIKit
import Firebase
import SDWebImage

class HooksReceivedTableViewController: UITableViewController {


    // MARK: Properties
    var hooksReceivedArray: HooksArray?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HooksReceivedVC: View Did Load!")
        
        
        // Observe user via Auth shared instance
        Auth.sharedInstance.observeUser { authEvent in
            print("HooksReceivedVC: observed the user \(authEvent) thanks to Auth.sharedInstance")
            
            // Switch on the auth event (execute code depending if user signed in or not)
            switch authEvent {
               
            // SIGNED IN
            case .observedSignedIn:
                
                print("HooksReceivedVC: \(Auth.sharedInstance.user?.displayName) is the user observed signed in")
                
                // HooksArray initialization and Observation
                
                // Check if the user is not nil (should never be else since just observed signed in) - still that check is kept for robustness
                if let user = Auth.sharedInstance.user {
    
                    // Create a ref to the user's hooks received
                    let userHooksReceivedRef = FIRDatabase.database().reference().child("users/\(user.uid)/hooksReceived")
                    // Init the array of hooks based on that ref
                    self.hooksReceivedArray = HooksArray(hooksAtRef: userHooksReceivedRef)
                    
                    // Observe the hooksArray and react accordingly
                    self.hooksReceivedArray?.observeFirebaseHooks { type in
                        print("HooksReceivedVC: hook event observed. Event type: \(type)")
                        self.tableView.reloadData()
                    }
                    
                }
                
            // SIGNED OUT
            case .observedSignedOut:
                print("HooksReceivedVC: user is signed out \(Auth.sharedInstance.user) ")
                
                // HooksArray reset to nil
                self.hooksReceivedArray = nil
                
            }
            
            
        }
    
    }
    
    
    
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        // Reload the table view when view appears (Implies - for e.g. - that the aging of hooks gets refreshed in the cells)
        self.tableView.reloadData()
        
    }
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.hooksReceivedArray?.content.count ?? 0
    }

    
    // Row Height = 100px
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HookReceivedCell", for: indexPath) as! HookReceivedTableViewCell

        if self.hooksReceivedArray != nil {
            
            // Configure the cell...
            // Get the hook object at stake for that cell
            let hook = self.hooksReceivedArray!.content[indexPath.row]
            
            // Customize the cell
            
            // Label
            cell.label.text = "\(hook.senderUserDisplayName) hooked your item. \(hook.getAgingAsString())"
            
            // Sender User Profile photo
            if hook.senderUserPhotoURL != nil {
                cell.senderUserPhoto.sd_setImage(with: URL(string: hook.senderUserPhotoURL!))
            } else {
                print("HooksReceivedVC: No Sender User Photo Available")
            }
            
            
            // Item hooked image thumbnail
            
            cell.hookedItemImageThumbnail.image = hook.hookedItemImageThumbnail
            
        }
        
        return cell
    }

    // User did select cell shall trigger navigation to the hook sender profile
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("User did select cell at index row \(indexPath.row)")
        
        // Get the hook item concerned
        let hookSelected = self.hooksReceivedArray?.content[indexPath.row]
        // Get the UID of the sender of that hook
        let senderUserUID = hookSelected?.senderUserUID
        
        // Optional binding
        if let senderUID = senderUserUID {
            
            // Create a Profile View Controller and configure it to display the hook sender profile
            let senderProfileViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ProfileViewControllerID") as! ProfileViewController
            // Configure the target view controller
            senderProfileViewController.presentedUserUID = senderUID
            senderProfileViewController.selfIsUserProfile = false
            
            // Push the target view controller in the navigation controller stack
            self.navigationController?.pushViewController(senderProfileViewController, animated: true)
            
        }
        
        
    }
    


}
