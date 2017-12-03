//
//  OnboardingViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/1/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import PureLayout

final class OnboardingViewController : ViewController {
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnSignIn.rx.tap.subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.present(SignInViewControler(), animated: true, completion: nil)
        }).disposed(by: disposeBag)
        
        
        
        let backGroundView = UIImageView()
        backGroundView.image = UIImage.gradientBackgroundImage()
        
        
        
        
        view.addSubview(backGroundView)
        view.addSubview(iconImageView)
        view.addSubview(pageControl)
        view.addSubview(scrollView)
        view.addSubview(borderView)

        //create content view
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.backgroundColor = UIColor.clear
        
        //create first page
        let title = NSLocalizedString("Book Everyday", comment: "")
        let description = NSLocalizedString("Compare And Save On A Wide Choice Of Cheap Flights Online Everyday", comment: "")
        let fistPage = createPage(title, description: description)
        contentView.addSubview(fistPage)
        
        //create second page
        let secondTitle = NSLocalizedString("Get Inspired", comment: "")
        let secondDescription = NSLocalizedString("Fresh Inspriration to get you going", comment: "")
        let secondPage = createPage(secondTitle, description: secondDescription)
        contentView.addSubview(secondPage)
        
        //create third page
        let thirdTitle = NSLocalizedString("Discover Journey", comment: "")
        let thirdDescription = NSLocalizedString("Follow people and be part of their life journey", comment: "")
        let thirdPage = createPage(thirdTitle, description: thirdDescription)
        contentView.addSubview(thirdPage)
        let pages: NSArray = [fistPage, secondPage, thirdPage]
        borderView.addSubview(btnDiscover)
        borderView.addSubview(btnSignIn)
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            backGroundView.autoPinEdgesToSuperviewEdges()
            
            iconImageView.autoAlignAxis(toSuperviewAxis: .vertical)
            iconImageView.autoPinEdge(toSuperviewEdge: .top, withInset: 50)
            iconImageView.autoSetDimensions(to: CGSize(width: 90, height: 83))
            
            scrollView.autoPinEdge(.top, to: .bottom, of: iconImageView, withOffset: 50 )
            scrollView.autoPinEdge(toSuperviewEdge: .leading)
            scrollView.autoPinEdge(toSuperviewEdge: .trailing)
            scrollView.autoPinEdge(.bottom, to: .top, of: pageControl)
            
            pageControl.autoPinEdge(.bottom, to: .top, of: borderView, withOffset: -50)
            pageControl.autoAlignAxis(toSuperviewAxis: .vertical)
            
            borderView.autoPinEdge(toSuperviewEdge: .bottom)
            borderView.autoPinEdge(toSuperviewEdge: .leading)
            borderView.autoPinEdge(toSuperviewEdge: .trailing)
            borderView.autoSetDimension(.height, toSize: 50)
            
            btnDiscover.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0,left: 20,bottom: 0,right: 0), excludingEdge: .trailing)
            
            btnSignIn.autoPinEdgesToSuperviewEdges(with: UIEdgeInsets(top: 0,left: 0,bottom: 0,right: 20), excludingEdge: .leading)
            
            contentView.autoPinEdgesToSuperviewEdges()
            fistPage.autoPinEdge(toSuperviewEdge: .top)
            fistPage.autoPinEdge(toSuperviewEdge: .leading)
            fistPage.autoMatch(.width, to: .width, of: self.scrollView)
            fistPage.autoMatch(.height, to: .height, of: self.scrollView)
            
            pages.autoDistributeViews(along: .horizontal, alignedTo: .top, withFixedSpacing: 0)
            pages.autoMatchViewsDimension(.height)
            
            contentView.autoPinEdge(.trailing, to: .trailing, of: thirdPage)
            contentView.autoPinEdge(.bottom, to: .bottom, of: thirdPage)
            
        }
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    //MARK Properties
    private lazy var userName: SignUpTextField = createTextInput(placeHolder: "Username or Email")
    private lazy var passWord: SignUpTextField = createTextInput(placeHolder: "Password")
    private lazy var titleUsr: UILabel = createTitleLabel()
    private lazy var titlePsw: UILabel = createTitleLabel()
    private lazy var btnSignIn: UIButton = createSignIn()
    private lazy var btnDiscover: UIButton = createDiscover()
    private lazy var iconImageView: UIImageView = createLogoImage()
    private lazy var mainTitle: UILabel = createMainTitle()
    private lazy var pageControl: UIPageControl = createPageControl()
    private lazy var scrollView: UIScrollView = createScrollView()
    private lazy var borderView: BorderView = createBorderView()
    
    private var currentPage: Int {
        let width = scrollView.bounds.width
        return Int((scrollView.contentOffset.x + 0.5 * width) / width)
    }
}

