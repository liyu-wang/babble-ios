//
//  JoinViewController.swift
//  Babble
//
//  Created by Liyu Wang on 6/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import RxCocoa
import RxSwift
import SwiftKeychainWrapper

class JoinViewController: BAViewController {

    let disposeBag = DisposeBag()
    
    var argsDict: Variable<[String: Any]> = Variable([:])
    
    var ageSeletedIndex = 0
    var genderSelectedIndex = 0
    var seekingSelectedIndices = [0]
    
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
    
    private func createUser() {
        UserWebService.shared.createUser(
            age: argsDict.value["age"] as! Int,
            gender: argsDict.value["gender"] as! String,
            seeking: argsDict.value["seeking"] as! String,
            language: BAEnvironmentManager.shared.getSystemLanguage(),
            disposeBag: disposeBag) { [weak self] (token, error) in
                if let token = token {
                    KeychainWrapper.standard.set(token, forKey: "token")
                } else {
                    self?.displayError(error! as NSError)
                }
        }
        
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
                self?.showSeekingSelectionSheet()
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
                                             initialSelection: self.ageSeletedIndex,
                                             doneBlock: { (pick, index, value) in
                                                self.argsDict.value["age"] = value!
                                                self.ageButton.setTitle("\(value!)", for: .normal)
                                                self.ageSeletedIndex = index
                                             },
                                             cancel: { (picker) in
                                                
                                             },
                                             origin: self.ageButton)
        picker?.hideCancel = true
        picker?.show()
    }
    
    private func showGenderActionSheetPicker() {
        
        let genderValues = ["m", "f"]
        let picker = ActionSheetStringPicker(title: "Gender",
                                             rows: ["Male", "Female"],
                                             initialSelection: self.genderSelectedIndex,
                                             doneBlock: { (picker, index, value) in
                                                self.genderButton.setTitle("\(value!)", for: .normal)
                                                self.argsDict.value["gender"] = genderValues[index]
                                                self.genderSelectedIndex = index
                                             },
                                             cancel: { (picker) in
                                                
                                             },
                                             origin: self.genderButton)
        picker?.hideCancel = true
        picker?.show()
    }
    
    private func showSeekingSelectionSheet() {
        
        let seekingValues = ["m", "f", "tm", "tf", "ot"]
        
        let multiSelectionViewController = LWMultiSelectionTableViewController(
            title: "Seeking",
            strs: ["Men", "Women", "Transmen", "Transwomen", "Pangender/Other"],
            selected: self.seekingSelectedIndices,
            completion: { (multiSelectionController, selectedItems, selectedIndices) in
                let str = selectedItems.joined(separator: ",")
                self.seekingButton.setTitle(str, for: .normal)
                
                var selectedValues: [String] = []
                for i in selectedIndices {
                    selectedValues.append(seekingValues[i])
                }
                self.argsDict.value["seeking"] = selectedValues.joined(separator: ",")
                
                self.seekingSelectedIndices = selectedIndices
        })
        multiSelectionViewController.zeroSelectionAllowed = false
        multiSelectionViewController.cancelButtonHidden = true
        
        let navController = LWSlideUpNavigationController(rootViewController: multiSelectionViewController)
        let slideUpPresentationController = LWSlideUpPresentationController(presentedViewController: navController, presenting: self)
        navController.transitioningDelegate = slideUpPresentationController
        
        self.present(navController, animated: true, completion: nil)
    }
    
    private func showTermsOfService() {
        
    }
}
