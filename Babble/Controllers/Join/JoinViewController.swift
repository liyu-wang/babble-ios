//
//  JoinViewController.swift
//  Babble
//
//  Created by Liyu Wang on 6/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Alamofire
import RxSwift
import RxCocoa
import RxAlamofire
import SwiftKeychainWrapper

class JoinViewController: BAViewController {

    let sourceStringURL = "http://localhost:8088/users"
    let disposeBag = DisposeBag()
    
    var argsDict: Variable<[String: Any]> = Variable([:])
    
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var seekingButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        startButton.isEnabled = false
        
        setupReactive()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }    
    
}

extension JoinViewController {
    
    private func setupReactive() {
        ageButton.rx.tap
            .bind{ [weak self] in
                self?.showAgeActionSheetPicker()
            }.disposed(by: disposeBag)
        
        genderButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showGenderActionSheetPicker()
            }).disposed(by: disposeBag)
        
        seekingButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.argsDict.value["seaking"] = "0, 1"
            }).disposed(by: disposeBag)
        
        startButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.createUser()
            }).disposed(by: disposeBag)
        
        argsDict.asObservable()
            .subscribe(onNext: { [weak self] args in
                self?.startButton.isEnabled = (args.count == 3)
            }).disposed(by: disposeBag)
        
        termsButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showTermsOfService()
            }).disposed(by: disposeBag)
    }
    
    private func showAgeActionSheetPicker() {
        let picker = ActionSheetStringPicker(title: "Age",
                                             rows: [Int](18...100),
                                             initialSelection: 0,
                                             doneBlock: { (pick, index, value) in
                                                self.argsDict.value["age"] = value!
                                                self.ageButton.setTitle("\(value!)", for: .normal)
                                             },
                                             cancel: { (picker) in
                                                
                                             },
                                             origin: self.ageButton)
        picker?.hideCancel = true
        picker?.show()
    }
    
    private func showGenderActionSheetPicker() {
        let picker = ActionSheetStringPicker(title: "Gender",
                                             rows: ["Male", "Female"],
                                             initialSelection: 0,
                                             doneBlock: { (picker, index, value) in
                                                self.argsDict.value["gender"] = value!
                                                self.genderButton.setTitle("\(value!)", for: .normal)
                                             },
                                             cancel: { (picker) in
                                                
                                             },
                                             origin: self.genderButton)
        picker?.hideCancel = true
        picker?.show()
    }
    
    private func showSeekingSelectionSheet() {
        
    }
    
    private func showTermsOfService() {
        
    }
}

extension JoinViewController {
    
    private func createUser() {
        
        RxAlamofire.requestJSON(.post, sourceStringURL)
            .debug()
            .subscribe(onNext: { [weak self] (r, json) in
                if let dict = json as? [String: AnyObject] {
                    KeychainWrapper.standard.set(dict["token"] as! String, forKey: "token")
                }
                }, onError: { [weak self] (error) in
                    self?.displayError(error as NSError)
            })
            .disposed(by: disposeBag)
    }
}
