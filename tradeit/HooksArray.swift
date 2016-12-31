import Foundation
import Firebase

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
    
    
    
    
    
    
    
    
}
