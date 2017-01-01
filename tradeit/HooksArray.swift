import Foundation
import Firebase


// HooksArray will need to subclass NSObject in order to enable KVO on content (for the using View Controller)

class HooksArray {
    
    
    // MARK: Properties
    
    // content (array itself)
    var content: [Hook] = []
    
    // Firebase reference at which the hooks array is synced
    var refD: FIRDatabaseReference
    
    
    // Initializer
    init(hooksAtRef ref: FIRDatabaseReference) {
        self.refD = ref
    }
    
    
    // Observe Child hooks in Firebase and keep the content in sync, while calling a completion block after each event
    func observeFirebaseHooks (withBlock: @escaping (_ eventType: HookEventType, _ atIndexPath: IndexPath) -> Void) -> Void {
        
        // Observe hook added to Firebase and append to content
        self.refD.observe(.childAdded, with: { snapshot in
            
            
            print("HooksArray: Observed hook added in Firebase: \(snapshot.value)")
            // Check if the snapshot convertion to [String: String] is not nil
            if let dic = snapshot.value as? [String: String] {
                
                // Create the hook with convenience initializer
                let addedHook = Hook(withNSDictionary: dic)
                print("HooksArray: created the addedHookObject \(addedHook.hookKey)")
                
                
                // Download the hooked item image thumbnail
                addedHook.downloadHookedItemImageThumbnail { error in
                    if error == nil {
                        print("HooksArray: Successfully downloaded addedHookObject item image thumbnail.")
                        
                    } else {
                        print("HooksReceivedVC: Failed downloading hooked item image thumbnail with error: \(error)")
                    }
                    
                    // Append to the content
                    self.content.append(addedHook)
                    
                    // call withBlock with appropriate arguments
                    withBlock(HookEventType.added, IndexPath(row: self.content.count - 1, section: 0))
                    
                }
                
            } else {
                print("HooksArray: Error with Firebase snapshot conversion into [String: String]")
            }
            
            
            
        })
        
        
        
        
        // Observe Child Removed and remove from content
        
        
        
        
        // Observer Child Changed and update in the content
        
        
        
    }
    

    
    
    
}

// Enumeration to list the different types of event for HooksArray content based on Firebase events
enum HookEventType {
    
    case added
    case removed
    case updated
    
}


