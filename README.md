
## Use Cocoapods?

Easily include the Prebid Mobile SDK for your primary ad server in your Podfile

```
platform :ios, '12.0'
use_frameworks!

target 'ozone20240129-news-all-ads' do
    pod 'PrebidMobile', '2.1.22', :source => 'https://github.com/ozone-project/inapp-sdk-ios-podspec'
    pod 'Google-Mobile-Ads-SDK'
    pod 'UsercentricsUI', '2.7.14'
# for instream video:
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.15.1', :source => 'https://github.com/CocoaPods/Specs.git'
# added 20240312
    pod 'GoogleAppMeasurement'
    pod 'GoogleUtilities'
    pod 'PromisesObjC'
end
```

## If you do not use Cocoapods

Contact us for a framework build you can easily use in your project

