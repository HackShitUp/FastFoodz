//
//  NavigationBarItem.swift
//  Nanolens
//
//  Created by Joshua Choi on 11/19/20.
//  Copyright © 2020 Joshua Choi. All rights reserved.
//

import UIKit
import CoreData



// MARK: - NavigationBarItemType
public enum NavigationBarItemType {
    case button
    case view
}



/**
 Abstract: Custom UIView class
 */
public class NavigationBarItem: UIView {

    // MARK: - Class Vars
    
    /// A CGFloat value representing the default height of the bar button items in the navigation bar - defaults to 34.0
    public static let height: CGFloat = 34.0
    
    /// CGRect value representing the default frame of the bar button item when it's displaying text
    public static let titleFrame: CGRect = CGRect(x: 0, y: 0, width: NavigationBarItem.height * 2.0, height: NavigationBarItem.height)
    
    /// Initialized void function used as a closure
    @objc var method: (() -> Void)?
    
    // MARK: - ActiveButton
    public var button: ActiveButton!
    
    // MARK: - NavigationBarItemType
    fileprivate var type: NavigationBarItemType!
    
    // MARK: - UITapGestureRecognizer
    fileprivate var tapGestureRecognizer: UITapGestureRecognizer!
    
    // - Tag
    public override var tintColor: UIColor! {
        didSet {
            DispatchQueue.main.async {
                // Set the tint color for this class' UIButton objects only
                self.subviews.forEach { (item: UIView) in
                    if item.isKind(of: UIButton.self) {
                        item.tintColor = self.tintColor
                    }
                }
            }
        }
    }
    
    /// MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    /// MARK: - Init
    /// - Parameter frame: A CGRect value used to specify the frame of this view class
    /// - Parameter type: An NavigationBarItemType enum
    /// - Parameter object: An optional PFUser PFObject if this view is supposed to display the user's profile photo
    /// - Parameter title: An optional NSAttributedString value representing the button's title
    /// - Parameter image: An optional UIImage value representing the UIButton's UIImage
    /// - Parameter view: An optional UIView object
    /// - Parameter tintColor: An optional UIColor value representing the UIButton's tintColor
    /// - Parameter backgroundColor: An optional UIColor value used to set the background color of this view class` ```containerView```
    /// - Parameter cornerRadii: An optional CGFloat value representing the corner radius of this class' ```containerView```
    /// - Parameter offset: A CGFloat value representing the padding between the top, left, right, and bottom for the custom button or image view added to this view class. Defaults to 8.0
    /// - Parameter method: An optional closure called when this view class is tapped
    public convenience init(frame: CGRect = CGRect(x: 0, y: 0, width: 34.00, height: 34.00),
                            type: NavigationBarItemType = .button,
                            title: NSAttributedString? = nil,
                            image: UIImage? = nil,
                            view: UIView? = nil,
                            tintColor: UIColor = UIColor.black,
                            backgroundColor: UIColor? = .clear,
                            cornerRadii: CGFloat? = nil,
                            offset: CGFloat = 6.0,
                            method: (() -> Void)? = nil) {
        
        self.init(frame: frame)
        
        // Set the closure
        self.method = method
        
        // MARK: NavigationBarItemType
        self.type = type
        
        // MARK: NavigationBarItemType
        switch type {
        case .button:
            // MARK: - ActiveButton
            button = ActiveButton(frame: CGRect(x: offset, y: offset, width: bounds.width - (offset * 2), height: bounds.height - (offset * 2)))
            button.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.setAttributedTitle(title, for: .normal)
            button.tintColor = .clear
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset).isActive = true
            button.topAnchor.constraint(equalTo: topAnchor, constant: offset).isActive = true
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset).isActive = true
            button.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset).isActive = true
            
        case .view:
            // MARK: - UIView
            if let view = view {
                // MARK: - AvatarImageView
                view.frame.size.width = bounds.width - (offset * 2)
                view.frame.size.height = bounds.height - (offset * 2)
                addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: offset).isActive = true
                view.topAnchor.constraint(equalTo: topAnchor, constant: offset).isActive = true
                view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -offset).isActive = true
                view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -offset).isActive = true
            }
        }
        
        // Setup this view class
        self.backgroundColor = backgroundColor
        self.layer.cornerRadius = cornerRadii ?? 0.0
        self.clipsToBounds = false
        
        // Set this class' ```tintColor```
        self.tintColor = tintColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        frame = bounds
        backgroundColor = .clear
        clipsToBounds = false
        translatesAutoresizingMaskIntoConstraints = false
        autoresizingMask = [.flexibleWidth, .flexibleHeight]
        widthAnchor.constraint(equalToConstant: bounds.width).isActive = true
        heightAnchor.constraint(equalToConstant: bounds.height).isActive = true
        
        // MARK: - UITapGestureRecognizer
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(callToAction(_:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.cancelsTouchesInView = false
        isUserInteractionEnabled = true
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    /// Called when this view class was tapped
    /// - Parameter sender: A UITapGestureRecognizer oject that calls this method
    @objc fileprivate func callToAction(_ sender: UITapGestureRecognizer) {
        // Call the closure
        self.method?()
    }
}