extension OnboardingViewController {
    
    private func createPageControl() -> UIPageControl {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = UIColor.white.withAlphaComponent(0.5)
        pageControl.currentPageIndicatorTintColor = UIColor.white
        pageControl.numberOfPages = 3
        return pageControl
    }
    
    private func createScrollView() -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
        scrollView.isScrollEnabled = true
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        return scrollView
    }
    
    private func createBorderView() -> BorderView {
        let borderView = BorderView()
        borderView.borderColor = ColorPalette.backGroundColor_Pink
        borderView.backgroundColor = UIColor.white
        return borderView
    }
    
    private func createPage(_ title: String, description: String) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        let innerContainer = UIView()
        view.addSubview(innerContainer)
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = title
        titleLabel.font = UIFont.boldSystemFont(ofSize: 32)
        titleLabel.textColor = UIColor.white
        innerContainer.addSubview(titleLabel)
        
        let descLabel = UILabel()
        descLabel.numberOfLines = 0
        descLabel.textAlignment = .center
        descLabel.font = UIFont.systemFont(ofSize: 20)
        descLabel.textColor = UIColor.white
        descLabel.attributedText = description.adjustedLineHeight(alignment: .center)
        innerContainer.addSubview(descLabel)
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            titleLabel.autoPinEdge(toSuperviewEdge: .top)
            titleLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            descLabel.autoPinEdge(.top, to: .bottom, of: titleLabel, withOffset: 10)
            descLabel.autoAlignAxis(toSuperviewAxis: .vertical)
            descLabel.autoPinEdge(toSuperviewEdge: .leading, withInset: 40)
            descLabel.autoPinEdge(toSuperviewEdge: .trailing, withInset: 40)
            innerContainer.autoAlignAxis(toSuperviewAxis: .vertical)
            innerContainer.autoPinEdge(toSuperviewEdge: .top, withInset: 20)
            innerContainer.autoMatch(.width, to: .width, of: view)
        }
        return view
    }
    
    private func createMainTitle() -> UILabel {
        let title = UILabel()
        title.font = UIFont.bigBoldSystemFont()
        title.backgroundColor = UIColor.black
        title.text = "Booking Flight"
        return title
    }
    private func createTitleLabel() -> UILabel {
        let label = UILabel()
        label.textColor = ColorPalette.mainColor
        label.autoSetDimension(.height, toSize: 44)
        return label
    }
    
    private func createTextInput(placeHolder: String? = nil) -> SignUpTextField {
        let textInput = SignUpTextField()
        textInput.autoSetDimension(.height, toSize: 44)
        textInput.spellCheckingType = .no
        textInput.returnKeyType = .done
        textInput.autocapitalizationType = .none
        textInput.spellCheckingType = .no
        textInput.autocorrectionType = .no
        textInput.textAlignment = .center
        textInput.textColor = ColorPalette.darkGrayTextColor
        textInput.placeholder = placeHolder
        textInput.font = UIFont.systemFont()
        return textInput
    }
    
    private func createSignIn() -> UIButton {
        let button = createButton()
        button.setTitle("Sign In", for: .normal)
        return button
    }
    
    private func createDiscover() -> UIButton {
        let button = createButton()
        button.setTitle("Discover", for: .normal)
        return button
    }
    
    private func createButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = UIColor(white: 0.9, alpha: 1)
        button.setTitleColor(UIColor(patternImage: UIImage.gradientBackgroundImage()), for: .normal)
        button.autoSetDimension(.height, toSize: 44)
        button.titleLabel?.font = UIFont.systemFont().bold()
        return button
    }
    
    private func createGrouped(title: UILabel, control: UIView) -> UIView {
        let grouped = UIStackView()
        grouped.axis = .horizontal
        grouped.spacing = 20
        grouped.addArrangedSubview(title)
        grouped.addArrangedSubview(control)
        return grouped
    }
    
    private func createLogoImage() -> UIImageView {
        let imageView = UIImageView()
        imageView.image = Image.mainIcon.image
        return imageView
    }
}
//MARK: - Scroll view delegate

extension OnboardingViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updatePage(currentPage, prevPage: pageControl.currentPage)
    }
    private func updatePage(_ currentPage: Int, prevPage: Int) {
        guard prevPage != currentPage else { return }
        pageControl.currentPage = currentPage
    }
}
