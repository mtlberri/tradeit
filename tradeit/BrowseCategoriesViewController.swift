import UIKit

class BrowseCategoriesViewController: UIViewController{
    
   // Property observer
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    
        // Observe user
        Auth.sharedInstance.observeUser { authEvent in
            print("Browse Catgerories VC: observed the user \(authEvent)")
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    


}

