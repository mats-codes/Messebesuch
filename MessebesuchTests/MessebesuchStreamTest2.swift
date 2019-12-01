//
//  MessebesuchStreamTest2.swift
//  MessebesuchTests
//
//  Created by Mattes Wieben on 01.12.19.
//  Copyright © 2019 matscodes. All rights reserved.
//

import XCTest
import RxSwift
import RxTest
import RxBlocking
@testable import Messebesuch

class MessebesuchStreamTest2: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testWithRxBlocking() {
        let input = [1,2,3]
        let output = try! Observable.from(input).toBlocking().toArray()
        XCTAssertEqual(input, output)
    }
    
    func testMessebesuchStream() {
        // Der scheduler wird die Test-Events zu definierten Zeitpunkten simulieren
        let scheduler = TestScheduler(initialClock: 0)
        let disposeBag = DisposeBag()
        
        // Definition der Informationen, die emittiert werden
        let information1 = Information(txt: "Subscription", isRxSwiftRelated: true)
        let smalltalk1 = Information(txt: "Bla", isRxSwiftRelated: false)
        let information2 = Information(txt: "Operator", isRxSwiftRelated: true)
        let smalltalk2 = Information(txt: "Irgendetwas über das Wetter", isRxSwiftRelated: false)
        
        // Erstellen eines Observables mit den definieren Informationen
        let informationObservable = scheduler.createHotObservable([
            Recorded.next(1, information1),
            Recorded.next(2, smalltalk1),
            Recorded.next(3, information2),
            Recorded.next(4, smalltalk2),
            Recorded.completed(6)
            ]).asObservable();
        
        
        // Erstellen eines Observables mit den Kaffeezuständen
        let coffeeObservable = scheduler.createHotObservable([
            Recorded.next(0, true),
            Recorded.next(2, false),
            Recorded.completed(8)
            ]).asObservable();
        
        // Definition der Events, die als Ausgabe des Messebesuchs erwartet werden.
        let expectedEvents = [
            Recorded.next(1, "Dev learned: Subscription"),
            Recorded.completed(8)
        ]
        
        // Initialisierung des Messebesuchs
        let messebesuch = Messebesuch(informationFlow: informationObservable, coffeeSupply: coffeeObservable)
        
        // Zuweisung des AusgabeStreams zu einem TestObserver, sodass die
        // Ergebnisse mit den erwarteten Ergebnissen verglichen werden können
        let testObserver = scheduler.createObserver(String.self)
        messebesuch.messeLearnings
            .subscribe(testObserver)
            .disposed(by: disposeBag)
        
        // Start der Erzeugung der Events
        scheduler.start()
        
        // Vergleich der Ausgabe mit der erwarteten Ausgabe
        XCTAssertEqual(expectedEvents, testObserver.events)
    }
}
