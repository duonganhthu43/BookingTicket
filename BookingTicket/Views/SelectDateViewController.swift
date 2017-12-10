//
//  SelectDateViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/10/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import FSCalendar

final class SelectDateViewController: ViewController, CustomNavigationBarController {
    init(viewModel: LeaveDatesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Select Dates", comment: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        setupNavigationBarButtons()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = tintColor
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !ReachabilityHelper.shared.isReachable {
            presentNoInternetConnectionError()
        }
    }
    
    //MARK: Properties
    private lazy var startDateLabel = createDateLabel()
    private lazy var endDateLabel = createDateLabel()
    let viewModel: LeaveDatesViewModel
    
    var tintColor: UIColor {
        return ColorPalette.mainColor
    }
    
    var navigationBarBackgroundColor: UIColor {
        return UIColor.white
    }
}

extension SelectDateViewController {
    func setupNavigationBarButtons() {
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: nil, action: nil)
        saveButton.rx.tap.withLatestFrom(viewModel.state).subscribe(onNext: { [weak self] state in
            _ = self?.navigationController?.popViewController(animated: true)
        }).disposed(by: disposeBag)
        viewModel.canSave.drive(saveButton.rx.isEnabled).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: nil, action: nil)
        cancelButton.rx.tap.withLatestFrom(viewModel.canReset).subscribe(onNext: { [weak self] canReset in
            guard let strongSelf = self else { return }
            if canReset {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                alertController.addAction(NSLocalizedString("Discard Changes", comment: ""), style: .destructive) {
                    _ = strongSelf.navigationController?.popViewController(animated: true)
                }
                alertController.addCancelAction()
                strongSelf.present(alertController, animated: true, completion: nil)
            }
            else {
                _ = strongSelf.navigationController?.popViewController(animated: true)
            }
        }).disposed(by: disposeBag)
        navigationItem.leftBarButtonItem = cancelButton
    }
}


extension SelectDateViewController {
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        //main stack view contains all components
        let stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        addSpaceToStackView(stackView, height: 12)
        
        //top 2 labels: Start Date and End Date
        let labelBorder = BorderView()
        labelBorder.borders = .left
        labelBorder.borderColor = ColorPalette.tableViewSeparatorColor
        let dateLabelStackView = UIStackView(arrangedSubviews: [startDateLabel, labelBorder, endDateLabel])
        dateLabelStackView.axis = .horizontal
        stackView.addArrangedSubview(dateLabelStackView)
        
        addSpaceToStackView(stackView)
        
        let weekdayHeaderView = FSCalendarWeekdayView()
        stackView.addArrangedSubview(weekdayHeaderView)
        
        let weekdayBorder = BorderView()
        weekdayBorder.borders = .bottom
        weekdayBorder.borderColor = tintColor
        stackView.addArrangedSubview(weekdayBorder)
        
        let calendarView = createCalendarView()
        stackView.addArrangedSubview(calendarView)
        
        weekdayHeaderView.calendar = calendarView
        
        let resetButton = createResetButton()
        let buttonBorder = BorderView()
        buttonBorder.borders = .top
        buttonBorder.borderColor = ColorPalette.tableViewSeparatorColor
        buttonBorder.addSubview(resetButton)
        stackView.addArrangedSubview(buttonBorder)
        
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdge(toSuperviewEdge: .leading)
            stackView.autoPinEdge(toSuperviewEdge: .trailing)
            labelBorder.autoSetDimension(.width, toSize: 1)
            startDateLabel.autoMatch(.width, to: .width, of: endDateLabel)
            resetButton.autoPinEdgesToSuperviewEdges()
            resetButton.autoSetDimension(.height, toSize: 44)
            weekdayHeaderView.autoSetDimension(.height, toSize: 20)
            weekdayBorder.autoSetDimension(.height, toSize: 10)
        }
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        
        viewModel.startDateString.drive(onNext: {[weak self] in
            self?.startDateLabel.attributedText = $0 }).disposed(by: disposeBag)
        viewModel.endDateString.drive(onNext: {[weak self] in
            self?.endDateLabel.attributedText = $0 }).disposed(by: disposeBag)
        viewModel.canReset.drive(resetButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.roundTrip.drive(onNext: { [weak self]  (isRoundTrip) in
                labelBorder.isHidden = !isRoundTrip
            self?.endDateLabel.isHidden = !isRoundTrip
            if !isRoundTrip {
                self?.viewModel.dispatch(action: LeaveDatesViewModel.Action.removeEndDate)
            }
        }).disposed(by: disposeBag)
        
    }
    
    private func addSpaceToStackView(_ stackView: UIStackView, height: CGFloat = 15) {
        let spaceView = UIView(frame: CGRect(x: 0, y: 0, width: height, height: height))
        stackView.addArrangedSubview(spaceView)
        spaceView.autoSetDimension(.height, toSize: height)
    }
    
    private func createDateLabel() -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont()
        label.textColor = tintColor
        label.autoSetDimension(.height, toSize: 87)
        return label
    }
    
    private func createResetButton() -> UIButton {
        let button = UIButton(type: .system)
        button.tintColor = tintColor
        button.setTitle(NSLocalizedString("Reset", comment: ""), for: .normal)
        return button
    }
}


