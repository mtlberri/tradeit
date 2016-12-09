import Foundation
import Firebase

class ItemsArray: NSObject {
    // content (array itself)
    var content: [Item] = []
    // to monitor when metadata init process is completed (depending on FB data reading) ("dynamic" enables observation)
    dynamic var metadataInitCompleted = false
    
    // Initializer
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
                print("Items Array metadata initialization is now completed! with \(self.content.count) elements")
                self.metadataInitCompleted = true
                print("TEST")
                // Calling the escaping completion handler after init(), passing value true
                completionHandler()
                
            }
        })
        { (error) in
            print("Oops, following errror occured while trying to build ItemsArray object metadata from FB: \(error.localizedDescription)")
        }
        
    }
    
}
