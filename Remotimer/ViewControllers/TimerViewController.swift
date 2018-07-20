//
//  TimerViewController.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 3..
//  Copyright © 2018년 ncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class TimerViewController: UIViewController {

    @IBOutlet weak var connectConditionView: UIView!
    @IBOutlet weak var connectConditionLabel: UILabel!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var controlsStackView: UIStackView!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnStartPause: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    let viewModel = TimerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindUI()
        bindAction()
    }

    override var prefersStatusBarHidden: Bool { return true }
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask { return .all }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sliderView.gestureRecognizers?.forEach({ g in
            sliderView.removeGestureRecognizer(g)
        })
    }

    private func initUI() {
        connectConditionView.layer.cornerRadius = 10
        messageLabel.isHidden = true

        let panGesture = UIPanGestureRecognizer()
        panGesture.maximumNumberOfTouches = 1
        sliderView.addGestureRecognizer(panGesture)
        panGesture.rx.event.asDriver()
            .drive(onNext: handlePanGesture)
            .disposed(by: disposeBag)
    }

    private func bindUI() {
        viewModel.connected.map { $0 ? #colorLiteral(red: 0.4862745098, green: 0.7019607843, blue: 0.2588235294, alpha: 1): #colorLiteral(red: 0.8470588235, green: 0.262745098, blue: 0.08235294118, alpha: 1) }
            .bind(to: connectConditionView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.connected.map { $0 ? "Connected" : "Disconnected" }
            .bind(to: connectConditionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.timer.map(timeToString)
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.timerStarted
            .map({ $0 ? "PAUSE" : "START" })
            .subscribe(onNext: { [unowned self] title in
                self.btnStartPause.setTitle(title, for: .normal)
            })
            .disposed(by: disposeBag)

        viewModel.connected
            .bind(to: controlsStackView.rx.isHidden)
            .disposed(by: disposeBag)

        viewModel.serverMessage
            .subscribe(onNext: { [unowned self] text in
                self.messageLabel.text = text
                self.messageLabel.isHidden = text.isEmpty
            })
            .disposed(by: disposeBag)
    }

    private func bindAction() {
        btnReset.rx.tap.asDriver()
            .drive(onNext: viewModel.reset)
            .disposed(by: disposeBag)

        btnStartPause.rx.tap.asDriver()
            .drive(onNext: viewModel.startPause)
            .disposed(by: disposeBag)

        btnStop.rx.tap.asDriver()
            .drive(onNext: viewModel.stop)
            .disposed(by: disposeBag)
    }

    private var lastPanningVelocityX: CGFloat = 0

    private func handlePanGesture(sender: UIPanGestureRecognizer) {
        let location = sender.translation(in: sender.view)
        let velX = sender.velocity(in: sender.view).x
        if sign(velX) != sign(lastPanningVelocityX) {
            sender.setTranslation(CGPoint.zero, in: sender.view)
        }
        lastPanningVelocityX = velX

        let width = sender.view?.bounds.width ?? 1
        let mins: CGFloat = UIDevice.current.orientation.isLandscape ? 10 : 5
        let mov = mins * location.x / width //5/10 minute per full slide
        viewModel.moveTimer(TimeInterval(mov))
    }
}
