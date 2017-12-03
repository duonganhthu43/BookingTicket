//
//  SignInViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/2/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class SignInViewControler: UIViewController {
    struct Validation {
        static let emailMaxlength: Int = 100
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(overlayView)
        view.addSubview(container)
        container.addSubview(stackView)
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            container.autoSetDimension(.height, toSize: modalHeight)
            container.autoPinEdge(toSuperviewEdge: .left)
            container.autoPinEdge(toSuperviewEdge: .right)
            
            let inset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
            stackView.autoPinEdgesToSuperviewEdges(with: inset, excludingEdge: .bottom)
        }
        bottomConstraint = container.bottomAnchor.constraint(equalTo: bottomAnchor)
        bottomConstraint?.isActive = true
        if #available(iOS 11.0, *) {
            let footer = UIView()
            footer.translatesAutoresizingMaskIntoConstraints = false
            footer.backgroundColor = UIColor.white
            view.addSubview(footer)
            footer.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets.zero, excludingEdge: .top)
            footer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        }
        
        let keyboard = Observable.of(KeyboardManager.willShow.asObservable(), KeyboardManager.willHide.asObservable()).merge()
        
        keyboard.takeUntil(rx.viewDidDisappear, restartWhen: rx.viewDidAppear).subscribe(onNext: { [weak self] in
            self?.transformButtonsView(info: $0)
        }).disposed(by: disposeBag)
        
        setupSubviews()
        
        emailText.rx.text.orEmpty
            .bind(to: signInViewModel.email)
            .disposed(by: disposeBag)
        passwordText.rx.text.orEmpty
            .bind(to: signInViewModel.password)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(passwordText.rx.text.orEmpty, emailText.rx.text.orEmpty) {!$0.isEmpty && !$1.isEmpty}
            .bind(to: signInButton.rx.isEnabled)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap
            .do(onNext: {[weak self] _ in self?.view?.endEditing(true) })
            .requireNetwork()
            .flatMapLatest(loginWithOwnCredential)
            .subscribe()
            .disposed(by: disposeBag)
        
        backButton.rx.tap
            .subscribe({ [weak self] _ in
                self?.dismissWithoutAction()
            })
            .disposed(by: disposeBag)
    }
    
    private func loginWithOwnCredential() -> Observable<AuthenticatedInfo> {
        // init default account
        let tempProfile = Profile(id: "Id", email: "abc@gmail.com",firstName: "first name", lastName: "last name",location: "ddd ", dateOfBirth: Date())
        let autInfo = AuthenticatedInfo(profile: tempProfile, mobileToken: "token")
        return signInViewModel.loginWithOwnCredential().map{ _ in autInfo }.trackingHUD().do(onNext: { [weak self] (info) in
                self?.dismiss(animated: true) {
                    SignInViewModel.sendAuthenticationNotification(info: info)
                }
            }, onError: { error in
                ToastManager.shared.presentAnimated(error: error)
        })
    }
    
    private func transformButtonsView(info: KeyboardManager.KeyboardTransitionInfo) {
        var bottom = UIScreen.main.bounds.height - info.frame.origin.y
        if #available(iOS 11.0, *), bottom > 0 {
            bottom -= view.safeAreaInsets.bottom
        }
        bottomConstraint?.constant = -bottom
        UIView.animate(withDuration: info.duration, delay: 0, options: info.options, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    //MARK: Properties

    var modalHeight: CGFloat {
        return 320
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    let disposeBag = DisposeBag()
    private lazy var overlayView: UIView = self.createOverlayView()
    private lazy var stackView: UIStackView = self.createStackView()
    private lazy var container: UIView = self.createContainerView()
    private var signInViewModel: SignInViewModel = SignInViewModel()
    private var emailText: SignUpTextField!
    private var passwordText: SignUpTextField!
    private var bottomConstraint: NSLayoutConstraint?
    private var signInButton: RoundCornerButton!
    private var backButton: UIButton!
}

extension SignInViewControler {
    private func createStackView() -> UIStackView {
        let stackView = UIStackView()
        stackView.spacing = 0
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }
    
    private func createOverlayView() -> UIView {
        let overlayView = UIView()
        overlayView.frame = view.frame
        overlayView.backgroundColor = UIColor.clear
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissWithoutAction))
        overlayView.addGestureRecognizer(tapGesture)
        return overlayView
    }
    
    private func createContainerView() -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        // tap buttons View to hide keyboard
        let tapButtonsViewGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        containerView.addGestureRecognizer(tapButtonsViewGesture)
        return containerView
    }
    
    @objc private func dismissWithoutAction() {
        dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
}

