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
    let timer = BehaviorRelay<TimeInterval>(value: 0)
    let timerStarted = BehaviorRelay<Bool>(value: false)
    let serverMessage = PublishRelay<String>()

    init() {
        clientService = ClientService()
        clientService.connectService(serviceName: RemotimerServiceName)
        clientService.disposed(by: disposeBag)

        clientService.connected
            .bind(to: connected)
            .disposed(by: disposeBag)

        clientService.messages
            .subscribe(onNext: { [weak self] msg in
                guard let `self` = self else { return }
                self.handleMessage(msg)
            })
            .disposed(by: disposeBag)

        connected
            .distinctUntilChanged()
            .filter(bypass)
            .subscribe(onNext: { [weak self] x in
                guard let `self` = self else { return }
                self.reset(sender: x)
            })
            .disposed(by: disposeBag)

        timerStarted
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] started in
                guard let `self` = self else { return }
                started ? self.startTimer() : self.stopTimer()
            })
            .disposed(by: disposeBag)
    }

    func handleMessage(_ message: RemotimerMessage) {
        switch message.command {

        case "message":
            serverMessage.accept(message.parameter)

        case "clear":
            serverMessage.accept("")

        case "resetTimer":
            reset(sender: message)

        case "setTime":
            let t = TimeInterval(message.parameter) ?? 0
            timer.accept(t)

        case "startTimer":
            startPause(sender: message)

        case "pauseTimer":
            startPause(sender: message)

        case "stopTimer":
            stop(sender: message)

        default:
            break
        }
    }

    func moveTimer(_ mov: TimeInterval) {
        timer.accept(max(timer.value + mov, 0))
    }

    func reset(sender: Any) {
        stop(sender: sender)
        timer.accept(0)
    }

    func startPause(sender: Any) {
        timerStarted.accept(!timerStarted.value)
    }

    func stop(sender: Any) {
        timerStarted.accept(false)
    }

    //
    // TIMER
    //

    private var internalTimer: Timer?

    private func startTimer() {
        internalTimer = Timer.scheduledTimer(withTimeInterval: 1,
                                             repeats: true,
                                             block: { [weak self] t in
                                                 guard let `self` = self else {
                                                     t.invalidate()
                                                     return
                                                 }
                                                 let nt = max(self.timer.value - 1, 0)
                                                 self.timer.accept(nt)
                                                 if nt == 0 {
                                                     t.invalidate()
                                                     self.timerStarted.accept(false)
                                                 }
                                             })
    }

    private func stopTimer() {
        if let t = internalTimer { t.invalidate() }
        internalTimer = nil
    }
}
