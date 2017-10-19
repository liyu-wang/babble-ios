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

class JoinViewController: BAViewController {

    var joinViewModel = JoinViewModel()
    
    @IBOutlet weak var ageButton: UIButton!
    @IBOutlet weak var genderButton: UIButton!
    @IBOutlet weak var seekingButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var termsButton: UIButton!
    
    var ageSelectedIndex = 0
    var genderSelectedIndex = 0
    var seekingSelectedIndices: [Int] = [0]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.setupReactive()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension JoinViewController {
    
    func setupReactive() {
        observeDisplayErrorEvent(from: self.joinViewModel)
        
        self.joinViewModel.isCreateUserEnabled.bind(to: startButton.rx.isEnabled).disposed(by: disposeBag)
        
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
                self?.joinViewModel.createUser()
            }).disposed(by: disposeBag)
        
        termsButton.rx.tap
            .subscribe(onNext: { [weak self] in
                self?.showTermsOfService()
            }).disposed(by: disposeBag)
    }
    
    private func showAgeActionSheetPicker() {
        let picker = ActionSheetStringPicker(title: "Age",
                                             rows: [Int](18...100),
                                             initialSelection: self.ageSelectedIndex,
                                             doneBlock: { (pick, index, value) in
                                                self.ageButton.setTitle("\(value!)", for: .normal)
                                                self.ageSelectedIndex = index
                                                
                                                self.joinViewModel.age.value = value as! Int
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
                                                self.genderSelectedIndex = index
                                                
                                                self.joinViewModel.gender.value = genderValues[index]
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
                
                self.seekingSelectedIndices = selectedIndices
                
                var selectedValues: [String] = []
                for i in selectedIndices {
                    selectedValues.append(seekingValues[i])
                }
                self.joinViewModel.seeking.value = selectedValues.joined(separator: ",")
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
