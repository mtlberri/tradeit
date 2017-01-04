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
    
    // MARK: Methods
    
    // Observe Child hooks in Firebase and keep the content in sync, while calling a completion block after each event
    func observeFirebaseHooks (withBlock: @escaping (_ eventType: HookEventType) -> Void) -> Void {
        
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
                    // Sort the content per decreasing Date and Time of creation (most recent first)
                    self.content.sort(by: >)
                    // call withBlock with appropriate arguments
                    withBlock(HookEventType.added)
                }
                
            } else {
                print("HooksArray: Error with Firebase snapshot conversion into [String: String]")
            }
        })
        
        
        
        
        // Observe Child Removed and remove from content
        self.refD.observe(.childRemoved, with: { snapshot in
            print("HooksArray: Observed hook removed in Firebase: \(snapshot.value)")
            // Check if the snapshot convertion to [String: String] is not nil
            if let dic = snapshot.value as? [String: String] {
                // Create the hook with convenience initializer
                let removedHook = Hook(withNSDictionary: dic)
                print("HooksArray: created the removedHookObject \(removedHook.hookKey)")
                // Remove the hook metadata in Firebase
                removedHook.removeMetadata() { error in
                    if error == nil {
                        print("HooksArray: Successfully removed hook metadata")
                        // Remove the hook from content
                        if let indexOfRemovedHook = self.content.index(of: removedHook) {
                            self.content.remove(at: indexOfRemovedHook)
                        } else {
                            print("HooksArray: Huh Oh, the hook removed in Firebase was not found in the array content...")
                        }
                        
                        // Sort the content per decreasing Date and Time of creation (most recent first)
                        self.content.sort(by: >)
                        // call withBlock with appropriate arguments
                        withBlock(HookEventType.removed)
                    } else {
                        print("HooksArray: Failed removal of hook metadata")
                    }
                    
                }
            } else {
                print("HooksArray: Error with Firebase snapshot conversion into [String: String]")
            }
        })
        
        
        
    }
    
    // Make an array of sender display names based on the array of hooks
    func makeHookSendersUIDAndDisplayNamesArray () -> [(UID: String, DisplayName: String)] {
        
        var result: [(UID: String, DisplayName: String)] = []
        
        // Loop over the array of hooks to populate the array of sender names
        for hook in self.content {
            result.append((UID: hook.senderUserUID, DisplayName: hook.senderUserDisplayName))
        }
        
        return result
    }
    

    
    
    
}

// Enumeration to list the different types of event for HooksArray content based on Firebase events
enum HookEventType {
    
    case added
    case removed
    case updated
    
}


