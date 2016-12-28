import Foundation
import UIKit
import Firebase

// For use in the image upload method
enum ImageKind {
    case original
    case thumbnail
}
// For use in the thumbnail creation method
enum ThumbnailCreationError: Error {
    case failed
}

class Item {
    
    // MARK : Properties
    
    // METADATA
    // Item key (Firebase key)
    var key: String
    // Item Owner UID
    var ownerUID: String
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
    
    // Firebase refs (Type properties)
    static let refD = FIRDatabase.database().reference()
    static let refS = FIRStorage.storage().reference().child("images")


    // Initialization method
    init(key: String, ownerUID: String) {
        self.key = key
        self.ownerUID = ownerUID
    }
    
    // MARK: Upload Methods
    
    // Method to post item METADATA in Firebase
    func uploadMetadata (withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> Void {
        
        // Create a Dictionary for transfer to Firebase DB
        let dic: [String: Any] = [
            "key": self.key,
            "ownerUID": self.ownerUID,
            "description": self.description ?? "",
            "tags": self.tags ?? ["items"],
            "imagePath": self.imagePath ?? "",
            "imageThumbnailPath": self.imageThumbnailPath ?? ""
        ]
        print("Created the following Dictionary in prep of upload:")
        print(dic)
        
        // Create the child item that will be updated in the Firebase DB. Atomic update at two locations: items, and userItems.
        let childUpdate = ["items/\(self.key)": dic,
                           "users/\(self.ownerUID)/userItems/\(self.key)": dic
                           ]
        
        // Update the entries in Firebase
        Item.refD.updateChildValues(childUpdate, withCompletionBlock: { (error: Error?, ref: FIRDatabaseReference) -> Void in
            if error == nil {
                print("Item method says: Upload of item METADATA \(self.key) in Firebase DB successfully completed!")
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
    func uploadImage (kind: ImageKind, withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> FIRStorageUploadTask? {
        
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
        if let imageToUpload = imageAtStake, let dataToUpload = UIImageJPEGRepresentation(imageToUpload, 1.0) {
            
                print("All conditions OK to start upload of \(kind) image of item \(self.key)")
            
                // the image path depends on the kind of image
                var myImagePath: String = ""
                switch kind {
                case .original:
                    myImagePath = "\(self.key).jpg"
                case .thumbnail:
                    myImagePath = "\(self.key)_thumbnail.jpg"
                }
            
                uploadTask = Item.refS.child(myImagePath).put(dataToUpload, metadata: nil) { (metadata, error) in
                        if error == nil {
                            print("Item method says: Upload of \(kind) image \(self.key) in Firebase Storage successfully completed!")
                            // Now that upload is complete, Set the path for image (depending on kind)
                            switch kind {
                            case .original:
                                self.imagePath = myImagePath
                            case .thumbnail:
                                self.imageThumbnailPath = myImagePath
                            }
                            // And load that update into Firebase DB
                            self.uploadMetadata() { error in
                                if error == nil {
                                    print("Successfully updated the synced Firebase DB Ref \(self.key) with image path \(myImagePath)")
                                    //Completion Block, error nil
                                    completion(error)
                                } else {
                                    print("Failed to update the synced Firebase DB Ref \(self.key) with image path \(myImagePath)")
                                    //Completion Block, error
                                    completion(error)
                                }
                            }
                        } else {
                            print("Item method says: Upload of \(kind) Image \(self.key) in Firebase Storage failed!")
                            print(error?.localizedDescription ?? "No localized description available for this error. Sorry.")
                            // Completion block with error
                            completion(error)
                        }
                }
            
        }
        // Return upload task
        return uploadTask

        
    }
    

    
    // Wrap-Up Method for overall upload
    func upload (withCompletionBlock completion: @escaping (_ errorsArray: [Error?]) -> Void) -> FIRStorageUploadTask? {
        
        var overallErrorsArray: [Error?] = []
        let originalImageUploadTask: FIRStorageUploadTask?
        
        // Tracker of completed tasks
        let totalNumberOfTasks = 4
        var completedTasks: [String] = [] {
            didSet {
                print("The following task are completed: \(completedTasks)")
                print("\(completedTasks.count) / \(totalNumberOfTasks)")
                
                if completedTasks.count == totalNumberOfTasks {
                    // Completion Handler is passed the array of Errors?
                    completion(overallErrorsArray)
                }
                
            }
        }
        
        
        // TASK#1: Upload the item METADA and use the completion block to know if error
        self.uploadMetadata() { (error) in
            // Add the completed task to the tracker
            completedTasks.append("Upload of Item METADATA")
            if error == nil {
                // Do nothing (no error)
            } else {
                // Append the error to the overall errors array
                overallErrorsArray.append(error)
            }
        }
        
        
        // TASK#2: Upload Original Image (and sync image path in corresponding Firebase DB)
        originalImageUploadTask = self.uploadImage(kind: .original) { (error) in
            // Add the completed task to the tracker
            completedTasks.append("Upload Original Image")
            if error == nil {
                // Do nothing (no error)
            } else {
                // Append the error to the overall errors array
                overallErrorsArray.append(error)
            }
        }
        
        // TASK#3: Create the Thumbnail (Need to add some error management in there!)
        self.createThumbnail() { (error) in
            // Add the completed task to the tracker
            completedTasks.append("Create Thumbnail")
            if error == nil {
                // Do nothing (no error)
            } else {
                // Append the error to the overall errors array
                overallErrorsArray.append(error)
            }
        }
        
        // TASK#4: Upload Thumbnail (Warning because I do not use the returned upload task - but that is itentional so OK)
        let thumbnailUploadTask = self.uploadImage(kind: .thumbnail) { (error) in
            // Add the completed task to the tracker
            completedTasks.append("Upload Thumbnail")
            if error == nil {
                // Do nothing (no error)
            } else {
                // Append the error to the overall errors array
                overallErrorsArray.append(error)
            }
        }
        
        // Return the upload task of the original image
        return originalImageUploadTask
        
    }
    
    
    // MARK: Download methods
    
    
    // Method to download an image of the item from Firebase Storage (whatever the kind of image enum ImageKind)
    func downloadImage (kind: ImageKind, withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> FIRStorageDownloadTask? {
        
        print("Entering the download of image \(kind) \(self.key)")
        var downloadTask: FIRStorageDownloadTask?
        var imagePathAtStake: String?
        
        // Look at the kind of image to download and assign the image path at stake to dedicated variable
        switch kind {
        case .original:
            imagePathAtStake = self.imagePath
        case .thumbnail:
            imagePathAtStake = self.imageThumbnailPath
        }
        
        // Check if image path is not nil
        if let path = imagePathAtStake {
            
            print("All conditions OK to start download of \(kind) image of item \(self.key)")
            
            let imageRef: FIRStorageReference = Item.refS.child("\(path)")
            print("Download reference is using path: \(path)")
            
            // Download data in memory with max size 10MB (10 * 1024 * 1024 bytes)
            downloadTask = imageRef.data(withMaxSize: 10 * 1024 * 1024) { (data, error) in
                
                if error == nil {
                    // set the image on the item at stake
                    switch kind {
                    case .original:
                        // Set the origial image on the item
                        self.image = UIImage(data: data!)
                        print("At Item level: \(kind) image has been downloaded for item \(self.key)")
                        // completion block called with error nil
                        completion(error)
                    case.thumbnail:
                        // Set the thumbnail image on the item
                        self.imageTumbnail = UIImage(data: data!)
                        print("At Item level: \(kind) image has been downloaded for item \(self.key)")
                        // completion block called with error nil
                        completion(error)
                    }
                } else {
                    print("At Item level: Huh-Oh Error while downloading \(kind) image \(self.key)")
                    print("At item level, error is: \(error?.localizedDescription)")
                    // completion block called with error
                    completion(error)
                }
            }
            
        }
        // Return download task
        return downloadTask
        
        
    }
    

    // MARK: Other methods
    
    // Method to create the thumbnail
    func createThumbnail (withCompletionBlock completion: @escaping (_ error: Error?) -> Void) -> Void {
        
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
            // No error passed to the completion block
            completion(nil)
        } else {
            print("Thumbnail of item \(self.key) creation failed")
            // Error passed to the completion handler
            completion(ThumbnailCreationError.failed)
        }
    }
    
    // Method to update item metadata based on a NSDictionary (most of the time coming from a FIRDB Snapshot)
    func updateMetadataUsingNSDictionary(_ dic: NSDictionary) -> Void {
        
        // Check that the NSDictionary is corresponding to the item (same key)
        if let dicKey = dic["key"] as? String, dicKey == self.key {
            
            
            // Update the item metadata based on the dic
            self.description = dic["description"] as? String
            self.tags = dic["tags"] as? [String]
            self.imagePath = dic["imagePath"] as? String
            self.imageThumbnailPath = dic["imageThumbnailPath"] as? String
            print("For item \(self.key): Successfully update metadata: description, tags, imagePath, imageThumbnailPath")
            
            
        } else {
            print("Error: app tried to update item metadata based on a NSDictionary that does not have the same key as the item")
        }

        
        
    }
    
    
    
    
    
}
