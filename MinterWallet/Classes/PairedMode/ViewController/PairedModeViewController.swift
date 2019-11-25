//
//  PairedModePairedModeViewController.swift
//  MinterWallet
//
//  Created by Roman Slysh on 17/10/2019.
//  Copyright © 2019 Minter. All rights reserved.
//

import UIKit
import SwiftOTP
import NotificationBannerSwift

class PairedModeViewController: UIViewController {

    // MARK: - IBOutlet

    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var textView: GrowingDefaultTextView! {
        didSet {
            textView.textContainerInset = UIEdgeInsets(top: 10.0, left: 16.0, bottom: 16.0, right: 16.0)
        }
    }
    @IBOutlet weak var secretCodeQRImageView: UIImageView!
    @IBOutlet weak var secretCodeButton: UIButton!

    var viewModel = PairedModeViewModel()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()

        if self.shouldShowTestnetToolbar {
            self.topConstraint.constant = 77.0
            self.view.addSubview(self.testnetToolbarView)
        }

        generateSecretCode()
    }

    @IBAction func activateButtonDidTap(_ sender: Any) {
        errorLabel.text = ""
        textView.setValid()

        let mnemonicText = textView.text.split(separator: " ")

        guard viewModel.isCorrect(mnemonic: textView.text) == nil else {
            let err = type(of: viewModel).ValidationError.wrongMnemonic
            textView.setInvalid()
            errorLabel.text = viewModel.validationText(for: err)
            return
        }

        let alert = BaseAlertController(title: "Attention!".localized(), message: "Confirm, you have backed up your secret code. If you did not do this you lose access to your wallet!".localized(), preferredStyle: .alert)
        let yesAction = UIAlertAction(title: "YES", style: .default) { _ in
            self.viewModel.saveAccount(id: -1, mnemonic: mnemonicText.joined(separator: " "), pairedCode: self.secretCodeButton.titleLabel?.text)
        }
        let noAction = UIAlertAction(title: "NO", style: .cancel)
        alert.addAction(yesAction)
        alert.addAction(noAction)
        alert.view.tintColor = UIColor.mainColor()

        present(alert, animated: true)
    }

    func generateSecretCode() {
        let secretCode = String.random(length: 10).base32EncodedString
        secretCodeButton.setTitle(secretCode, for: .normal)

        let QRCode = "otpauth://totp/BIPWallet?secret=\(secretCode)&issuer=iOSBIP"
        let image = generateQRCode(from: QRCode)
        secretCodeQRImageView.image = image
    }

    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    @IBAction func secretCodeButtonPressed(_ sender: Any) {
        SoundHelper.playSoundIfAllowed(type: .cancel)
        UIPasteboard.general.string = secretCodeButton.titleLabel?.text
        let banner = NotificationBanner(title: "Copied!", subtitle: nil, style: .info)
        banner.show()
    }
}

extension PairedModeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
        }
        return true
    }
}
