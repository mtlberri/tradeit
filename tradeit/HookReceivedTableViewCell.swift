

import UIKit

class HookReceivedTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var senderUserPhoto: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var hookedItemImageThumbnail: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
