import Foundation
import UIKit

class Item {
    
    // Item key (Firebase key)
    var key: String?
    
    // Description of the item being traded
    var description: String?
    
    // Tags to search for that item
    var tags: [String]?
    
    // Image
    var image: UIImage?
    // Image path (in Google Cloud Storage) - starting at /images/
    var imagePath: String?
    
    // Image thumbnail
    var imageTumbnail: UIImage?
    // Image thumbnail path (in Google Cloud Storage) - starting at /images/
    var imageThumbnailPath: String?

    
}
