import UIKit

class FilterCollectionCell: UICollectionViewCell {

    //Outlets
    @IBOutlet weak var backgroundCellView: BackgroundView!
    @IBOutlet weak var filterImageView: UIImageView!
    @IBOutlet weak var filterNameLabel: UILabel!
    
    //Static fields
    static let identifier: String = "FilterCollectionCell"
    
    //Private fields
    private var index: Int = -1
    private let data: [(UIImage?, String, UIColor?)] = [(UIImage(named: "new"), "new", UIColor(named: "newColor")),
                                                        (UIImage(named: "process"), "in process", UIColor(named: "processColor")),
                                                        (UIImage(named: "check"), "completed", UIColor(named: "completeColor")),
                                                        (UIImage(named: "expired"), "expired", UIColor(named: "expiredColor"))]
    
    override var isSelected: Bool{
        didSet {
            if isSelected {
                
                backgroundCellView.borderColor = .black
                backgroundCellView.backgroundColor = data[index].2!
                filterImageView.tintColor = .black
            } else {
                
                backgroundCellView.borderColor = data[index].2!
                backgroundCellView.backgroundColor = .white
                filterImageView.tintColor = data[index].2!
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func setUpCell(with index: Int) {
        self.index = index
        
        backgroundCellView.borderColor = data[index].2!
        filterImageView.tintColor = data[index].2!
        filterImageView.image = data[index].0!
        filterNameLabel.text = data[index].1
    }
}
