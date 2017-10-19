//
//  BAViewModel.swift
//  Babble
//
//  Created by Liyu Wang on 18/10/17.
//  Copyright © 2017 Oasis. All rights reserved.
//

import Foundation
import RxSwift

class BAViewModel {
    // MARK: Out
    var error = Variable<Error?>(nil)
    
    func emitDisplayErrorEvent(error: Error?) {
        self.error.value = error
    }
}
