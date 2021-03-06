import Foundation
import UIKit
import Firebase
import SDWebImage

// Hook class created to represent a hook from a sender user to an item being owned by another user

class Hook {
    
    // MARK: Properties
    
    let hookKey: String
    let dateAndTimeOfCreation: Date
    
    // Sender User
    let senderUserUID: String
    let senderUserDisplayName: String
    var senderUserPhotoURL: String?
    var senderUserPhoto: UIImage?
    
    // Hooked Item
    let hookedItemKey: String
    let hookedItemOwnerUID: String
    var hookedItemImageThumbnailPath: String?
    var hookedItemImageThumbnail: UIImage?
    
    // MARK: Designated Initializer
    init(hookKey: String,
        dateAndTimeOfCreation: Date,
        
        senderUserUID: String,
        senderUserDisplayName: String,
        senderUserPhotoURL: String?,
        senderUserPhoto: UIImage?,
        
        hookedItemKey: String,
        hookedItemOwnerUID: String,
        hookedItemImageThumbnailPath: String?,
        hookedItemImageThumbnail: UIImage?
        ) {
        
        self.hookKey = hookKey
        self.dateAndTimeOfCreation = dateAndTimeOfCreation
        
        // Sender User
        self.senderUserUID = senderUserUID
        self.senderUserDisplayName = senderUserDisplayName
        self.senderUserPhotoURL = senderUserPhotoURL
        self.senderUserPhoto = senderUserPhoto
        
        // Hooked Item
        self.hookedItemKey = hookedItemKey
        self.hookedItemOwnerUID = hookedItemOwnerUID
        self.hookedItemImageThumbnailPath = hookedItemImageThumbnailPath
        self.hookedItemImageThumbnail = hookedItemImageThumbnail
        
    }
    
    // MARK: Convenience Initializers
    // MARK: Convenience Initializer based on Item, and senderUser
    convenience init (_ item: Item, sentByUser: FIRUser, creationDate: Date) {
        
        // Create the hook key by using childByAutoId on the item/hooks ref
        let generatedHookKey = Item.refD.child("items/\(item.key)/hooks").childByAutoId().key
        
        // Call the designated initializer
        self.init(hookKey: generatedHookKey,
                  dateAndTimeOfCreation: creationDate,
                  
                  senderUserUID: sentByUser.uid,
                  senderUserDisplayName: sentByUser.displayName ?? "unnamed user",
                  senderUserPhotoURL: sentByUser.photoURL?.absoluteString,
                  senderUserPhoto: nil,
                  
                  hookedItemKey: item.key,
                  hookedItemOwnerUID: item.ownerUID,
                  hookedItemImageThumbnailPath: item.imageThumbnailPath,
                  hookedItemImageThumbnail: nil)
        
    }
    
    // MARK: Convenience Initializer based on NSDictionary (most of the time coming from a Firebase Snapshot)
    convenience init (withNSDictionary dic: [String: String]) {
        
        // Customize a dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        // Call the designated initializer based on the dictionary values
        self.init(hookKey: dic["hookKey"] ?? "hookKeyNotFound",
                  dateAndTimeOfCreation: dateFormatter.date(from: dic["dateAndTimeOfCreation"] ?? "") ?? Date(),
                  
                  senderUserUID: dic["senderUserUID"] ?? "senderUserUIDNotFound",
                  senderUserDisplayName: dic["senderUserDisplayName"] ?? "senderUserDisplayNameNotFound",
                  senderUserPhotoURL: dic["senderUserPhotoURL"], // Optional
                  senderUserPhoto: nil,
                  
                  hookedItemKey: dic["hookedItemKey"] ?? "hookedItemKeyNotFound",
                  hookedItemOwnerUID: dic["hookedItemOwnerUID"] ?? "hookedItemOwnerUIDNotFound",
                  hookedItemImageThumbnailPath: dic["hookedItemImageThumbnailPath"], // Optional
                  hookedItemImageThumbnail: nil)
        
    }
    
    
    
    // MARK: Upload methods
    
