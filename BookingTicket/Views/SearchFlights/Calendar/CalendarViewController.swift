//
//  CalendarViewController.swift
//  BookingTicket
//
//  Created by anhthu on 12/3/17.
//  Copyright © 2017 anhthu. All rights reserved.
//

import UIKit
import FSCalendar
import RxSwift
import RxCocoa

final class CalendarViewController: ViewController, CustomNavigationBarController {
    init() {
        super.init(nibName: nil, bundle: nil)
        title = NSLocalizedString("Choose Dates", comment: "")
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

    
    func setupNavigationBarButtons() {
        let saveButton = UIBarButtonItem(title: NSLocalizedString("Save", comment: ""), style: .done, target: nil, action: nil)
        navigationItem.rightBarButtonItem = saveButton
        
        let cancelButton = UIBarButtonItem(title: NSLocalizedString("Cancel", comment: ""), style: .plain, target: nil, action: nil)
        navigationItem.leftBarButtonItem = cancelButton
    }
    
    var tintColor: UIColor {
        return ColorPalette.mainColor
    }
    
    var navigationBarBackgroundColor: UIColor {
        return UIColor.white
    }
}


extension CalendarViewController {
    func setupUI() {
        view.backgroundColor = UIColor.white
        
        //main stack view contains all components
        let stackView = UIStackView()
        stackView.axis = .vertical
        view.addSubview(stackView)
        
        addSpaceToStackView(stackView, height: 12)
        
        //top 2 labels: Start Date and End Date
        let startDateLabel = createDateLabel()
        let endDateLabel = createDateLabel()
        
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
        
        
        let resetButton = createResetButton()
        let buttonBorder = BorderView()
        buttonBorder.borders = .top
        buttonBorder.borderColor = ColorPalette.tableViewSeparatorColor
        buttonBorder.addSubview(resetButton)
        stackView.addArrangedSubview(buttonBorder)
        
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        view.addSubview(spinner)
        
        NSLayoutConstraint.autoCreateAndInstallConstraints {
            stackView.autoPinEdge(toSuperviewEdge: .leading)
            stackView.autoPinEdge(toSuperviewEdge: .trailing)
            labelBorder.autoSetDimension(.width, toSize: 1)
            startDateLabel.autoMatch(.width, to: .width, of: endDateLabel)
            resetButton.autoPinEdgesToSuperviewEdges()
            resetButton.autoSetDimension(.height, toSize: 44)
            weekdayHeaderView.autoSetDimension(.height, toSize: 20)
            weekdayBorder.autoSetDimension(.height, toSize: 10)
            spinner.autoAlignAxis(toSuperviewAxis: .vertical)
        }
        stackView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: topAnchor, constant: 25).isActive = true
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

extension CalendarViewController: FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
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
        return calendar
    }
    
    private func bindCalendarView(_ calendar: CalendarView) {
        
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
