//
//  BAEnvironmentManager.swift
//  Babble
//
//  Created by Liyu Wang on 17/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import Foundation

struct BAEnvironmentManager {
    static let shared = BAEnvironmentManager()
    
    func getSystemLanguage() -> String {
        return Locale.preferredLanguages.first ?? "en"
    }
}
