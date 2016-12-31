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
    
    
    // Observe Child Added and append to the content
    
    // Observe Child Removed and remove from content
    
    // Observer Child Changed and update in the content
    
    
    
}
