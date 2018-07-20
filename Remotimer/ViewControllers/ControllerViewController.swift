//
//  ControllerViewController.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 3..
//  Copyright © 2018년 ncode. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class ControllerViewController: UIViewController {

    @IBOutlet weak var connectConditionView: UIView!
    @IBOutlet weak var connectConditionLabel: UILabel!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var clearButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var btnSet: UIButton!
    @IBOutlet weak var btnReset: UIButton!
    @IBOutlet weak var btnStartPause: UIButton!
    @IBOutlet weak var btnStop: UIButton!
    @IBOutlet weak var sliderOuterView: UIView!
    @IBOutlet weak var sliderInnerView: UIView!
    @IBOutlet weak var wheelGestureRecognizer: UIWheelGestureRecognizer!

    let viewModel = ControllerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        bindUI()
        bindAction()
    }

    override var prefersStatusBarHidden: Bool { return true }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        wheelGestureRecognizer.setHandler(handler: nil)
    }

    private func initUI() {
        sliderOuterView.addGestureRecognizer(wheelGestureRecognizer)
        wheelGestureRecognizer.setHandler(handler: handleWheelGesture)
    }

    private func setupUI() {
        connectConditionView.layer.cornerRadius = 10
        sliderOuterView.layer.cornerRadius = sliderOuterView.bounds.width / 2
        sliderInnerView.layer.cornerRadius = sliderInnerView.bounds.width / 2
        wheelGestureRecognizer.maxDistance = Double(sliderOuterView.bounds.width / 2)
        wheelGestureRecognizer.minDistance = Double(sliderInnerView.bounds.width / 2)
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
    }

    private func bindAction() {
        view.rx.tapped()
            .drive(onNext: { [unowned self] _ in self.view.endEditing(true) })
            .disposed(by: disposeBag)

        sendButton.rx.tap.asDriver()
            .map({ [unowned self] _ in self.messageField.text ?? "" })
            .drive(onNext: viewModel.sendMessage)
            .disposed(by: disposeBag)

        clearButton.rx.tap.asDriver()
            .map({ _ in "" })
            .do(onNext: { [unowned self] in self.messageField.text = $0 })
            .drive(onNext: viewModel.sendMessage)
            .disposed(by: disposeBag)

        btnSet.rx.tap.asDriver()
            .drive(onNext: viewModel.setTimeToClient)
            .disposed(by: disposeBag)

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

    private func handleWheelGesture(sender: UIWheelGestureRecognizer) {
        if sender.lastDirection != sender.direction { sender.angle = 0 }
        let angleToSecond = 5 * sender.angle / 360.0 //5 minute per wheel
        viewModel.moveTimer(angleToSecond)
    }
}
