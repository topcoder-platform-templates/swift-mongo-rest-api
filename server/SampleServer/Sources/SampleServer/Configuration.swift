//
//  Configuration.swift
//  SampleServer
//
//  Created by Volkov Alexander on 10/12/19.
//

import Foundation

/// A helper class to get the configuration data in the plist file.
final class Configuration: NSObject {
    
    // singleton
    static let shared = Configuration()
    
    // port
    static var port: Int {
        return 8080
    }
    
    // database name
    static var databaseName: String {
        return ProcessInfo.processInfo.environment["DATABASE_NAME"] ?? "test"
    }
    
    // database host
    static var databaseHost: String {
        #if DEBUG
            return "localhost"
        #else
            return ProcessInfo.processInfo.environment["DATABASE_HOST"] ?? "database"
        #endif
    }
    
    // database user
    static var databaseUser: String {
        #if DEBUG
            return "root"
        #else
            return ProcessInfo.processInfo.environment["DATABASE_USERNAME"] ?? "root"
        #endif
    }
    
    // database password
    static var databasePassword: String {
        #if DEBUG
            return "myPassword"
        #else
            return ProcessInfo.processInfo.environment["DATABASE_PASSWORD"] ?? "myPassword"
        #endif
    }

}
