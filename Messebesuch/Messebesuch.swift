//
//  Messebesuch.swift
//  CrimeStream
//
//  Created by Mattes Wieben on 25.11.19.
//  Copyright 2019 matscodes. All rights reserved.
//

import Foundation
import RxSwift

class Messebesuch {
    var messeLearnings: Observable<String>
    
    init(informationFlow: Observable<Information>, coffeeSupply: Observable<Bool>) {
        messeLearnings = Observable.combineLatest(informationFlow, coffeeSupply)
            .do(onNext: {print($0)})
            .filter({$0.0.isRxSwiftRelated && $0.1})
            .map({"Dev learned: \($0.0.txt)"})
    }
}

