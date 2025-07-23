
## Use Cocoapods?

Easily include the Prebid Mobile SDK for your primary ad server in your Podfile

```
platform :ios, '12.0'
use_frameworks!

target 'ozone20240129-news-all-ads' do
    pod 'PrebidMobile', '3.0.2', :source => 'https://github.com/ozone-project/inapp-sdk-ios-podspec'
    pod 'Google-Mobile-Ads-SDK', '11.1.0'
    pod 'UsercentricsUI', '2.7.14'
# for instream video:
    pod 'GoogleAds-IMA-iOS-SDK', '~> 3.15.1', :source => 'https://github.com/CocoaPods/Specs.git'
# added 20240312
    pod 'GoogleAppMeasurement'
    pod 'GoogleUtilities'
    pod 'PromisesObjC'
    pod 'nanopb'
end

```

## If you do not use Cocoapods

Contact us for a framework build you can manually import into your project (Universal Binary)

## Changes in this version

- migrating Ozone changes to the latest code from updated PrebidMobile code
- built from 3.0.2

## Code changes required compared to v2.2.0

- See the 'Ozoner' app code for code changes
- Specific changes:
```
- change how you set the auction endpoint:
  Old (2.2.0): - Prebid.shared.setCustomPrebidServer(url: AppDelegate.ozoneEndpoint)
  New (3.0.2): - set the server url when you call initializeSDK


- No need for this now: Prebid.shared.prebidServerHost = PrebidHost.Custom

- PBMLocationManager has been renamed to LocationManager

- (Recommendation) Add a function to cater for CLAuthorizationStatus() being deprecated:

  func getLocationStatus() -> CLAuthorizationStatus {

        let locStatus: CLAuthorizationStatus

        if #available(iOS 14.0, *) {
            // iOS 14 and above: use instance property
            locStatus = CLLocationManager().authorizationStatus
        } else {
            // iOS < 14: use class method
            locStatus = CLLocationManager.authorizationStatus()
        }

        return locStatus;
  }


- adUnit.fetchDemand changed method signature

- InstreamVideoAdUnit fetchDemand - we now have to use a different method signature; the previous one was marked in 2.2.0: "Deprecated. Use fetchDemand(completion: @escaping (_ bidInfo: BidInfo) -> Void) instead." and has now been removed. Use:
  adUnit.fetchDemand { [weak self] (bidInfo: BidInfo) in
  and get what you need from: bidInfo.targetingKeywords and bidInfo.resultCode

```

## Other changes

- Google-Mobile-Ads-SDK - version 12 was a major update with breaking changes. Fortunately XCode will suggest fixes, and you should accept them; they're basically package & file name changes. Or you can continue to use V11.x
