//
//  SectionedViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import StackViewController
import RxSwift
import RxCocoa
import UIKit

//MARK: Constants

private let spacing: CGFloat = 8

//MARK: - SectionedViewController

class SectionedViewController: ViewController {
    struct SectionItemConfig {
        var cornerRadius: CGFloat = 3
        var backgroundColor: UIColor = UIColor.white
        var borderColor: UIColor? = nil
        var titleConfig: TitleConfig = TitleConfig()
    }
    
    struct TitleConfig {
        var color: UIColor? = ColorPalette.darkGrayTextColor
        var font: UIFont? = UIFont.boldSystemFont(ofSize: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if automaticallyAdjustsTopInset {
            automaticallyAdjustsScrollViewInsets = false
        }
        view.backgroundColor = ColorPalette.tableViewGroupedBackgroundColor
        createNewStackViewController()
    }
    
    private func createNewStackViewController() {
        if let oldStackViewController = stackViewController {
            oldStackViewController.willMove(toParentViewController: nil)
            oldStackViewController.view.removeFromSuperview()
            oldStackViewController.removeFromParentViewController()
        }
        
        stackViewController = StackViewController()
        addChildViewController(stackViewController)
        view.insertSubview(stackViewController.view, at: 0)
        stackViewController.didMove(toParentViewController: self)
        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.scrollView.delaysContentTouches = false
        stackViewController.stackView.spacing = spacing
        stackViewController.stackView.alignment = .center
        
        if automaticallyAdjustsTopInset {
            if #available(iOS 11.0, *) { }
            else {
                // 32 = 64 / 2, divided by 2 as stackViewController creates an additional top constraint with the same top inset as constant
                stackViewController.scrollView.contentInset.top = 32
                stackViewController.scrollView.scrollIndicatorInsets.top = 64
            }
        }
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackViewController.view.autoPinEdgesToSuperviewEdges()
        }
        
        let topSpaceView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: spacing))
        let bottomSpaceView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: spacing))
        stackViewController.addItem(topSpaceView)
        stackViewController.addItem(bottomSpaceView)
    }
    
    private(set) var stackViewController: StackViewController!
    
    var automaticallyAdjustsTopInset: Bool {
        return true
    }
}

extension SectionedViewController {
    func addSectionViewController(_ controller: UIViewController, config: SectionItemConfig = SectionItemConfig()) {
        let backgroundController = SectionBackgroundViewController(contentController: controller, config: config)
        stackViewController.insertItem(backgroundController, atIndex: stackViewController.items.count - 1)
        backgroundController.view.autoMatch(.width, to: .width, of: stackViewController.stackView, withOffset: -spacing * 2)
    }
    
    func add(view: UIView) {
        stackViewController.insertItem(view, atIndex: stackViewController.items.count - 1)
        view.autoMatch(.width, to: .width, of: stackViewController.stackView, withOffset: -spacing * 2)
    }
    
    func removeAllSectionViewControllers() {
        createNewStackViewController()
    }
}

//MARK: - SectionBackgroundViewController

protocol SectionedChildViewControllerProtocol: class {
    var titleInsets: UIEdgeInsets { get }
    var contentInsets: UIEdgeInsets { get }
    var loading: Driver<Bool>? { get }
    
    func createLoadingView() -> UIView
}

extension SectionedChildViewControllerProtocol {
    static var defaultInset: CGFloat {
        return 16
    }
    
    var titleInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: Self.defaultInset, right: 0)
    }
    
    var contentInsets: UIEdgeInsets {
        return UIEdgeInsets(top: Self.defaultInset, left: Self.defaultInset, bottom: Self.defaultInset, right: Self.defaultInset)
    }
    
    var loading: Driver<Bool>? {
        return nil
    }
    
    func createLoadingView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.white
        let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(activityIndicator)
        activityIndicator.autoCenterInSuperview()
        activityIndicator.startAnimating()
        return view
    }
}

private class SectionBackgroundViewController: ViewController {
    init(contentController: UIViewController, config: SectionedViewController.SectionItemConfig) {
        self.contentController = contentController
        self.config = config
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate override func loadView() {
        let view = BorderView()
        view.borderWidthUnit = .point
        view.borderWidth = 2
        view.layer.masksToBounds = true
        self.view = view
    }
    
    fileprivate override func viewDidLoad() {
        super.viewDidLoad()
        let insets = (contentController as? SectionedChildViewControllerProtocol)?.contentInsets ?? UIEdgeInsets.zero
        if let title = contentController.title {
            let labelContainer = UIView()
            labelContainer.addSubview(titleLabel)
            
            let stackView = UIStackView(arrangedSubviews: [labelContainer])
            stackView.axis = .vertical
            view.addSubview(stackView)
            
            addChildViewController(contentController)
            stackView.addArrangedSubview(contentController.view)
            contentController.didMove(toParentViewController: self)
            
            let titleInsets = (contentController as? SectionedChildViewControllerProtocol)?.titleInsets ?? UIEdgeInsets.zero
            NSLayoutConstraint.autoCreateAndInstallConstraints {
                stackView.autoPinEdgesToSuperviewEdges(with: insets)
                titleLabel.autoPinEdgesToSuperviewEdges(with: titleInsets)
            }
            
            titleLabel.attributedText = NSAttributedString(string: title, attributes: [.kern: 1])
            titleLabel.font = config.titleConfig.font
            titleLabel.textColor = config.titleConfig.color
        }
        else {
            addChildViewController(contentController)
            view.addSubview(contentController.view)
            contentController.didMove(toParentViewController: self)
            
            NSLayoutConstraint.autoCreateAndInstallConstraints {
                contentController.view.autoPinEdgesToSuperviewEdges(with: insets)
            }
        }
        
        view.backgroundColor = config.backgroundColor
        view.layer.cornerRadius = config.cornerRadius
        
        if let borderView = view as? BorderView {
            borderView.borderColor = config.borderColor
            borderView.borders = config.borderColor != nil ? .top : []
        }
        
        if let contentController = contentController as? SectionedChildViewControllerProtocol, let loading = contentController.loading {
            let loadingView = contentController.createLoadingView()
            view.addSubview(loadingView)
            loadingView.autoPinEdgesToSuperviewEdges()
            loading.map(!).drive(loadingView.rx.isHidden).disposed(by: disposeBag)
        }
        
        // bind hidden status of content controller to self
        contentController.view.rx.observe(Bool.self, "hidden")
            .ignoreNil()
            .bind(to: view.rx.isHidden)
            .disposed(by: disposeBag)
    }
    
    //MARK: Properties
    private lazy var titleLabel = UILabel()
    private let config: SectionedViewController.SectionItemConfig
    private let contentController: UIViewController
}
