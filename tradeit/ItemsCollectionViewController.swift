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
///////////////////////////////////////////////////////

class ItemsCollectionViewController: UICollectionViewController {

    
    // MARK: Properties
    var itemsArray = [Item]()
    
    // Firebase database ref
    var dbRef: FIRDatabaseReference! = FIRDatabase.database().reference()
    // Firebase storage reference
    let imagesRef = FIRStorage.storage().reference(forURL: "gs://tradeit-99edf.appspot.com/").child("images")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false



        // Do any additional setup after loading the view.
        // Go get the Firebase data
        buildItemsArray()
        
        
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
        print("There will be \(self.itemsArray.count) cells")
        return self.itemsArray.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ItemCollectionViewCell
    
        // Configure the cell
        cell.backgroundColor = UIColor.white
        cell.imageView.image = itemsArray[indexPath.row].image
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
    
    func buildItemsArray() -> Void {
        
        // read Firebase data once and fill the itemsArray based on data retrieved
        dbRef.observeSingleEvent(of: .value, with: { (snapshot) in
            
            let firebaseNSDictionary = snapshot.value as? NSDictionary
            
            if let dictionary = firebaseNSDictionary {
                
                for element in dictionary {
                    
                    print("Entering the loop to create itemToAdd based on firebase element:")
                    print(element.value)
                    let elementNSDictionary = element.value as! NSDictionary
                    
                    let itemToAdd = Item()
                    // Populate the itemToAddd
                    itemToAdd.key = elementNSDictionary["key"] as? String
                    itemToAdd.description = elementNSDictionary["description"] as? String
                    itemToAdd.tags = elementNSDictionary["description"] as? [String]
                    // To be added later in Firebase model
                    //itemToAdd.imagePath = elementNSDictionary["imagePath"] as? String
                    print("For item \(itemToAdd.description): Successfully set properties: key, description, tags")
                    
                    // Download the image and assign it to the itemToAdd object
                    let itemImageRef = self.imagesRef.child("\(itemToAdd.key!).jpg")
                    // Download image in memory with a max size allowed of 1MB (1*1024*1024 bytes)
                    itemImageRef.data(withMaxSize: 1 * 1024 * 1024, completion: { (data, error) -> Void in
                        if ( error != nil ) {
                            print("Oops error occured in the download of item image: \(itemToAdd.key!).jpg")
                        } else {
                            // Create an image based on the data downloaded and assign it to the item image
                            itemToAdd.image = UIImage(data: data!)
                            print("For item \(itemToAdd.description): Successfully downloaded image: \(itemToAdd.key!).jpg")
                            
                            self.collectionView?.reloadData()
                            print("For item \(itemToAdd.description): Collection view reloading ordered")
                        }
                        
                    })
                    
                    self.itemsArray.append(itemToAdd)
                    print("For item \(itemToAdd.description): Appended the item to the itemsArray")
                    self.collectionView?.reloadData()
                    print("For item \(itemToAdd.description): Collection view reloading ordered")

                }
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
        
        
    }

}
