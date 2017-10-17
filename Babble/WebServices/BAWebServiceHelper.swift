//
//  BAWebServiceHelper.swift
//  Babble
//
//  Created by Liyu Wang on 16/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import Foundation
import Alamofire

struct BAWebServiceHelper {

    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
    static let baseAPIURLString = "http://localhost:8088"
    #else
    static let baseAPIURLString = "http://192.168.0.97:8088"
    #endif
    
    static func createRequest(
        method: Alamofire.HTTPMethod,
        path: String,
        parameters: [String: Any]?,
        timeout: TimeInterval? = nil
    ) throws -> URLRequest {
        let url = try baseAPIURLString.asURL()
        let mutableURLRequest = NSMutableURLRequest(url: url.appendingPathComponent(path))
        mutableURLRequest.httpMethod = method.rawValue
        
        if let timeout = timeout {
            mutableURLRequest.timeoutInterval = timeout
        }
        
        return try URLEncoding.default.encode(mutableURLRequest as URLRequest, with: parameters)
    }
}
