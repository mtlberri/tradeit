import Foundation
import Firebase

class ItemsArray: NSObject {
    // content (array itself)
    var content: [Item] = []
    
    // MARK: Initializer
    init(withMetadataFromFBRef ref: FIRDatabaseReference, completionHandler: @escaping () -> Void) {
        
        // Call up to NSObject initializer
        super.init()
        
        // read Firebase data once and fill the content based on data retrieved
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            // create a NSDictionary with all elements in the snasphot of the ref
            let snapshotDictionary = snapshot.value as? NSDictionary
            
            // if that snapshotDictionary is not nil, use it
            if let dictionary = snapshotDictionary {
                
                // For each element in the dictionary, create the corresponding Item object and append it to the self.content Array
                for element in dictionary {
                    
                    print("Entering the loop to create 'ItemsArray' object based on firebase element:")
                    print(element.value)
                    
                    // element NSDictionary
                    let elementNSDictionary = element.value as! NSDictionary
                    
                    // new Item object
                    let itemToAppend = Item()
                    
                    // Populate the itemToAppend with FB Database element values
                    itemToAppend.key = elementNSDictionary["key"] as? String
                    itemToAppend.description = elementNSDictionary["description"] as? String
                    itemToAppend.tags = elementNSDictionary["description"] as? [String]
                    itemToAppend.imagePath = elementNSDictionary["imagePath"] as? String
                    itemToAppend.imageThumbnailPath = elementNSDictionary["imageThumbnailPath"] as? String
                    print("For item \(itemToAppend.key): Successfully set properties: key, description, tags, imagePath, imageThumbnailPath")
                    
                    // Append the item to the array
                    self.content.append(itemToAppend)
                    print("For item \(itemToAppend.key): Appended the item to the itemsArray.content")
                    
                }
                // Calling the escaping completion handler after init() completed
                print("Calling the escaping completion handler after ItemsArray init() completed")
                completionHandler()
            }

        })

    }
    
    // MARK: Methods
    // Method to load thumbnails
    func loadThumbnails (atFBStorageRef refS: FIRStorageReference, withUnitaryThumbnailUploadCompletionBlock completionOfUnite: @escaping (_ error: Error?) -> Void) -> Void {
        
        print("Entering the method to load thumbnails")
        
        // For every item of the array, load the thumbnail (if exisitng) and call the unitary completion block to alert upon completion
        for item in self.content {
            print("Entering the loop for item \(item.key)")
            
            // Download image of the item
            // Warning because download task returned is no used (OK - no problem)
            item.downloadImage(kind: .thumbnail, atFBStorageRef: refS) { (error) in
                
                if error == nil {
                    print("At Items Array level: One Image Thumbnail \(item.key) successfully downloaded")
                    // Completion of unit called with error nil
                    completionOfUnite(error)
                } else {
                    print("At Items Array level: One Image Thumbnail \(item.key) failed download")
                    // Completion of unit called with error
                    completionOfUnite(error)
                }
            }
    
        }
        
    }
    
}
