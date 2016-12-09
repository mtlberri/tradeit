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
    
    // Firebase database ref
    var dbRef: FIRDatabaseReference! = FIRDatabase.database().reference()
    // Firebase storage reference
    let imagesRef = FIRStorage.storage().reference(forURL: "gs://tradeit-99edf.appspot.com/").child("images")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false



        // Do any additional setup after loading the view.
        // Initialize the items array
        self.itemsArray = ItemsArray(withMetadataFromFBRef: self.dbRef) { () -> Void in
            print("Completion handler of items array init() called...")
            print("...Ordering to re-load the view!")
            self.collectionView?.reloadData()
            
        // Put an observer on the items array "numberOfThumbnailsDownloaded" key
        self.itemsArray.addObserver(self, forKeyPath: "numberOfThumbnailsDownloaded", options: .new, context: &self.myContext)
        }
        
    }
    
    //override the observer function
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print("Observer triggered!")
        if context == &myContext {
            print("new number of thumbnail(s) downloaded is: \(change?[NSKeyValueChangeKey.newKey])")
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
        cell.backgroundColor = UIColor.blue
        // cell.imageView.image = itemsArray[indexPath.row].image
        print("Returning Cell number: \(indexPath.row)")
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */
    
    // MARK: My Methods

    
    // De-Initialization
    deinit {
        print("Removing obserbver on Items Array 'numberOfThumbnailsDownloaded'")
        self.itemsArray.removeObserver(self, forKeyPath: "numberOfThumbnailsDownloaded")
    }

}