extension SelectDateViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    func createCalendarView() -> CalendarView {
        let calendar = CalendarView(frame: view.bounds)
        calendar.rx.setDataSource(self).disposed(by: disposeBag)
        calendar.pagingEnabled = false
        calendar.allowsMultipleSelection = true
        calendar.placeholderType = .none
        calendar.headerHeight = 34
        calendar.weekdayHeight = 0
        calendar.lineHeightMultiplier = 1.4
        calendar.today = nil
        calendar.appearance.weekdayTextColor = tintColor
        
        if let topBorder = calendar.value(forKey: "topBorder") as? UIView {
            topBorder.removeFromSuperview()
        }
        if let bottomBorder = calendar.value(forKey: "bottomBorder") as? UIView {
            bottomBorder.removeFromSuperview()
        }
        
        bindCalendarView(calendar)
        
        if let date = viewModel.originalStartDate {
            calendar.scroll(to: date)
        }
        return calendar
    }
    
    private func bindCalendarView(_ calendar: CalendarView) {
        calendar.rx.dateSelected
            .filter { !$0.isDatePast }.flatMap { date in
                 Observable.just(LeaveDatesViewModel.Action.selectDate(date))
            }.subscribe(onNext: { [weak self] in
                self?.viewModel.dispatch(action: $0)
            }).disposed(by: disposeBag)
        
        viewModel.selections.drive(calendar.rx.selections).disposed(by: disposeBag)
    }
    
    private func handleOverlap(kind: LeaveDatesViewModel.OverlapKind, for date: Date) -> Observable<Bool> {
        switch kind {
        case .none:
            return Observable.just(true)
            
        case let .current(startedToday):
            let format = NSLocalizedString("%@ is scheduled for **%@**. Change it's end date to %@?", comment: "")
            let newEndDate = startedToday && date.isToday ? date : date - 1.days
            let content = String(format: format, date.mediumDateWithoutYearString, "beautiful ", newEndDate.mediumDateWithoutYearString)
            let config = NSAttributedString.FormatConfiguration(boldColor: ColorPalette.mainColor)
            let message = NSAttributedString.fromFormat(content, configuration: config)
            return alert(message: message, buttonTitle: NSLocalizedString("Change", comment: ""))
            
        case .future:
            let format = NSLocalizedString("You've selected a date scheduled for **%@**, would you like to remove your future leave?", comment: "")
            let content = String(format: format,"beautiful")
            let config = NSAttributedString.FormatConfiguration(boldColor: ColorPalette.mainColor)
            let message = NSAttributedString.fromFormat(content, configuration: config)
            return alert(message: message, buttonTitle: NSLocalizedString("Remove", comment: ""))
            
        }
    }
    
    private func alert(message: NSAttributedString, buttonTitle: String) -> Observable<Bool> {
        return Reactive<AlertPopupViewController>.present(parent: self) {
            $0.attributedMessage = message
            $0.mainButtonTitle = buttonTitle
            }
            .filter { $0 }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let cal = Calendar.current
        let com = cal.dateComponents([.year, .month], from: Date())
        return cal.date(from: com)!
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date() + 100.years
    }
}
