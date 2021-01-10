//
//  Refresher.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 6/9/18.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import NVActivityIndicatorView



// MARK: - UIView
class TriangleView : UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func draw(_ rect: CGRect) {

        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.beginPath()
        context.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        context.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        context.addLine(to: CGPoint(x: (rect.maxX / 2.0), y: rect.minY))
        context.closePath()
        context.setFillColor(UIColor.londonSky.cgColor)
        context.fillPath()
    }
}



/**
 Abstract: Custom UIRefreshControl
 */
class Refresher: UIRefreshControl {
    
    // MARK: - Class Vars
    
    // MARK: - UIView
    fileprivate var view: UIView!
    
    // MARK: - NVActivityIndicatorView
    fileprivate var nvActivityIndicatorView: NVActivityIndicatorView!

    /// Initialized Boolean used to determine if we're displaying the first ever refresh. Need this to determine if we should move the scroll view's content offset to force it to display this class.
    fileprivate var isInitRefresh: Bool = true
    
    // MARK: - Init
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // Class set up
    func setup() {
        // Self
        frame = bounds
        backgroundColor = .clear
        tintColor = .clear
        
        // MARK: - UIView
        view = TriangleView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 15.0))
        view.backgroundColor = .clear
        addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        view.heightAnchor.constraint(equalToConstant: 15.0).isActive = true
        view.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        view.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        // MARK: - NVActivityIndicatorView
        nvActivityIndicatorView = NVActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0), type: .triangleSkewSpin, color: UIColor.londonSky, padding: 0.0)
        nvActivityIndicatorView.backgroundColor = .clear
        addSubview(nvActivityIndicatorView)
        nvActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        nvActivityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        nvActivityIndicatorView.widthAnchor.constraint(equalToConstant: 30.0).isActive = true
        nvActivityIndicatorView.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        nvActivityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor).isActive = true
        nvActivityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        // Hide the refresher (setting the tint color to clear does NOT work)
        if let _ = superview {
            self.subviews.first?.alpha = 0
        }
    }

    /// Animates the image view rotation. We can think of this method as adopting the .beginRefreshing() and .endRefreshing() UIRefreshControl methods.
    /// - Parameter isLoading: A Boolean indicating whether the refresh control should start spinning or not.
    @objc open func animate(_ isLoading: Bool) {
        DispatchQueue.main.async {
            if isLoading == true {
                // MARK: - UIView
                self.view.alpha = 0.0
                
                // MARK: - NVActivityIndicatorView
                self.nvActivityIndicatorView.color = UIColor.londonSky
                
                // Start refreshing
                self.layoutIfNeeded()
                self.beginRefreshing()
                
                // MARK: - NVActivityIndicatorView
                self.nvActivityIndicatorView.startAnimating()
                
                // MARK: - UIScrollView
                // Scroll to the top of the scroll view first if it's content offset isn't at the top
                if let scrollView = self.superview as? UIScrollView, scrollView.contentOffset.y != -30.0 && self.isInitRefresh {
                    // Scroll to the top of the scroll view first if it's content offset isn't at the top
                    scrollView.setContentOffset(CGPoint(x: 0, y: -30.0), animated: false)
                    // Update the Boolean to indicate that we no longer need to scroll to the specified offset
                    self.isInitRefresh = false
                }

            } else if isLoading == false {
                // MARK: - UIView
                self.view.alpha = 1.0
                
                // End refreshing
                self.endRefreshing()
                
                // MARK: - NVActivityIndicatorView
                self.nvActivityIndicatorView.stopAnimating()
            }
        }
    }
}
