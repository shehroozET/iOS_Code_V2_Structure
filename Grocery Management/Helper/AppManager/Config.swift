//
//  Config.swift
//  Grocery Management
//
//  Created by mac on 20/05/2025.
//

import Foundation

let App_API_BASE_URL_PRODUCTION: String = ""
let App_API_BASE_URL_STAGING: String = ""

public enum AppEnvironment {
    case production
    case staging
}

public protocol AppFeatures {
    
}

public protocol AppConfiguration {
    var features: AppFeatures { get set }
    var api: String { get set }
}

public struct DefaultAppFeatures: AppFeatures {
    public var nightMode: Bool
    
    public init(nightMode: Bool = true) {
        self.nightMode = nightMode
    }
}

struct DefaultAppConfiguration: AppConfiguration {
    var features: AppFeatures
    var api: String
    
    init() {
        self.features = DefaultAppFeatures()
        self.api = App_API_BASE_URL_PRODUCTION
    }
}


public class Config {
    public static let shared: Config = Config()
    
    private var _configuration: AppConfiguration
    
    private init() {
        self._configuration = DefaultAppConfiguration()
    }
    
    public var configuration: AppConfiguration {
        get {
            return _configuration
        }
        set {
            _configuration = newValue
        }
    }

    public var features: AppFeatures {
        get {
            return _configuration.features
        }
        set {
            _configuration.features = newValue
        }
    }
    
    public var environment: AppEnvironment {
        get {
            return _configuration.api == App_API_BASE_URL_STAGING ? .staging : .production
        }
        set {
            switch newValue {
            case .production:
                _configuration.api = App_API_BASE_URL_PRODUCTION
            case .staging:
                _configuration.api = App_API_BASE_URL_STAGING
            }
        }
    }

    /**
     * @deprecated Use configuration getter instead
    **/
    @available(*, deprecated, message: "Use configuration getter property instead")
    public func getConfiguration() -> AppConfiguration {
        return _configuration
    }

    @available(*, deprecated, message: "Use configuration setter property instead")
    public func setConfiguration(configuration: AppConfiguration) {
        _configuration = configuration
    }
}
