# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'major-7-ios' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        # Temporary fix, ref: https://developer.apple.com/forums/thread/656616
        
        config.build_settings['ARCHS[sdk=iphonesimulator*]'] = 'x86_64'
        # M1 simulator fix, ref: https://blog.sudeium.com/2021/06/18/build-for-x86-simulator-on-apple-silicon-macs/
      end
    end
  end
  
  # Pods for major-7-ios
  
  #Facebook
  pod 'FBSDKCoreKit/Swift'
  pod 'FBSDKLoginKit/Swift'
  
  #Google / Firebase
  pod 'Firebase/Core'
  pod 'Firebase/Analytics'
  pod 'Firebase/Messaging'
  pod 'GoogleSignIn'
  pod 'GoogleMaps'
  
  #Networking
  pod 'Alamofire'
  pod 'PromiseKit/CorePromise'
  pod 'Kingfisher'                              # image downloading
  pod 'Reqres'                                  # network activity logger
  
  #General Pods
  pod 'Localize-Swift'                          # localization
  pod 'DynamicColor'                            # UIColor extension
  pod 'SnapKit'                                 # layout constaints
  pod 'Pastel'                                  # dynamic gradient background
  pod 'ObjectMapper'                            # json mapping
  pod 'SkeletonView', '1.8.5'                   # as title
  pod 'BouncyLayout'                            # UICollectionView animation
  pod 'AMScrollingNavbar'                       # UINavigationBar hiding
  #pod 'MXParallaxHeader'                        # parallax header
  pod 'Floaty', '~> 4.1'                        # floating button
  pod 'JGProgressHUD'                           # progress hud
  pod 'SwiftGifOrigin', '~> 1.6'                # gif in UIImageView
  pod 'Bartinter'                               # update status bar style automatically
  pod 'SkyFloatingLabelTextField'               # floating label above textfield
  pod 'NVActivityIndicatorView'                 # as title
  pod 'SwiftMessages'                           # in-app notifications/empty states of tableview/collectionview etc...
  pod 'CHIPageControl'                          # UIPageControl
  pod 'Parchment'                               # Paging menu
  pod 'XCDYouTubeKit'                           # Youtube AVPlayer
  pod 'PIPKit'                                  # picture in picture mode
  pod 'FloatingPanel'                           # as title
  pod 'fluid-slider'                            # custom ui slider
  pod 'InfiniteLayout'                          # infinite scrolling uicollectionview
  pod 'BetterSegmentedControl'                  # segmented control
  pod 'MarqueeLabel'                            # auto scrolling UILabel
  pod 'SwiftDate'                               # as title
  pod 'Hero'                                    # transitions
  pod 'lottie-ios'                              # After Effects animations
  pod 'ViewAnimator'                            # Animate uicollectionview cells
  #pod 'ActiveLabel'                             # supporting Hashtags (#), Mentions (@), URLs (http:/)
  
  pod 'Validator', :git => 'https://github.com/fatdoyy/Validator.git'                            # UITextField validation
  #pod 'ImageViewer', :inhibit_warnings => true, :git=> 'https://github.com/mezhevikin/ImageViewer'  # as title
  #pod 'ImageViewer', :git=> 'https://github.com/Nabeatsu/ImageViewer', :branch=> 'master'           # as title
  pod 'ImageViewer'
  
end
