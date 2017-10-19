//
//  UserWebService.swift
//  Babble
//
//  Created by Liyu Wang on 13/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import Foundation
import Alamofire
import RxAlamofire
import RxSwift

enum UserRouter: URLRequestConvertible {
    case create(age: Int, gender: String, seeking: String, language: String)
    
    func asURLRequest() throws -> URLRequest {
        let req: (method: Alamofire.HTTPMethod, path: String, parameters: Parameters?) = {
            switch self {
            case let .create(age, gender, seeking, language):
                return (.post,
                        "/users",
                        ["age": age, "gender": gender, "seeking": seeking, "language": language])
            }
        }()
        
        return try BAWebServiceHelper.createRequest(method: req.method, path: req.path, parameters: req.parameters)
    }
    
}

struct UserWebService {
    var disposeBag: DisposeBag = DisposeBag()

    func createUser(
        age: Int,
        gender: String,
        seeking: String,
        language: String,
        completion: @escaping ((_ model: JoinModel?, _ error: Error?) -> Void))
    {   
        RxAlamofire.requestJSON(UserRouter.create(age: age, gender: gender, seeking: seeking, language: language))
            .debug()
            .subscribe(onNext: { (r, json) in
                if let dict = json as? [String: AnyObject] {
                    let model = JoinModel(userID: dict["userId"] as! String,
                                          token: dict["token"] as! String)
                    completion(model, nil)
                }
            }, onError: { (error) in
                completion(nil, error)
            })
            .disposed(by: disposeBag)
    }
}
