/*   Copyright 2018-2021 Prebid.org, Inc.
 
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
 
  http://www.apache.org/licenses/LICENSE-2.0
 
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

import Foundation

fileprivate let defaultTimeoutMillis = 2000

/// A callback used for Prebid initialization status.
///
/// This callback is called when the Prebid SDK initialization completes. It provides the status of the initialization and any error that may have occurred.
///
/// - Parameters:
///   - status: The status of the Prebid initialization.
///   - error: An optional error that occurred during initialization.
public typealias PrebidInitializationCallback = ((PrebidInitializationStatus, Error?) -> Void)

/// The `Prebid` class manages the configuration and initialization of the PrebidMobile SDK.
@objcMembers
public class Prebid: NSObject {
    
    // MARK: - Public Properties (SDK)
    
    /// Indicates whether the timeout value has been updated.
    public var timeoutUpdated: Bool = false
    
    /// The Prebid Server account ID.
    public var prebidServerAccountId = ""
    
    /// The Prebid auction settings ID.
    public var auctionSettingsId: String?
    
    /// Enables or disables debug mode.
    /// ORTB: bidRequest.test
    public var pbsDebug = false
    
    /// Custom HTTP headers to be sent with requests.
    public var customHeaders: [String: String] = [:]
    
    /// Stored bid responses identified by bidder names.
    public var storedBidResponses: [String: String] = [:]
    
    
    // MARK: OZONE ADDITIONS; all ozone methods start `ozone....` so it's easy to find them in intellisense
    
    // MB 20230301 Ozone changes
    /**
     * set app.ext.page value
     */
    public func ozoneSetAppPage( url: String ) {
        ozoneAppPage = url;
    }
    /**
     * set device.ip
     */
    public func ozoneSetDeviceIp( ip: String ) {
        deviceIp = ip;
    }
    /**
     * Set the entire ext.ozone object at once
     */
    public func ozoneSetExtOzone(data: [AnyHashable: Any] ) {
        extOzoneDict = data;
    }
    /**
     * call this if you want to allow the code to insert the default ext.prebid object
     */
    public func ozoneIncludeExtPrebid() {
        doInsertExtPrebid = true;
    }
    
    @objc public var extOzoneDict:[AnyHashable: Any] = [:]
    @objc public var doInsertExtPrebid: Bool = false
    @objc public var ozoneAppPage: String? = nil
    @objc public var deviceIp: String? = nil
    
    
    // MARK: END OF OZONE


	/// Optional Delegate which returns Request and Response Data for further processing
    public weak var eventDelegate: PrebidEventDelegate?

    /// This property is set by the developer when he is willing to assign the assetID for Native ad.
    public var shouldAssignNativeAssetID : Bool = false
    
    /// This property is set by the developer when he is willing to share the location for better ad targeting
    public var shareGeoLocation = false
    
    /// Set the desidered verbosity of the logs
    public var logLevel: LogLevel {
        get { Log.logLevel }
        set { Log.logLevel = newValue }
    }
    
    /// The singleton instance of the `Prebid` class.
    public static let shared = Prebid()
    
    /// The version of the PrebidMobile SDK.
    public var version: String {
        PBMFunctions.sdkVersion()
    }
    
    /// The version of the OM SDK.
    public var omsdkVersion: String {
        OMSDKVersionProvider.omSDKVersionString
    }
    
    // MARK: - Public Properties (Prebid)
    
    /// Custom status endpoint for the Prebid Server.
    public var customStatusEndpoint: String? {
        didSet {
            PrebidSDKInitializer.setCustomStatusEndpoint(customStatusEndpoint)
        }
    }
    
    /// Timeout for Prebid requests in milliseconds.
    public var timeoutMillis: Int {
        didSet {
            timeoutMillisDynamic = NSNumber(value: timeoutMillis)
        }
    }
    
    /// Dynamic timeout value.
    public var timeoutMillisDynamic: NSNumber?
    
    /// Stored auction response.
    public var storedAuctionResponse: String?
    
    // MARK: - Public Properties (SDK)

    /// Indicates whether the PBS should cache the bid for the rendering API.
    /// If the value is true the SDK will make the cache request in order to report
    /// the impression event respectively to the legacy analytic setup.
    public var useCacheForReportingWithRenderingAPI = false
    
    /// Controls how long each creative has to load before it is considered a failure.
    public var creativeFactoryTimeout: TimeInterval = 6.0
    
    /// Controls how long video and interstitial creatives have to load before it is considered a failure.
    public var creativeFactoryTimeoutPreRenderContent: TimeInterval = 30.0
    
    /// If set to true, the output of PrebidMobile's internal logger is written to a text file. This can be helpful for debugging. Defaults to false.
    public var debugLogFileEnabled: Bool {
        get { Log.logToFile }
        set { Log.logToFile = newValue }
    }
    
    /// If true, the SDK will periodically try to listen for location updates in order to request location-based ads.
    public var locationUpdatesEnabled: Bool {
        get { LocationManager.shared.locationUpdatesEnabled }
        set { LocationManager.shared.locationUpdatesEnabled = newValue }
    }

    /// If true, the sdk will add `includewinners` flag inside the targeting object described in [PBS Documentation](https://docs.prebid.org/prebid-server/endpoints/openrtb2/pbs-endpoint-auction.html#targeting)
    public var includeWinners = false

    /// If true, the sdk will add `includebidderkeys` flag inside the targeting object described in [PBS Documentation](https://docs.prebid.org/prebid-server/endpoints/openrtb2/pbs-endpoint-auction.html#targeting)
    public var includeBidderKeys = false
    
    /**
     * If true, the SDK will not check the PBS status during initialization. This will save initialization time
     * if the PBS endpoint is always live and handled client side
     */
    public var shouldDisableStatusCheck: Bool = false
    
    // MARK: - Public Methods
    
    // MARK: - Stored Bid Response
    
    /// Adds a stored bid response.
    /// - Parameters:
    ///   - bidder: The name of the bidder.
    ///   - responseId: The response ID.
    public func addStoredBidResponse(bidder: String, responseId: String) {
        storedBidResponses[bidder] = responseId
    }
    
    /// Clears all stored bid responses.
    public func clearStoredBidResponses() {
        storedBidResponses.removeAll()
    }
    
    /// Retrieves stored bid responses.
    /// - Returns: An array of dictionaries containing stored bid responses, or nil if there are none.
    public func getStoredBidResponses() -> [[String: String]]? {
        var storedBidResponses: [[String: String]] = []
        
        for(bidder, responseId) in Prebid.shared.storedBidResponses {
            var storedBidResponse: [String: String] = [:]
            storedBidResponse["bidder"] = bidder
            storedBidResponse["id"] = responseId
            storedBidResponses.append(storedBidResponse)
        }
        return storedBidResponses.isEmpty ? nil : storedBidResponses
    }
    
    // MARK: - Custom Headers
    
    /// Adds a custom HTTP header.
    /// - Parameters:
    ///   - name: The name of the header.
    ///   - value: The value of the header.
    public func addCustomHeader(name: String, value: String) {
        customHeaders[name] = value
    }
    
    /// Clears all custom HTTP headers.
    public func clearCustomHeaders() {
        customHeaders.removeAll()
    }
    
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - gadMobileAdsObject: GADMobileAds object
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        _ gadMobileAdsObject: AnyObject? = nil,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nil)
            PrebidSDKInitializer.initializeSDK(completion)
            PrebidSDKInitializer.checkGMAVersion(gadObject: gadMobileAdsObject)
            PrebidSDKInitializer.logInitializerWarningIfNeeded()
    }
    
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - nonTrackingURL: The custom Prebid Server URL, used when a user rejected the app to track
    ///   - gadMobileAdsObject: GADMobileAds object
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        nonTrackingURLString: String,
        _ gadMobileAdsObject: AnyObject? = nil,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nonTrackingURLString)
            PrebidSDKInitializer.initializeSDK(completion)
            PrebidSDKInitializer.checkGMAVersion(gadObject: gadMobileAdsObject)
            PrebidSDKInitializer.logInitializerWarningIfNeeded()
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - gadMobileAdsVersion: GADMobileAds version string, use `GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)` to get it
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        gadMobileAdsVersion: String? = nil,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nil)
            PrebidSDKInitializer.initializeSDK(completion)
            PrebidSDKInitializer.checkGMAVersion(gadVersion: gadMobileAdsVersion)
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Checks the version of GMA SDK. If the version is not supported - logs warning.
    ///
    /// Use this SDK initializer if you're using PrebidMobile with GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - nonTrackingURL: The custom Prebid Server URL, used when a user rejected the app to track
    ///   - gadMobileAdsVersion: GADMobileAds version string, use `GADGetStringFromVersionNumber(GADMobileAds.sharedInstance().versionNumber)` to get it
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        nonTrackingURLString: String,
        gadMobileAdsVersion: String? = nil,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nonTrackingURLString)
            PrebidSDKInitializer.initializeSDK(completion)
            PrebidSDKInitializer.checkGMAVersion(gadVersion: gadMobileAdsVersion)
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Use this SDK initializer if you're using PrebidMobile without GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nil)
            PrebidSDKInitializer.initializeSDK(completion)
    }
    
    /// Initializes PrebidMobile SDK.
    ///
    /// Checks the status of Prebid Server. The `customStatusEndpoint` property is used as server status endpoint.
    /// If `customStatusEndpoint` property is not provided, the SDK will use default endpoint - `host` + `/status`.
    ///
    /// Use this SDK initializer if you're using PrebidMobile without GMA SDK.
    /// - Parameters:
    ///   - serverURL: The custom Prebid Server URL, used when a user allowed the app to track
    ///   - nonTrackingURL: The custom Prebid Server URL, used when a user rejected the app to track
    ///   - completion: returns initialization status and optional error
    public static func initializeSDK(
        serverURL: String,
        nonTrackingURLString: String,
        _ completion: PrebidInitializationCallback? = nil) throws {
            try Host.shared.setHostURL(serverURL, nonTrackingURLString: nonTrackingURLString)
            PrebidSDKInitializer.initializeSDK(completion)
    }
    
    // MARK: - Private Methods
    
    override init() {
        timeoutMillis = defaultTimeoutMillis
        timeoutMillisDynamic = NSNumber(value: timeoutMillis)
    }
    
    public static func registerPluginRenderer(_ pluginRenderer: PrebidMobilePluginRenderer) {
        PrebidMobilePluginRegister.shared.registerPlugin(pluginRenderer)
    }
    
    public static func unregisterPluginRenderer(_ pluginRenderer: PrebidMobilePluginRenderer) {
        PrebidMobilePluginRegister.shared.unregisterPlugin(pluginRenderer)
    }
    
    public static func containsPluginRenderer(_ pluginRenderer: PrebidMobilePluginRenderer) -> Bool {
        PrebidMobilePluginRegister.shared.containsPlugin(pluginRenderer)
    }
}
