import Foundation
import UIKit
import Firebase

enum ImageKind {
    case original
    case thumbnail
}

class Item {
    
    // MARK : Properties
    // METADATA
    // Item key (Firebase key)
    var key: String?
    // Description of the item being traded
    var description: String?
    // Tags to search for that item
    var tags: [String]?
    // Image path (in Google Cloud Storage) - starting at /images/
    var imagePath: String?
    // Image thumbnail path (in Google Cloud Storage) - starting at /images/
    var imageThumbnailPath: String?
    
    // IMAGES
    var image: UIImage?
    // Image thumbnail
    var imageTumbnail: UIImage?


    // MARK : Methods
    
    // Method to post item METADATA in Firebase
    func uploadMetadata (atFBDBRef ref: FIRDatabaseReference, withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> Void {
        
        // If no key, Go create a auto child Id and get corresponding key (else just keep existing key for that item)
        if self.key == nil {
            self.key = ref.childByAutoId().key
            print("Item key is created in prep of METADATA upload: \(self.key)")
        } else {
            print("Item key is already existing and re-used for METADATA update: \(self.key)")
        }
        
        
        // Create a Dictionary for transfer to Firebase DB
        let dic: [String: Any] = [
            "key": self.key!,
            "description": self.description ?? "",
            "tags": self.tags ?? ["items"],
            "imagePath": self.imagePath ?? "",
            "imageThumbnailPath": self.imageThumbnailPath ?? ""
        ]
        print("Created the following Dictionary in prep of upload:")
        print(dic)
        
        // Create the child item that will be updated in the Firebase DB
        let childUpdate = ["\(self.key!)": dic]
        
        // Update the entry in Firebase
        ref.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            if error == nil {
                print("Item method says: Upload of item METADATA \(self.key!) in Firebase DB successfully completed!")
                // Completion block with error nil
                completion(error)
            } else {
                print("Item method says: Oops an error occured while uploading Item METADATA to Firebase:")
                print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                // Completion block with error
                completion(error)
            }
        })
        
    }
    
    // Method to upload an image of the item in Firebase Storage (whatever the kind of image enum ImageKind)
    func uploadImage (kind: ImageKind, atFBStorageRef refS: FIRStorageReference, syncedWithFBDRRef refD: FIRDatabaseReference ,withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> FIRStorageUploadTask? {
        
        var uploadTask: FIRStorageUploadTask?
        var imageAtStake: UIImage?
        
        // Look at the kind of image to upload and assign the image at stake to dedicated variable
        switch kind {
        case .original:
            imageAtStake = self.image
        case .thumbnail:
            imageAtStake = self.imageTumbnail
        }
        
        // Check if image is not nil, and if its data conversion is not nil,
        if let imageToUpload = imageAtStake, let dataToUpload = UIImageJPEGRepresentation(imageToUpload, 1.0), let itemKey = self.key {
            
                print("All conditions OK to start upload of \(kind) image of item \(itemKey)")
            
                // the image path depends on the kind of image
                var myImagePath: String = ""
                switch kind {
                case .original:
                    myImagePath = "\(itemKey).jpg"
                case .thumbnail:
                    myImagePath = "\(itemKey)_thumbnail.jpg"
                }
            
                uploadTask = refS.child(myImagePath).put(dataToUpload, metadata: nil) { (metadata, error) in
                        if error == nil {
                            print("Item method says: Upload of \(kind) image \(itemKey) in Firebase Storage successfully completed!")
                            // Now that upload is complete, Set the path for image (depending on kind)
                            switch kind {
                            case .original:
                                self.imagePath = myImagePath
                            case .thumbnail:
                                self.imageThumbnailPath = myImagePath
                            }
                            // And load that update into Firebase DB
                            self.uploadMetadata(atFBDBRef: refD) { error in
                                if error == nil {
                                    print("Successfully updated the synced Firebase DB Ref \(itemKey) with image path \(myImagePath)")
                                } else {
                                    print("Failed to update the synced Firebase DB Ref \(itemKey) with image path \(myImagePath)")
                                }
                            }
                            // Completion block with error nil
                            completion(error)
                        } else {
                            print("Item method says: Upload of \(kind) Image \(itemKey) in Firebase Storage failed!")
                            print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                            // Completion block with error
                            completion(error)
                        }
                }
        
        }
        // Return upload task
        return uploadTask

        
    }
    
    // Method to create the thumbnail
    func createThumbnail() -> Bool {
        
        print("Creation of thumbnail starts...")
        // Print original image data size
        if let originalImage = self.image, let originalImageData = UIImageJPEGRepresentation(originalImage, 1.0) {
            print("Original image data size is: \(Float(originalImageData.count) / 1024.0)")
        }
        
        // Check that: image is existing, can be compressed 0.0 into data object, and that it can be converted back in an image
        if let originalImage = self.image, let compressedImageData = UIImageJPEGRepresentation(originalImage, 0.0), let compressedImage = UIImage(data:compressedImageData)  {
            
            // set the compressed image in the object dedicated property
            self.imageTumbnail = compressedImage
            print("Thumbnail of item \(self.key) successfully created!")
            print("Thumbnail image data size is: \(Float(compressedImageData.count) / 1024.0)")
            return true
        } else {
            print("Thumbnail of item \(self.key) creation failed")
            return false
        }
    }
    
    
    
    
    
    
    
}
