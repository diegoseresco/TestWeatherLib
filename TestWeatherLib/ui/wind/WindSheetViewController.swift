//
//  WeatherTodaySheetViewController.swift
//  garrigues
//
//  Created by Diego Salcedo on 10/09/22.
//  Copyright © 2022 Seresco. All rights reserved.
//

import UIKit
import CoreLocation

public class WindSheetViewController: UIViewController {
    
    // MARK: - UI Components
    let clearView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let containerView: UIView = {
        let view = UIView()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {
            view.backgroundColor = .white
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bottomSheetDecoration: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2.5
        view.backgroundColor = UIColor.bottomSheetDecorationColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let segmentedControls: UISegmentedControl = {
        let segmentedControls = UISegmentedControl()
        if #available(iOS 13.0, *) {
            segmentedControls.selectedSegmentTintColor = .mainColor
        }
        segmentedControls.isSelected = true
        segmentedControls.selectedSegmentIndex = 0
        let font = UIFont.systemFont(ofSize: 18)
        segmentedControls.setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        segmentedControls.insertSegment(withTitle: TimePeriod.atSix.range, at: 0, animated: true)
        segmentedControls.insertSegment(withTitle: TimePeriod.atTwelve.range, at: 1, animated: true)
        segmentedControls.insertSegment(withTitle: TimePeriod.atEighteen.range, at: 2, animated: true)
        segmentedControls.insertSegment(withTitle: TimePeriod.atTwentyFour.range, at: 3, animated: true)
        segmentedControls.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControls
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(24)
        label.text = "Municipality"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "Province"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let circularView: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 115
        view.layer.borderWidth = 1
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let arrowImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "ic_arrow")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    let windDirectionLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(18)
        label.text = "Dirección:"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let kmPerHourLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "km/h"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let kmInfoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 4
        stackView.axis = .vertical
        return stackView
    }()
    let activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        return activityIndicator
    }()
    let northLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "N"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let southLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "S"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let eastLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "E"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let westLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(20)
        label.text = "O"
        label.textAlignment = .center
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Class Properties
    private var windPrediction: [Wind]?
    var municipalityId = ""
    
    let locationDelegate = LocationDelegate()
    var latestLocation: CLLocation? = nil
    var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
    var yourLocation: CLLocation {
      get { return UserDefaults.standard.currentLocation }
      set { UserDefaults.standard.currentLocation = newValue }
    }
    
    let locationManager: CLLocationManager = {
        $0.requestWhenInUseAuthorization()
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.startUpdatingLocation()
        $0.startUpdatingHeading()
        return $0
    }(CLLocationManager())
    
    private func orientationAdjustment() -> CGFloat {
        let isFaceDown: Bool = {
            switch UIDevice.current.orientation {
            case .faceDown: return true
            default: return false
            }
        }()
        
        let adjAngle: CGFloat = {
            switch UIApplication.shared.statusBarOrientation {
            case .landscapeLeft:  return 90
            case .landscapeRight: return -90
            case .portrait, .unknown: return 0
            case .portraitUpsideDown: return isFaceDown ? 180 : -180
            }
        }()
        return adjAngle
    }

    // MARK: - View Life Cycle
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.layer.cornerRadius = 13
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupConstraints()
        setupInteractions()
        setupData()
        setupCompass()
    }
    
    func setupCompass() {
        locationManager.delegate = locationDelegate
        
        locationDelegate.locationCallback = { location in
            self.latestLocation = location
        }
        
        locationDelegate.headingCallback = { newHeading in
            
            func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
                let heading: CGFloat = {
                    let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
                    switch UIDevice.current.orientation {
                    case .faceDown: return -originalHeading
                    default: return originalHeading
                    }
                }()
                
                return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
            }
            
            UIView.animate(withDuration: 0.5) {
                let angle = computeNewAngle(with: CGFloat(newHeading))
                self.arrowImage.transform = CGAffineTransform(rotationAngle: angle)
            }
        }
    }
    
    func setupData() {
        self.showLoading()
        MeteorologyApi.getWeatherPredictionsKey(municipalityId: municipalityId) { result in
            self.hideLoading()
            self.titleLabel.text = result.name
            self.subtitleLabel.text = result.province
            self.windPrediction = result.prediction.days[1].wind.filter { $0.period == TimePeriod.atSix.range || $0.period == TimePeriod.atTwelve.range || $0.period == TimePeriod.atEighteen.range || $0.period == TimePeriod.atTwentyFour.range }
            self.segmentedControls.selectedSegmentIndex = 0
            self.setupView(timePeriod: .atSix)
        }
    }
    
    func setupInteractions() {
        segmentedControls.addTarget(self, action: #selector(changeDay), for: .valueChanged)
        clearView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissView)))
    }
    
    func setupView(timePeriod: TimePeriod) {
        if let windPrediction = windPrediction?[timePeriod.index] {
            kmPerHourLabel.text = "\(windPrediction.velocity) km/h"
            windDirectionLabel.text = "Dirección: \(windPrediction.directionName)"
        }
    }
    

    func setupLayout() {
        view.addSubview(clearView)
        view.addSubview(containerView)
        
        containerView.addSubview(bottomSheetDecoration)
        containerView.addSubview(segmentedControls)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(circularView)
        containerView.addSubview(activityIndicator)
        containerView.addSubview(northLabel)
        containerView.addSubview(southLabel)
        containerView.addSubview(eastLabel)
        containerView.addSubview(westLabel)
        containerView.addSubview(kmInfoStackView)
        
        circularView.addSubview(arrowImage)
        
        kmInfoStackView.addArrangedSubview(kmPerHourLabel)
        kmInfoStackView.addArrangedSubview(windDirectionLabel)
        
    }
    
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            clearView.topAnchor.constraint(equalTo: view.topAnchor),
            clearView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            clearView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            clearView.bottomAnchor.constraint(equalTo: containerView.topAnchor),
            
            containerView.topAnchor.constraint(greaterThanOrEqualTo: view.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            
            northLabel.topAnchor.constraint(equalTo: circularView.topAnchor, constant: -10),
            northLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            northLabel.heightAnchor.constraint(equalToConstant: 20),
            northLabel.widthAnchor.constraint(equalToConstant: 30),
            
            southLabel.bottomAnchor.constraint(equalTo: circularView.bottomAnchor, constant: 10),
            southLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            southLabel.heightAnchor.constraint(equalToConstant: 20),
            southLabel.widthAnchor.constraint(equalToConstant: 30),
            
            eastLabel.leadingAnchor.constraint(equalTo: circularView.leadingAnchor, constant: -10),
            eastLabel.centerYAnchor.constraint(equalTo: circularView.centerYAnchor),
            eastLabel.heightAnchor.constraint(equalToConstant: 30),
            eastLabel.widthAnchor.constraint(equalToConstant: 20),
            
            westLabel.trailingAnchor.constraint(equalTo: circularView.trailingAnchor, constant: 10),
            westLabel.centerYAnchor.constraint(equalTo: circularView.centerYAnchor),
            westLabel.heightAnchor.constraint(equalToConstant: 30),
            westLabel.widthAnchor.constraint(equalToConstant: 20),
            
            bottomSheetDecoration.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 6),
            bottomSheetDecoration.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            bottomSheetDecoration.widthAnchor.constraint(equalToConstant: 38),
            bottomSheetDecoration.heightAnchor.constraint(equalToConstant: 5),
            
            segmentedControls.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 30),
            segmentedControls.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: segmentedControls.bottomAnchor, constant: 14),
            titleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
            subtitleLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            circularView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            circularView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            circularView.heightAnchor.constraint(equalToConstant: 230),
            circularView.widthAnchor.constraint(equalToConstant: 230),
            
            arrowImage.heightAnchor.constraint(equalToConstant: 70),
            arrowImage.widthAnchor.constraint(equalToConstant: 70),
            arrowImage.centerXAnchor.constraint(equalTo: circularView.centerXAnchor),
            arrowImage.centerYAnchor.constraint(equalTo: circularView.centerYAnchor),
            
            kmInfoStackView.topAnchor.constraint(equalTo: circularView.bottomAnchor, constant: 20),
            kmInfoStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            kmInfoStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -30),
        ])
    }
    
    func showLoading() {
        self.kmInfoStackView.isHidden = true
        self.northLabel.isHidden = true
        self.southLabel.isHidden = true
        self.eastLabel.isHidden = true
        self.westLabel.isHidden = true
        self.segmentedControls.isHidden = true
        self.titleLabel.isHidden = true
        self.subtitleLabel.isHidden = true
        self.circularView.isHidden = true
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        self.kmInfoStackView.isHidden = false
        self.northLabel.isHidden = false
        self.southLabel.isHidden = false
        self.eastLabel.isHidden = false
        self.westLabel.isHidden = false
        self.segmentedControls.isHidden = false
        self.titleLabel.isHidden = false
        self.subtitleLabel.isHidden = false
        self.circularView.isHidden = false
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
    }
    
    // MARK: - Interaction Handling
    @objc func dismissView() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func changeDay(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            setupView(timePeriod: .atSix)
        case 1:
            setupView(timePeriod: .atTwelve)
        case 2:
            setupView(timePeriod: .atEighteen)
        case 3:
            setupView(timePeriod: .atTwentyFour)
        default:
            setupView(timePeriod: .atSix)
        }
    }
    
}

