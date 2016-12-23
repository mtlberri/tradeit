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
    var itemsArray: ItemsArray!
    
    // Firebase database ref to Root/items
    var dbRef: FIRDatabaseReference! = FIRDatabase.database().reference().child("items")
    // Firebase storage reference
    let imagesRef = FIRStorage.storage().reference(forURL: "gs://tradeit-99edf.appspot.com/").child("images")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        print("Starting Initialization of itemsArray")
        // Initialize the items array
        self.itemsArray = ItemsArray(withMetadataFromFBRef: self.dbRef) { () -> Void in
            print("Completion handler of items array init() called...")
            print("...Ordering to re-load the view!")
            self.collectionView?.reloadData()
            
            // Then download the thumbnails, with completion block called each time an individual thumbnail download completed
            self.itemsArray.loadThumbnails() { (error) in
                if error == nil {
                    print("At Collection View level: One Thumbnail downloaded without error: Reload the view!")
                    self.collectionView?.reloadData()
                } else {
                    print("At Collection View level: Thumbnail downloaded with error: Reload the view anyway!")
                    self.collectionView?.reloadData()
                }
                
                
            }
            
        }
        
        
        

        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        print("There will be \(self.itemsArray.content.count) cells")
        return self.itemsArray.content.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
        // Configure the cell
        //cell.backgroundColor = UIColor.blue
        cell.itemDescription.text = self.itemsArray.content[indexPath.row].description ?? "No Description Available"
        cell.imageView.image = self.itemsArray.content[indexPath.row].imageTumbnail
        print("Returning Cell number: \(indexPath.row)")
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    // When item selected
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Item selected at row: \(indexPath.row)")
        
        // create a Item Display view controller with selected item in it
        let destinationViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ItemDisplay") as! ItemDisplayViewController
        destinationViewController.itemToDisplay = self.itemsArray.content[indexPath.row]
        
        print("destination view controller ready! Now being pushed by the navigation controller...")
        // Present the destination view controller
        self.navigationController?.pushViewController(destinationViewController, animated: true)
        
    }
    
    
    // MARK: My Methods



}
