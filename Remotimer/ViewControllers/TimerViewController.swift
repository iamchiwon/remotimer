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
    @IBOutlet weak var btnSub30: UIImageView!
    @IBOutlet weak var btnSub10: UIImageView!
    @IBOutlet weak var btnSub5: UIImageView!
    @IBOutlet weak var btnAdd5: UIImageView!
    @IBOutlet weak var btnAdd10: UIImageView!
    @IBOutlet weak var btnAdd30: UIImageView!
    @IBOutlet weak var btnAction: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!

    let viewModel = TimerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        connectConditionView.layer.cornerRadius = 10
        messageLabel.isHidden = true

        bindUI()
        bindAction()
    }

    override var prefersStatusBarHidden: Bool { return true }

    private func bindUI() {
        viewModel.connected.map { $0 ? #colorLiteral(red: 0.4862745098, green: 0.7019607843, blue: 0.2588235294, alpha: 1): #colorLiteral(red: 0.8470588235, green: 0.262745098, blue: 0.08235294118, alpha: 1) }
            .bind(to: connectConditionView.rx.backgroundColor)
            .disposed(by: disposeBag)

        viewModel.connected.map { $0 ? "Connected" : "Disconnected" }
            .bind(to: connectConditionLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.timer.map(viewModel.timeToString)
            .bind(to: timerLabel.rx.text)
            .disposed(by: disposeBag)

        viewModel.connected
            .bind(to: controlsStackView.rx.isHidden)
            .disposed(by: disposeBag)
    }

    private func bindAction() {
        let sub30 = btnSub30.rx.tapped().map({ _ in -30 })
        let sub10 = btnSub10.rx.tapped().map({ _ in -10 })
        let sub5 = btnSub5.rx.tapped().map({ _ in -5 })
        let add5 = btnAdd5.rx.tapped().map({ _ in 5 })
        let add10 = btnAdd10.rx.tapped().map({ _ in 10 })
        let add30 = btnAdd30.rx.tapped().map({ _ in 30 })
        Driver.merge([sub30, sub10, sub5, add5, add10, add30])
            .drive(onNext: { [unowned self] in self.viewModel.updateTime($0) })
            .disposed(by: disposeBag)

        viewModel.serverMessage
            .subscribe(onNext: { [unowned self] text in
                self.messageLabel.text = text
                self.messageLabel.isHidden = text.isEmpty
            })
            .disposed(by: disposeBag)
    }
}
