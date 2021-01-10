//
//  MainViewController.swift
//  Fast Foodz
//
//  Created by Joshua Choi on 1/9/21.
//  Copyright © 2021 Joshua Choi. All rights reserved.
//

import UIKit
import CoreLocation
import NavigationTransitionController



/**
 Abstract: Primary view controller used to control the contents of displaying the MapViewController and MapListViewController
 */
class MainViewController: UIViewController {

    // MARK: - Class Vars
    
    // Index of the current view controller visible on the screen
    var index: Int = 0 {
        didSet {
            // MARK: - UISegmentedControl
            self.segmentedControl.selectedSegmentIndex = self.index
        }
    }
    
    /// Returns all of the view controllers added to this class' UIScrollView
    var viewControllers: [UIViewController] {
        get {
            return [mapViewController, mapListViewController]
        }
    }
    
    /// Returns the current UIViewController class displayed in the screen
    var currentViewController: UIViewController? {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    /// CGSize value that returns the scroll view's size
    var pageSize: CGSize {
        get {
            return CGSize(width: scrollView.frame.size.width, height: scrollView.frame.size.height)
        }
    }
    
    // MARK: - CLLocation
    var testLocation: CLLocation? = nil
    
    // MARK: - CLLocationManager
    let clLocationManager: CLLocationManager = CLLocationManager()
    
    /// Boolean used to layout the scroll view once — defaults to FALSE
    var isLoaded: Bool = false
    
    // MARK: - MapViewController
    let mapViewController = MapViewController()
    
    // MARK: - MapListViewController
    let mapListViewController = MapListViewController()
    
    // MARK: - NavigaationBarItem
    var segmentedControlItem: NavigationBarItem!
    
    // MARK: - NavigationBar
    var navigationBar: NavigationBar!
    
    // MARK: - UIView
    var segmentedControlContainerView: UIView!
    
    // MARK: - UISegmentedControl
    var segmentedControl: UISegmentedControl!
    
    // MARK: - IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var enableLocationButton: UIButton!
    
    /// MARK: - Init
    /// - Parameter index: An Int value representing the index of the current view controller that's visible
    init(index: Int = 0) {
        super.init(nibName: "MainViewController", bundle: nil)
        
        // Set the index
        self.index = index
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - View Controller Life Cycle
    open override var childForStatusBarStyle: UIViewController? {
        return currentViewController
    }

    open override var prefersStatusBarHidden: Bool {
        return currentViewController?.prefersStatusBarHidden ?? false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Call the current view controller's life cycle
        currentViewController?.viewDidAppear(false)
        
        // If we've already enabled locations access, let's fetch the user's location again whenever this class gets initialized
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // MARK: - CLLocationManager
            self.clLocationManager.startUpdatingLocation()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: - MainData
        MainData.delegate = self
        
        // MARK: - UISegmentedControl
        segmentedControl = UISegmentedControl()
        segmentedControl.insertSegment(withTitle: "Map", at: 0, animated: false)
        segmentedControl.insertSegment(withTitle: "List", at: 1, animated: false)
        segmentedControl.backgroundColor = UIColor.londonSky
        segmentedControl.selectedSegmentTintColor = UIColor.competitionPurple
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.deepIndigo], for: .normal)
        segmentedControl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(toggleMode(_:)), for: .valueChanged)
        
        // MARK: - UIView
        segmentedControlContainerView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: UIScreen.main.bounds.width/2.5, height: 34.0))
        segmentedControlContainerView.backgroundColor = .clear
        segmentedControlContainerView.translatesAutoresizingMaskIntoConstraints = false
        segmentedControlContainerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControlContainerView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width/3.0).isActive = true
        segmentedControlContainerView.heightAnchor.constraint(equalToConstant: 34.0).isActive = true
        segmentedControlContainerView.addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        segmentedControl.leadingAnchor.constraint(equalTo: segmentedControlContainerView.leadingAnchor).isActive = true
        segmentedControl.topAnchor.constraint(equalTo: segmentedControlContainerView.topAnchor).isActive = true
        segmentedControl.trailingAnchor.constraint(equalTo: segmentedControlContainerView.trailingAnchor).isActive = true
        segmentedControl.bottomAnchor.constraint(equalTo: segmentedControlContainerView.bottomAnchor).isActive = true
        
        // MARK: - NavigationBarItem
        segmentedControlItem = NavigationBarItem(frame: segmentedControlContainerView.bounds, type: .view, view: segmentedControlContainerView, offset: 0.0)
        
        // MARK: - NavigationBar
        navigationBar = NavigationBar(viewController: self, titleAttributedString: NSAttributedString(string: "Fast Food Places", attributes: [.font: UIFont.systemFont(ofSize: 20.0, weight: .bold)]), alignment: .center, rightBarItems: [segmentedControlItem])
        
        // MARK: - CLLocationManager
        clLocationManager.desiredAccuracy = kCLLocationAccuracyBest
        clLocationManager.delegate = self

        // MARK: - NSAttributedString
        let enableLocationAttributedString = NSMutableAttributedString()
        enableLocationAttributedString.append(NSAttributedString(string: "Please Enable Location Access📍\n\n", attributes: [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 20.0, weight: .bold)]))
        enableLocationAttributedString.append(NSAttributedString(string: "This allows Fast Foodz to help you discover great restuarants nearby when you're hungry.\n\n", attributes: [.foregroundColor: UIColor.darkGray, .font: UIFont.systemFont(ofSize: 16.0, weight: .medium)]))
        enableLocationAttributedString.append(NSAttributedString(string: "Authorize Location", attributes: [.foregroundColor: UIColor.competitionPurple, .font: UIFont.systemFont(ofSize: 20.0, weight: .heavy)]))
        enableLocationButton.alpha = CLLocationManager.authorizationStatus() == .authorizedWhenInUse ? 0.0 : 1.0
        enableLocationButton.titleLabel?.numberOfLines = 0
        enableLocationButton.titleLabel?.textAlignment = .center
        enableLocationButton.setAttributedTitle(enableLocationAttributedString, for: .normal)
        enableLocationButton.addTarget(self, action: #selector(manageLocationAccess(_:)), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If we haven't laid out the views yet, do that now
        if !isLoaded {
            // MARK: - UIScrollViews
            scrollView.alpha = CLLocationManager.authorizationStatus() == .authorizedWhenInUse ? 1.0 : 0.0
            scrollView.contentSize = CGSize(width: pageSize.width * CGFloat(viewControllers.count), height: pageSize.height)
            scrollView.contentInsetAdjustmentBehavior = .never
            scrollView.showsHorizontalScrollIndicator = false
            scrollView.showsVerticalScrollIndicator = false
            scrollView.isDirectionalLockEnabled = true
            scrollView.isPagingEnabled = true
            scrollView.delaysContentTouches = false
            scrollView.bounces = false
            scrollView.delegate = self
            view.addGestureRecognizer(scrollView.panGestureRecognizer)

            // Iterate through the view controllers and add it to the scroll view
            for (index, controller) in viewControllers.enumerated() {
                // Add the UIViewController to the scroll view
                controller.view.frame = getFrameOfViewController(index: index)
                scrollView.addSubview(controller.view)
                addChild(controller)
                controller.didMove(toParent: self)
            }
            
            // Scroll to the index
            scrollToIndex(index: index) { (success: Bool) in
                if success {
                    // MARK: - UIScrollViewDelegate
                    self.scrollViewDidScroll(self.scrollView)
                }
            }
            
            // Update the Boolean
            self.isLoaded = true
        }
    }
}
