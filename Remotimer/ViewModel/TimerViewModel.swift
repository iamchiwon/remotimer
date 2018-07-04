//
//  TimerViewModel.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 5..
//  Copyright © 2018년 ncode. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TimerViewModel {

    var clientService: ClientService!
    let disposeBag = DisposeBag()

    let connected = BehaviorRelay<Bool>(value: false)
    let timer = BehaviorRelay<Int>(value: 0)
    let serverMessage = PublishRelay<String>()

    init() {
        clientService = ClientService()
        clientService.connectService(serviceName: RemotimerServiceName)
        clientService.disposed(by: disposeBag)

        clientService.connected.bind(to: connected).disposed(by: disposeBag)
        clientService.messages.subscribe(onNext: handleMessage).disposed(by: disposeBag)
    }

    func handleMessage(_ message: RemotimerMessage) {
        switch message.command {

        case "message":
            serverMessage.accept(message.parameter)

        case "clear":
            serverMessage.accept("")

        default:
            break
        }
    }

    func updateTime(_ time: Int) {
        let newValue = max(timer.value + time, 0)
        timer.accept(newValue)
    }

    func timeToString(_ time: Int) -> String {
        let minute = time / 60
        let second = time % 60
        return String(format: "%02d:%02d", minute, second)
    }
}
