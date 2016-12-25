import UIKit
import Firebase

private let reuseIdentifier = "ItemCell"

// Insets distances
private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
// Number of items per row = 3
private let itemsPerRow: CGFloat = 3

// Implementation of the protocol Flow Layout
extension ItemsCollectionViewController : UICollectionViewDelegateFlowLayout {
  
    // size of an item
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let paddingSpace = sectionInsets.left * (itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = availableWidth / itemsPerRow
        
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    // returns the spacing between the cells, headers, and footers. A constant is used to store the value
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    // spacing between each line = padding
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

class ItemsCollectionViewController: UICollectionViewController {
    
    // MARK: Properties
    
    // Context var for KVO observer
    var myContext = 0
    
    // Items Array
    var itemsArray: ItemsArray?
    
    // Firebase database ref to the items to be displayed in the collection view
    var dbRef: FIRDatabaseReference! = FIRDatabase.database().reference().child("items")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ItemsCV did load!")
        // do some
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("ItemsCV will appear!")
        
        
        if self.itemsArray == nil {
            print("ItemsCV: Please go init the array of items because it is not existing yet. And reload data upon completion of each unit.")
            self.initItemsArray() {
                print("ItemsCV: Reload the view!")
                self.collectionView?.reloadData()
            }
        } else {
            print("ItemsCV: No need to init the array of items because it is existing already")
        }
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("There will be \(self.itemsArray?.content.count) cells")
        return self.itemsArray?.content.count ?? 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
        // Configure the cell
        //cell.backgroundColor = UIColor.blue
        cell.itemDescription.text = self.itemsArray?.content[indexPath.row].description ?? "No Description Available"
        cell.imageView.image = self.itemsArray?.content[indexPath.row].imageTumbnail
        print("Returning Cell number: \(indexPath.row)")
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    // When item selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Item selected at row: \(indexPath.row)")
        
        // create a Item Display view controller with selected item in it
        let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemDisplay") as! ItemDisplayViewController
        destinationViewController.itemToDisplay = self.itemsArray?.content[indexPath.row]
        
        print("destination view controller ready! Now being pushed by the navigation controller...")
        // Present the destination view controller
        self.navigationController?.pushViewController(destinationViewController, animated: true)
        
    }
    
    
    // MARK: My Methods

    // Method to load th itemsArray
    func initItemsArray (withUnitCompletionBlock unitCompletion: @escaping () -> Void) -> Void {
        
        // Initialize the items array (so it will not be nil anymore from there on)
        self.itemsArray = ItemsArray()
        // Download the metadata of the items array
        self.itemsArray?.downloadMetadata(withMetadataFromFBRef: self.dbRef) { () -> Void in
            print("Metadat of the items array has been loaded!")
            print("...calling the unitCompletion Block!")
            // Invoke unitCompletion when present controller is used for another collectionView (so that this later can reload)
            unitCompletion()
            // Then download the thumbnails, with completion block called each time an individual thumbnail download completed
            self.itemsArray?.downloadThumbnails() { (error) in
                if error == nil {
                    print("At Collection View level: One Thumbnail downloaded without error: calling the unitCompletion Block!")
                    unitCompletion()
                } else {
                    print("At Collection View level: Thumbnail downloaded with error: calling the unitCompletion Block!")
                    unitCompletion()
                }
                
                
            }
            
        }
        
        
    }

}
