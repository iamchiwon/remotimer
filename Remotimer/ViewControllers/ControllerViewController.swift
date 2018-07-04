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

    let viewModel = ControllerViewModel()
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        connectConditionView.layer.cornerRadius = 10

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
    }

    private func bindAction() {
        view.rx.tapped()
            .drive(onNext: { [unowned self] _ in
                self.view.endEditing(true)
            })
            .disposed(by: disposeBag)

        sendButton.rx.tap.asDriver()
            .map({ [unowned self] _ in self.messageField.text ?? "" })
            .drive(onNext: viewModel.sendMessage)
            .disposed(by: disposeBag)

        clearButton.rx.tap.asDriver()
            .map({ _ in "" })
            .do(onNext: { [unowned self] emptyText in
                self.messageField.text = emptyText
            })
            .drive(onNext: viewModel.sendMessage)
            .disposed(by: disposeBag)
    }
}
