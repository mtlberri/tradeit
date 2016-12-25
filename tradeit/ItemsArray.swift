import Foundation
import Firebase

class ItemsArray: NSObject {
    // content (array itself)
    var content: [Item] = []
    
    // MARK: Download Items Array Metadada
    func downloadMetadata(withMetadataFromFBRef ref: FIRDatabaseReference, completionHandler: @escaping () -> Void) {

        
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
                    
                    // Check that the FIR data present the minimum valid data to create an Item object (key and ownerUID)
                    let elementDataValid: Bool = elementNSDictionary["key"] != nil && elementNSDictionary["ownerUID"] != nil
                    
                    if elementDataValid {
                        
                        // init the item to append
                        let itemToAppend = Item(key: elementNSDictionary["key"] as! String, ownerUID: elementNSDictionary["ownerUID"] as! String)
 
                        // update the item to append metadat based on the elementNSDictionary
                        itemToAppend.updateMetadataUsingNSDictionary(elementNSDictionary)         
                        
                        
                        // Append the item to the array
                        self.content.append(itemToAppend)
                        print("For item \(itemToAppend.key): Appended the item to the itemsArray.content")

                    } else {
                        print("No Valid data from FIRDB to create an Item")
                    }
                    
                    
                }
                // Calling the escaping completion handler after init() completed
                print("Calling the escaping completion handler after ItemsArray init() completed")
                completionHandler()
            }

        })

    }
    
    // MARK: Methods
    // Method to download thumbnails
    func downloadThumbnails (withUnitaryThumbnailUploadCompletionBlock completionOfUnite: @escaping (_ error: Error?) -> Void) -> Void {
        
        print("Entering the method to load thumbnails")
        
        // For every item of the array, load the thumbnail (if exisitng) and call the unitary completion block to alert upon completion
        for item in self.content {
            print("Entering the loop for item \(item.key)")
            
            // Download image of the item
            // Warning because download task returned is no used (OK - no problem)
            item.downloadImage(kind: .thumbnail) { (error) in
                
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
