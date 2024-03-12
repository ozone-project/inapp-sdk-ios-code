
## Use Cocoapods?

Easily include the Prebid Mobile SDK for your primary ad server in your Podfile/

```
platform :ios, '12.0'
use_frameworks!

target 'your-project-name' do
    pod 'PrebidMobile', '2.1.2', :source => 'https://github.com/ozone-project/inapp-sdk-ios-podspec'
    pod 'Google-Mobile-Ads-SDK'
#    pod 'UsercentricsUI', '2.7.14' -> example; you might use a different CMP
# for instream video:
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.15.1', :source => 'https://github.com/CocoaPods/Specs.git'
end
```

## If you do not use Cocoapods

Contact us for a framework build you can easily use in your project

