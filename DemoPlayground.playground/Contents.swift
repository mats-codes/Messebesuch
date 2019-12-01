import RxSwift


// 1. Beispiel --> Einfache Subscription
Observable.from(["Hello", "RxSwift"]).subscribe(onNext: {print($0)})



//2. & 3. Beispiel --> Asynchronität & DisposeBag
// Creating the Subject
let simpleSubject = PublishSubject<String>()

// Creating the Disposebag
let disposeBag = DisposeBag()

// Create Subscription
simpleSubject.asObservable()
    .subscribe(onNext: { print($0) }) // Until here NOTHING HAPPENS!!
    .disposed(by: disposeBag)

// Emitting Events
simpleSubject.onNext("Hello")
simpleSubject.onNext("RxSwift")

// Emitting one Event after three Seconds
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    simpleSubject.onNext("RxSwift is Awesome!")
}



// Helper struct and subject
struct Information {
    var txt: String
    var isRxSwiftRelated: Bool
}



// 4. Beispiel --> Ein Operator
var informationSubject = PublishSubject<Information>()
informationSubject.asObservable()
    .filter({$0.isRxSwiftRelated})
    .subscribe(onNext: {print($0.txt)})
    .disposed(by: disposeBag)

informationSubject.onNext(Information(txt: "Subscription", isRxSwiftRelated:true))
informationSubject.onNext(Information(txt: "BlaBlaBla", isRxSwiftRelated:false))



// 5. Beispiel --> Ein Operatoren
informationSubject = PublishSubject<Information>()
informationSubject.asObservable()
    .filter({$0.isRxSwiftRelated})
    .map({$0.txt})
    .subscribe(onNext: {print($0)})
    .disposed(by: disposeBag)

informationSubject.onNext(Information(txt: "Subscription", isRxSwiftRelated:true))
informationSubject.onNext(Information(txt: "BlaBlaBla", isRxSwiftRelated:false))



// 6. Beispiel --> Debug-Statement
informationSubject = PublishSubject<Information>()
informationSubject.asObservable()
    .filter({$0.isRxSwiftRelated})
    .map({$0.txt})
    .subscribe(onNext: {print($0)})
    .disposed(by: disposeBag)

informationSubject.onNext(Information(txt: "Subscription", isRxSwiftRelated:true))
informationSubject.onNext(Information(txt: "BlaBlaBla", isRxSwiftRelated:false))



// 7. Beispiel --> Mehrere Observables
// Create Subject
informationSubject = PublishSubject<Information>()
let drankEnoughCoffeSubject = PublishSubject<Bool>()

// Create Subscription
Observable.combineLatest(informationSubject, drankEnoughCoffeSubject)
    .do(onNext: {print($0)})                        // Printing all values of stream
    .filter({ $0.0.isRxSwiftRelated && $0.1})       // Filtering irrelevant stuff and everything if Dev hadn't had enough coffee
    .map({"Dev learned: \($0.0.txt)"})              // Mapping input to output string
    .subscribe(onNext: {print($0)                   // Printing outpur
    }).disposed(by: disposeBag)

// Emitting Events
drankEnoughCoffeSubject.onNext(true)
informationSubject.onNext(Information(txt: "Subscription", isRxSwiftRelated:true))
informationSubject.onNext(Information(txt: "BlaBlaBla", isRxSwiftRelated:false))

drankEnoughCoffeSubject.onNext(false)
informationSubject.onNext(Information(txt: "Observable", isRxSwiftRelated:true))
informationSubject.onNext(Information(txt: "Operator", isRxSwiftRelated:true))



// Best Practice --> no nested Subscriptions
Observable.of(1,2,3)
    .flatMap{
        // This could be an HTTP-Call
        Observable.from(["The value is \($0)"])
    }
    // This subscribes to the elements of the inner Observable
    .subscribe(onNext:{print($0)})
