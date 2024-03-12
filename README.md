
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

Contact us for a framework build you can manually import into your project

## Changes in this version 

- Only one small change: adUnits contain automatic customTargeting `"instl":"0"` or `"instl":"1"`
- built from 2.1.2 (`2.1.2+20240312` causes problems for cocoapods because it expects only a numeric build version, so we appended a `2`)
- updated Podfile info (above) to explicitly include GoogleAppMeasurement, GoogleUtilities and PromisesObjC
