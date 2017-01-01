import UIKit
import Firebase
import SDWebImage

class HooksReceivedTableViewController: UITableViewController {


    // MARK: Properties
    var hooksReceivedArray: HooksArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HooksReceivedVC: View Did Load!")
        
        // Check if the user is signed in
        if let user = FIRAuth.auth()?.currentUser {
            
            // Create a ref to the user's hooks received
            let userHooksReceivedRef = FIRDatabase.database().reference().child("users/\(user.uid)/hooksReceived")
            // Init the array of hooks based on that ref
            self.hooksReceivedArray = HooksArray(hooksAtRef: userHooksReceivedRef)
            
            // Observe the hooksArray and react accordingly
            self.hooksReceivedArray.observeFirebaseHooks { (type, index) in
                print("HooksReceivedVC: hook event observed. Event type: \(type), at index: \(index)")
                self.tableView.reloadData()
                
            }
            
            
            
            
            
        } else {
            print("HooksReceivedVC: No User signed in... please sign in!")
        }
        

        
        
    }
    
    
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.hooksReceivedArray.content.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HookReceivedCell", for: indexPath) as! HookReceivedTableViewCell

        // Configure the cell...
        // Get the hook object at stake for that cell
        let hook = self.hooksReceivedArray.content[indexPath.row]
        
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
        
        // Check if the hooked item image thumbnail needs to be downloaded
        if hook.hookedItemImageThumbnail == nil {
            hook.downloadHookedItemImageThumbnail { error in
                if error == nil {
                    print("HooksReceivedVC: Successfully downloaded hooked item image thumbnail. Reload View!")
                    // Completion Block for hooked item image thumbnail
                    self.tableView.reloadData()
                } else {
                    print("HooksReceivedVC: Failed downloading hooked item image thumbnail with error: \(error)")
                }
            }
            
        } else {
            print("HooksReceivedVC: hook hooked item image thumbnail already existing")
        }
        
        cell.hookedItemImageThumbnail.image = hook.hookedItemImageThumbnail
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
