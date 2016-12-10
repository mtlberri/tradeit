import UIKit
import Firebase

class ItemDisplayViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemDescription: UITextView!
    @IBOutlet weak var progressView: UIProgressView!
    
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
        let downloadTask = self.itemToDisplay?.downloadImage(kind: .original, atFBStorageRef: imagesRef) { error in
            // completion block
            if error == nil {
                print("At view controller level: item image downloaded successfully!")
                print("set the image in the view! (and hide progress bar)")
                self.itemImage.image = self.itemToDisplay?.image
                self.progressView.isHidden = true
            } else {
                print("item image download failed with error: \(error)")
            }
            
        }
        
        // Monitoring download progress
        downloadTask?.observe(.progress, handler: { snapshot in
            if let progress = snapshot.progress {
                let percentComplete = Double(progress.completedUnitCount) / Double(progress.totalUnitCount)
                self.progressView.progress = Float(percentComplete)
                print("Upload progressed: percent complete = \(percentComplete)")
            }
        })
        
        
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
