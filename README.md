# Fast Foodz

_Programming assignment for [Current](https://www.current.com)_

## Final Project Demo
[Demo](demo.GIF "Demo")

## Pods Used In Project
1. [NavigationTransitionController](https://github.com/Nanogram-Inc/NavigationTransitionController) (Made by yours truly ;]) — Used to create interactive transitions between view controllers. 
2. [NVActivityIndicatorView](https://github.com/ninjaprox/NVActivityIndicatorView) — Used to animate the custom UIRefreshControl.
3. [SDWebImage](https://github.com/SDWebImage/SDWebImage)  — Used to asynchronously load a place's image URL returned from Yelp's API
4. [SkeletonView](https://github.com/Juanpe/SkeletonView) — Used to load an animation for a view while loading its contents asynchronously

## Experience Outline
An interesting thing I noticed about this starter project was that this project still uses the ```AppDelegate.swift```'s ```UIWindow``` value to load its contents. However, devices supporting iOS 13 and greater are expected to use the ```UISceneDelegate``` protocol to support multiple-windows. Even if an app doesn't support multiple app instances, such as this sample project, it's best to follow protocols to prevent introducing breaking changes. So, I upated the *info.plist* specifying the ```UIScene``` configuration's session there.  

Next, I began installing the pods I needed for this project based on its requisites. The first thing I did was architect the project's codebase to organize it based on the following abstractions:
- Classes
-- Place
-- LocalError
-- MainData
-- ShareContext
- Factories
-- YelpFactory
- Keys
- Style
- ViewControllers
-- DetailViewController
-- MainNavigationController
-- MainViewController
-- MapListViewController
-- MapViewController
- Views
-- Storyboard
-- UICollectionReusableView
-- UICollectionViewCell
-- UICollectionViewFlowLayout
-- UIView

Then, I began building the ```MainViewController``` which is just a view controller that contains the ```MapViewController``` and ```MapListviewController``` inside of a ```UIScrollView``` object so that the user can easily scroll between the 2 screens (the former view controller needs work with the conflicting pan gesture recognizer). It's also toggle-able using the ```UISegmentedControl``` as specified in the requisites. The ```MainViewController``` adopts the struct, ```MainData```'s protocol, ```MainDataDelegate``` to update its child view controllers whenever the current device's location was updated. 

Next, I began building the factory to get data from Yelp's API. Initially, I used the [YelpAPI](https://github.com/Yelp/yelp-ios) because I had prior experience with it. But after realizing that the API doesn't deliver a place's price, a requisite for this project, I instead used a standard ```URLSession``` to make GET requests using the ```REST``` API as specified in the requisite PDF. Finally, I began building the interfaces to bind the data using an MVVM pattern. 

## Requirements
- iOS 13

## Author

HackShitUp, josh.m.choi@gmail.com

