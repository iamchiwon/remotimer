//
//  ControllerViewModel.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 5..
//  Copyright © 2018년 ncode. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Tibei

class ControllerViewModel {

    var serverService: ServerService!
    let disposeBag = DisposeBag()

    let connected = BehaviorRelay<Bool>(value: false)

    init() {
        serverService = ServerService(serviceName: RemotimerServiceName)
        serverService.startServer()
        serverService.disposed(by: disposeBag)

        serverService.clients.map({ $0.isNotEmpty })
            .bind(to: connected)
            .disposed(by: disposeBag)
    }

    func sendMessage(_ msg: String) {
        if msg.isEmpty {
            let command = RemotimerMessage(command: "clear")
            serverService.broadcast(command: command)
        } else {
            let command = RemotimerMessage(command: "message", parameter: msg)
            serverService.broadcast(command: command)
        }
    }
}