public enum WindDirection {
    case O, E, S, N, SE, SO, NE, NO, C
    
    var name: String {
        switch self {
        case .O:
            return "O"
        case .E:
            return "E"
        case .S:
            return "S"
        case .N:
            return "N"
        case .SE:
            return "SE"
        case .SO:
            return "SO"
        case .NE:
            return "NE"
        case .NO:
            return "NO"
        case .C:
            return "C"
        }
    }
}

public enum TimePeriod {
    case atSix
    case atTwelve
    case atEighteen
    case atTwentyFour
    
    var index: Int {
        switch self {
        case .atSix:
            return 0
        case .atTwelve:
            return 1
        case .atEighteen:
            return 2
        case .atTwentyFour:
            return 3
        }
    }
    
    var range: String {
        switch self {
        case .atSix:
            return "00-06"
        case .atTwelve:
            return "06-12"
        case .atEighteen:
            return "12-18"
        case .atTwentyFour:
            return "18-24"
        }
    }
}


class LocationDelegate: NSObject, CLLocationManagerDelegate {
    var locationCallback: ((CLLocation) -> ())? = nil
    var headingCallback: ((CLLocationDirection) -> ())? = nil
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        locationCallback?(currentLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        headingCallback?(newHeading.trueHeading)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("⚠️ Error while updating location " + error.localizedDescription)
    }
}