extension SignInViewControler {
    private func setupSubviews() {
        addHeader(text: NSLocalizedString("Sign In", comment: ""))
        emailText = addEmailText()
        addSpace(height: 8)
        passwordText = addTextField(placeHolder: NSLocalizedString("Password", comment: ""), isSecure: true)
        addSpace(height: 40)
        signInButton = addRoundedButton(text: NSLocalizedString("Sign in", comment: ""))
        backButton = addSecondaryButton(text: NSLocalizedString("Back", comment: ""))
    }
    
    func addEmailText() -> SignUpTextField {
        let emailText  = addTextField(placeHolder: NSLocalizedString("Email", comment: ""), isSecure: false)
        emailText.keyboardType = .emailAddress
        emailText.maxLength = Validation.emailMaxlength
        return emailText
    }
    
    func addSecondaryButton(text: String?) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont()
        button.setTitleColor(ColorPalette.lightGrayTextColor, for: .normal)
        stackView.addArrangedSubview(button)
        button.autoSetDimension(.height, toSize: 56)
        return button
    }
    
    func addRoundedButton(text: String?) -> RoundCornerButton {
        let button = RoundCornerButton(type: .system)
        button.setTitle(text, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont()
        stackView.addArrangedSubview(button)
        button.autoMatch(.width, to: .width, of: stackView, withOffset: -48)
        button.autoSetDimension(.height, toSize: 44)
        return button
    }
    
    func addTextField(placeHolder: String? = nil, isSecure: Bool = false) -> SignUpTextField {
        let textField = SignUpTextField()
        textField.placeholder = placeHolder
        if isSecure {
            textField.isSecureTextEntry = true
        }
        else {
            textField.font = UIFont.systemFont()
        }
        applySettings(textField: textField)
        stackView.addArrangedSubview(textField)
        textField.autoMatch(.width, to: .width, of: stackView, withOffset: -88)
        textField.autoSetDimension(.height, toSize: 44)
        return textField
    }
    
    private func applySettings(textField: UITextField) {
        textField.spellCheckingType = .no
        textField.returnKeyType = .done
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.autocorrectionType = .no
        textField.textAlignment = .center
        textField.textColor = ColorPalette.darkGrayTextColor
    }
    
    func addSpace(height: CGFloat) {
        guard height > 0 else { return }
        let view = UIView()
        addCustomView(view)
        view.autoSetDimension(.height, toSize: height)
        view.autoSetDimension(.width, toSize: 1)
    }
    
    func addCustomView(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    func addHeader(text: String? = nil) {
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.textColor = UIColor(patternImage: UIImage.gradientBackgroundImage())
        titleLabel.font = UIFont.boldSystemFont(ofSize: 19)
        titleLabel.text = text
        stackView.addArrangedSubview(titleLabel)
        titleLabel.autoMatch(.width, to: .width, of: stackView)
        titleLabel.autoSetDimension(.height, toSize: 44)
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension SignInViewControler: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        
        return PopupPresentationController(presentedViewController: presented, presenting: presenting)
    }
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        return PopupAnimatedTransitioning(isPresentation: true, bounce: false)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PopupAnimatedTransitioning(isPresentation: false, bounce: false)
    }
}

extension SignInViewControler: PopupViewControllerSpacing {
    var leftRightMargin: CGFloat {
        return 0
    }
    
    var topBottomMargin: CGFloat {
        return 0
    }
}