    func uploadMetadata(withCompletionBlock completion: @escaping (_ error: Error?) -> Void) ->Void {
        
        print("Entering the uploadMetadata method for hook \(self.hookKey)")
        // Get the itemUser
        
        // Customize a dateFormatter
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        let stringDateAndTime = dateFormatter.string(from: self.dateAndTimeOfCreation)
        print("Date used is going to be \(stringDateAndTime)")
        
        // Create a Dictionary for transfer to Firebase DB
        let dic: [String: String] = [
            
            "hookKey": self.hookKey,
            "dateAndTimeOfCreation": stringDateAndTime,
            
            // Sender User
            "senderUserUID": self.senderUserUID,
            "senderUserDisplayName": self.senderUserDisplayName,
            "senderUserPhotoURL": self.senderUserPhotoURL ?? "",
            
            // Hooked Item
            "hookedItemKey": self.hookedItemKey,
            "hookedItemOwnerUID": self.hookedItemOwnerUID,
            "hookedItemImageThumbnailPath": self.hookedItemImageThumbnailPath ?? ""
        ]
        
        print("Created the following Dictionary in prep for hook upload:")
        print(dic)
        
        // Create the child item that will be updated in the Firebase DB. Atomic update at three locations: items, hook sender user, item owner user.
        let childUpdate = ["items/\(self.hookedItemKey)/hooks/\(self.hookKey)": dic,
                           "users/\(self.hookedItemOwnerUID)/hooksReceived/\(self.hookKey)": dic,
                           "users/\(self.senderUserUID)/hooksSent/\(self.hookKey)": dic
                           
        ]
        
        // Update the entries in Firebase
        Item.refD.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            if error == nil {
                print("Hook method says: Upload of hook METADATA \(self.hookKey) in Firebase DB successfully completed!")
                // Completion block with error nil
                completion(error)
            } else {
                print("Hook method says: Oops an error occured while uploading Hook METADATA to Firebase:")
                print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                // Completion block with error
                completion(error)
            }
        })
        
    }
    
    // Remove metadata (delete hook from Firebase)
    func removeMetadata(withCompletionBlock completion: @escaping (_ error: Error?) -> Void) ->Void {
        
        // Create the child item that will be removed in the Firebase DB. Atomic removal at three locations: items, hook sender user, item owner user.
        let childUpdate = ["items/\(self.hookedItemKey)/hooks/\(self.hookKey)" : nil ,
                           "users/\(self.senderUserUID)/hooksSent/\(self.hookKey)" : nil,
                           "users/\(self.hookedItemOwnerUID)/hooksReceived/\(self.hookKey)" : nil,
                           "dummyNode": ""
        ]
        
        // Delete the entries in Firebase
        Item.refD.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            if error == nil {
                print("Hook method says: Removal of hook METADATA \(self.hookKey) in Firebase DB successfully completed!")
                // Completion block with error nil
                completion(error)
            } else {
                print("Hook method says: Oops an error occured while removing Hook METADATA to Firebase:")
                print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                // Completion block with error
                completion(error)
            }
        })
        
    }
    
    // MARK: Download methods
    
    func downloadHookedItemImageThumbnail (withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> Void {
        

        // Check if image path is not nil
        if let path = self.hookedItemImageThumbnailPath {
            
            print("All conditions OK to start download of \(self.hookKey) item image thumbnail")
            
            let imageRef: FIRStorageReference = Item.refS.child("\(path)")
            print("Download reference is using path: images/\(path)")
            
            // Download data in memory with max size 10MB (10 * 1024 * 1024 bytes)
            imageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) in
                
                if error == nil {
                    // set the thumbnail image of the item being hooked
                    self.hookedItemImageThumbnail = UIImage(data: data!)
                    print("At Hook level: image thumbnail has been downloaded for hook \(self.hookKey)")
                    // completion block called with error nil
                    completion(error)
                    } else {
                    print("At Hook level: Huh-Oh Error while downloading thumbnail image for hook \(self.hookKey)")
                    print("At Hook level, error is: \(error?.localizedDescription)")
                    // completion block called with error
                    completion(error)
                }
            }
            
            
        } else {
            print("At Hook level: image thumbnail path is nil. No item thumbnail image will be downloaded.")
        }
        
    }
    
    
    
    // MARK: Other methods
    
    // Method that returns the aging of the hook as a string
    func getAgingAsString () -> String {
        
        // Customize a dateFormatter
        // let dateFormatter = DateFormatter()
        // dateFormatter.dateStyle = .medium
        // dateFormatter.timeStyle = .medium
        
        print("Hook date and time of creation is: \(self.dateAndTimeOfCreation)")
        
        let rawAging = -self.dateAndTimeOfCreation.timeIntervalSinceNow
        
        switch rawAging {
        case 0..<60:
            return String(Int(rawAging)) + "s"
        case 60..<3600:
            return String(Int(rawAging/60)) + "m"
        case 3600..<86400:
            return String(Int(rawAging/3600)) + "h"
        default:
            return String(Int(rawAging/86400)) + "d"
            
        }
        
    }
    
    
    
    
    
}

// Extension to add conformance to the Comparable protocol (and sort Hooks per date and time
extension Hook: Comparable {
    
    // Hooks ordering is based on time of creation
    static func <(lhs: Hook, rhs: Hook) -> Bool {
        return lhs.dateAndTimeOfCreation < rhs.dateAndTimeOfCreation
    }
    
    // Two hooks are considered equal if they have the same key
    static func ==(lhs: Hook, rhs: Hook) -> Bool {
        return lhs.hookKey == rhs.hookKey
    }
    
    
}





