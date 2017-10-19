//
//  BAViewController.swift
//  Babble
//
//  Created by Liyu Wang on 9/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit
import RxSwift

class BAViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func observeDisplayErrorEvent(from viewModel: BAViewModel) {
        viewModel.error.asObservable()
            .filter({ (error) -> Bool in
                return error != nil
            })
            .subscribe { (event) in
                self.displayError((event.element!)! as NSError)
            }.disposed(by: disposeBag)
    }

    func displayError(_ error: NSError?) {
        if let e = error {
            let alertController = UIAlertController(title: "Error", message: e.localizedDescription, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                // do nothing...
                
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
