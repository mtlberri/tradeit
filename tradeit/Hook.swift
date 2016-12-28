import Foundation
import UIKit
import FirebaseStorage

// Hook class created to represent a hook from a sender user to an item being owned by another user
class Hook {
    
    // Mark: Properties
    
    let hookKey: String
    let dateAndTimeOfCreation: NSDate
    
    // Sender User
    let senderUserUID: String
    let senderUserDisplayName: String
    let senderUserPhotoURL: String?
    let senderUserPhoto: UIImage?
    
    // Hooked Item
    let hookedItemKey: String
    let hookedItemImageRef: FIRStorageReference?
    let hookedItemImage: UIImage?
    
    // Initializer
    init(hookKey: String, senderUserUID: String) {
        
        self.hookKey = hookKey
        self.dateAndTimeOfCreation = NSDate()
        
        // Sender User 
        self.senderUserUID = senderUserUID
        
        
        
    }
    
    
    
    
}
