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
import RxOptional
import Tibei

class ControllerViewModel {

    var serverService: ServerService!

    let timer = BehaviorRelay<TimeInterval>(value: 0)
    let timerStarted = BehaviorRelay<Bool>(value: false)
    let disposeBag = DisposeBag()

    let connected = BehaviorRelay<Bool>(value: false)

    init() {
        serverService = ServerService(serviceName: RemotimerServiceName)
        serverService.startServer()
        serverService.disposed(by: disposeBag)

        serverService.clients.map({ $0.isNotEmpty })
            .bind(to: connected)
            .disposed(by: disposeBag)

        timerStarted
            .distinctUntilChanged()
            .subscribe(onNext: { [weak self] started in
                guard let `self` = self else { return }
                started ? self.startTimer() : self.stopTimer()
            })
            .disposed(by: disposeBag)
        
        setupImpactFeedback()
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

    func moveTimer(_ mov: TimeInterval) {
        timer.accept(max(timer.value + mov, 0))
    }

    func setTimeToClient(sender: Any) {
        let command = RemotimerMessage(command: "setTime", parameter: "\(timer.value)")
        serverService.broadcast(command: command)
    }

    func reset(sender: Any) {
        stop(sender: sender)

        timer.accept(0)
        setTimeToClient(sender: sender)
        
        let command = RemotimerMessage(command: "resetTimer")
        serverService.broadcast(command: command)
    }

    func startPause(sender: Any) {
        timerStarted.accept(!timerStarted.value)

        let command = RemotimerMessage(command: timerStarted.value ? "startTimer" : "pauseTimer")
        serverService.broadcast(command: command)
    }

    func stop(sender: Any) {
        timerStarted.accept(false)

        let command = RemotimerMessage(command: "stopTimer")
        serverService.broadcast(command: command)
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
    
    //
    // Haptic Feedback
    //
    
    private let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
    
    private func setupImpactFeedback() {
        // Prepare impact feedbacks
        mediumImpact.prepare()
        
        // Impact on minutes changed
        timer
            .withLatestFrom(timerStarted, resultSelector: { $1 ? nil : $0 }) // Pass when timer stopped
            .filterNil()
            .map({ timeToMinute($0) })
            .distinctUntilChanged()
            .skip(1) // Skip first init
            .subscribe(onNext: { [weak self] _ in
                self?.impactMediumFeedback()
            })
            .disposed(by: disposeBag)
    }
    
    private func impactMediumFeedback() {
        mediumImpact.impactOccurred()
    }
}
