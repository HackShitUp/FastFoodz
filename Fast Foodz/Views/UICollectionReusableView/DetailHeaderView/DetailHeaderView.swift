//
//  DetailHeaderView.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/10/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import SkeletonView
import SDWebImage




/**
 Abstract: UICollectionReusableView
 */
class DetailHeaderView: UICollectionReusableView {
    
    // MARK: - Class Vars
    
    /// CGSize of this view class
    static var size: CGSize {
        get {
            return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width/2.0)
        }
    }
    
    // MARK: - Place
    var place: Place!

    // MARK: - IBOutlets
    @IBOutlet weak var imageView: UIImageView!
    
    /// Update the contents of this view class
    /// - Parameter place: A Place object
    func updateContent(place: Place) {
        // MARK: - Place
        self.place = place
        
        if let imageURL = place.imageURL {
            // Execute in the main thread
            DispatchQueue.main.async {
                // MARK: - SkeletonView
                self.imageView.isSkeletonable = true
                self.imageView.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.lilacGrey), animation: nil, transition: .none)
            }
            
            // MARK: - SDWebImage
            imageView.sd_setImage(with: imageURL) { (image: UIImage?, error: Error?, type: SDImageCacheType, url: URL?) in
                if error == nil {
                    // Execute in the main thread
                    DispatchQueue.main.async {
                        // MARK: - SkeletonView
                        self.imageView.hideSkeleton()
                    }
                } else {
                    print("\(#file)/\(#line) - Error: \(error?.localizedDescription as Any)")
                }
            }
        }
    }
    
    // MARK: - View Life Cycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // imageView
        imageView.isSkeletonable = true
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFill
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        // MARK: - SDWebImage
        imageView.sd_cancelCurrentImageLoad()
    }
}
