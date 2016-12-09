import Foundation
import UIKit
import Firebase

class Item {
    
    // MARK : Properties
    
    // METADATA
    // Item key (Firebase key)
    var key: String?
    // Description of the item being traded
    var description: String?
    // Tags to search for that item
    var tags: [String]?
    // Image path (in Google Cloud Storage) - starting at /images/
    var imagePath: String?
    // Image thumbnail path (in Google Cloud Storage) - starting at /images/
    var imageThumbnailPath: String?
    
    // IMAGES
    var image: UIImage?
    // Image thumbnail
    var imageTumbnail: UIImage?


    // MARK : Methods
    
    // Method to post item METADATA in Firebase
    func uploadMetadata (atFBRef ref: FIRDatabaseReference, withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> Void {
        
        // Go create a auto child Id and get corresponding key
        self.key = ref.childByAutoId().key
        print("Item key is created to be: \(self.key)")
        
        // Create a Dictionary for transfer to Firebase DB
        let dic: [String: Any] = [
            "key": self.key!,
            "description": self.description ?? "",
            "tags": self.tags ?? ["items"],
            "imagePath": self.imagePath ?? "",
            "imageThumbnailPath": self.imageThumbnailPath ?? ""
        ]
        print("Created the following Dictionary in prep of upload:")
        print(dic)
        
        // Create the child item that will be updated in the Firebase DB
        let childUpdate = ["\(self.key!)": dic]
        print("Child update that is going to be pushed in Firebase is:")
        print(childUpdate)
     
        
        
        // Update the entry in Firebase
        ref.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            if error == nil {
                print("Item method says: Upload of item \(self.key) in Firebase DB successfully completed!")
                // Completion block with error nil
                completion(error)
            } else {
                print("Item method says: Oops an error occured while uploading Item METADATA to Firebase:")
                print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                // Completion block with error
                completion(error)
            }
        })

        
        
        
    }
    
}
