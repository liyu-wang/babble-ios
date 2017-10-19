//
//  LWSlideUpNavigationController.swift
//  Babble
//
//  Created by Liyu Wang on 11/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import UIKit

class LWSlideUpNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.updatePreferredContentSize(with: self.traitCollection)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        self.updatePreferredContentSize(with: newCollection)
    }
    
    private func updatePreferredContentSize(with traitCollection: UITraitCollection) {
        self.preferredContentSize = CGSize(width: self.view.bounds.width, height: traitCollection.verticalSizeClass == .compact ? 250 : 250)
    }
}
