//
//  MapListCell.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit



class DynamicVerticalLayout: UICollectionViewFlowLayout {
    
    // MARK: - Class Vars
    
    // MARK: - Init
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    fileprivate func setup() {
        // Configure the layout
        scrollDirection = .vertical
        sectionInset = .zero
        minimumInteritemSpacing = 0.0
        minimumLineSpacing = 0.0
        estimatedItemSize = UICollectionViewFlowLayout.automaticSize
    }
}



extension UICollectionView {
    // MARK: - CellSize
    private struct CellSizeCache {
        static var sizes = "cachedCellSizes"
    }
    
    /// Initialized Dictionary used to store cell sizes per each index paths
    var cachedCellSizes: [IndexPath : CGSize] {
        set(value) {
            objc_setAssociatedObject(self, &CellSizeCache.sizes, value, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        
        get {
            // Return the stored skip
            return objc_getAssociatedObject(self, &CellSizeCache.sizes) as? [IndexPath: CGSize] ?? [:]
        }
    }
}



/**
 Abstract: UICollectionViewCell used to display map data
 */
class MapListCell: UICollectionViewCell {
    
    // MARK: - Class Vars
    
    // CGSize of this cell class
    static let size: CGSize = CGSize(width: UIScreen.main.bounds.width, height: 60.0)
    
    // MARK: - Place
    var place: Place!
    
    // - Tag
    override var isHighlighted: Bool {
        didSet {
            separatorView.alpha = isHighlighted ? 0.0 : 1.0
            contentView.backgroundColor = isHighlighted ? UIColor.lilacGrey : UIColor.white
        }
    }
    
    // MARK: - IBOutlets
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    /// Update the contents of this cell class
    /// - Parmaeter place: A Place object
    func updateContent(place: Place) {
        // MARK: - Place
        self.place = place
        
        // Set the image view
        self.imageView.image = place.categoryImage?.withRenderingMode(.alwaysTemplate)
        
        // MARK: - NSMutableAttributedString
        let labelAttributedString = NSMutableAttributedString()
        labelAttributedString.append(NSAttributedString(string: place.name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 16.0, weight: .medium), .foregroundColor: UIColor.deepIndigo]))
        // Set the place's price
        if let price = place.price {
            labelAttributedString.append(NSAttributedString(string: "\n\(price)", attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.pickleGreen]))
            (0...(4 - price.count)).forEach { (position: Int) in
                if position > 0 {
                    labelAttributedString.append(NSAttributedString(string: "$", attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.lilacGrey]))
                }
            }
        } else {
            labelAttributedString.append(NSAttributedString(string: "\n$$$$", attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.lilacGrey]))
        }
        // Set the place's distance
        if let currentLocation = MainData.currentLocation, let placeLocation = place.location {
            // Get the distance in meters
            let distanceInMeters = currentLocation.distance(from: placeLocation)
            // Get the distance in miiles
            let miles: Double = Double(distanceInMeters) * 0.00062137
            labelAttributedString.append(NSAttributedString(string: " • ", attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.lilacGrey]))
            labelAttributedString.append(NSAttributedString(string: "\(String(format: "%.2f", ceil(miles*100)/100))", attributes: [.font: UIFont.systemFont(ofSize: 13.0, weight: .semibold), .foregroundColor: UIColor.lilacGrey]))
        }
        // MARK: - NSMutableParagraphStyle
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = UIFont.systemFont(ofSize: 16.0, weight: .medium).capHeight
        labelAttributedString.addAttributes([.paragraphStyle: paragraphStyle], range: NSRange(location: 0, length: labelAttributedString.mutableString.length))
        self.label.attributedText = labelAttributedString
    }

    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // contentView
        contentView.backgroundColor = UIColor.white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.leadingAnchor.constraint(equalTo: leadingAnchor).isActive = true
        contentView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        contentView.trailingAnchor.constraint(equalTo: trailingAnchor).isActive = true
        contentView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true

        // separatorView
        separatorView.backgroundColor = UIColor.londonSky
        
        // imageView
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.deepIndigo
        imageView.backgroundColor = .clear
        
        // label
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.textAlignment = .left
        
        // button
        button.tintColor = UIColor.deepIndigo
        button.setImage(UIImage(named: "chevron")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.isUserInteractionEnabled = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // imageView
        imageView.image = nil
        // label
        label.attributedText = nil
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let size = contentView.systemLayoutSizeFitting(CGSize(width: layoutAttributes.frame.width, height: CGFloat.greatestFiniteMagnitude), withHorizontalFittingPriority: UILayoutPriority.required, verticalFittingPriority: UILayoutPriority.fittingSizeLevel)
        layoutAttributes.frame.size = size
        return layoutAttributes
    }
}
