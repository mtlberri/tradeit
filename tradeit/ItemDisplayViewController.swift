import UIKit
import Firebase

class ItemDisplayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    
    // MARK: Properties
    var itemToDisplay: Item?
    
    // Firebase storage reference
    let imagesRef = FIRStorage.storage().reference(forURL: "gs://tradeit-99edf.appspot.com/").child("images")
    
    // MARK: METHODS
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("Display item description in the view")
        self.itemDescription.text = self.itemToDisplay?.description
        
        print("Start loading of item image")
        self.itemToDisplay?.downloadImage(kind: .original, atFBStorageRef: imagesRef) { error in
            // completion block
            if error == nil {
                print("item image downloaded successfully!")
                print("set the image in the view!")
                self.itemImage.image = self.itemToDisplay?.image
            } else {
                print("item image download failed with error: \(error)")
            }
            
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
