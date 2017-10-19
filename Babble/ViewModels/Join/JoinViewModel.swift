//
//  JoinViewModel.swift
//  Babble
//
//  Created by Liyu Wang on 17/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import Foundation
import RxSwift
import SwiftKeychainWrapper

class JoinViewModel: BAViewModel {
    let userWebService: UserWebService
    
    // MARK: - In
    var age = Variable<Int>(0)
    var gender = Variable<String>("")
    var seeking = Variable<String>("")
    
    // MARK: - Out
    var isCreateUserEnabled: Observable<Bool> {
        return Observable.combineLatest(age.asObservable(), gender.asObservable(), seeking.asObservable()) {
            (age, gender, seeking) in
            return age >= 18
                && gender.characters.count > 0
                && seeking.characters.count > 0
        }
    }
    
    init(userWebService: UserWebService = UserWebService()) {
        self.userWebService = userWebService
    }
    
    func createUser() {
        userWebService.createUser(
            age: age.value,
            gender: gender.value,
            seeking: seeking.value,
            language: BAEnvironmentManager.shared.getSystemLanguage()) { [weak self] (joinModel, error) in
                if let model = joinModel {
                    KeychainWrapper.standard.set(model.token, forKey: "token")
                } else {
//                    self?.displayError(error! as NSError)
                    self?.emitDisplayErrorEvent(error: error)
                }
        }
        
    }
}
