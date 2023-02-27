//
//  ViewController.swift
//  wavy
//
//  Created by Luis Felipe Batista Pereira on 26/02/23.
//

import UIKit

class ViewController: UIViewController {
    let wave = WaveSegment()
    let target = Target()
    let sliderT:UISlider = {
       let slider = UISlider()
        slider.minimumValue = 0.5
        slider.maximumValue = 5
        slider.setValue(2, animated:  false)
        return slider
    }()
    
    let sliderLambda:UISlider = {
       let slider = UISlider()
        slider.minimumValue = 10
        slider.maximumValue = 200
        slider.setValue(50, animated:  false)
        return slider
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(wave)
        view.addSubview(target)
        view.addSubview(sliderT)
        view.addSubview(sliderLambda)
        sliderT.addTarget(self, action: #selector(periodChanged), for: .valueChanged)
        sliderLambda.addTarget(self, action: #selector(lambdaChanged), for: .valueChanged)
        setUpConstraints()
    }
    
    @objc func periodChanged() {
        let significativeValue = sliderT.value*10
        let roundedInt = Int(significativeValue)
        let newValue = Double(roundedInt)/10
        wave.T = newValue
    }
    
    @objc func lambdaChanged() {
        let newValue = Int(sliderLambda.value)
        wave.lamda = Double(newValue)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        wave.T = Double(sliderT.value)
        wave.animationStart()
        wave.backgroundColor = .systemPink
        target.backgroundColor = .green
        target.animationStart()
    }
    
    func setUpConstraints() {
        wave.translatesAutoresizingMaskIntoConstraints = false
        wave.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        wave.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        wave.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        wave.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        sliderT.translatesAutoresizingMaskIntoConstraints = false
        sliderT.heightAnchor.constraint(equalToConstant: 16).isActive = true
        sliderT.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -64).isActive = true
        sliderT.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        sliderT.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        
        sliderLambda.translatesAutoresizingMaskIntoConstraints = false
        sliderLambda.heightAnchor.constraint(equalToConstant: 32).isActive = true
        sliderLambda.bottomAnchor.constraint(equalTo: sliderT.topAnchor, constant: -8).isActive = true
        sliderLambda.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32).isActive = true
        sliderLambda.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32).isActive = true
        
        target.translatesAutoresizingMaskIntoConstraints = false
        target.widthAnchor.constraint(equalToConstant: 16).isActive = true
        target.heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
        target.leadingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        target.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
    }
    
}


class Target: UIView {
    var phase = 0.0
    var amplitude = 100.0
    var lamda = 300.0
    var T = 1.0
    var shape = CAShapeLayer()
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var currentTime: CFTimeInterval = 0
    
    override func draw(_ rect: CGRect) {
            drawRingFittingInsideView()
        }
        
        internal func drawRingFittingInsideView() -> () {
            let k = (2*Double.pi/lamda)
            let w = 2*Double.pi/T
            let expression = k*bounds.midX - w*Double(currentTime) + phase
            let y = bounds.midY - amplitude*cos(expression)
            let center = CGPoint(x: bounds.midX, y: y)
            let circlePath = UIBezierPath(
                    arcCenter: center,
                    radius: 8,
                    startAngle: CGFloat(0),
                    endAngle:2*Double.pi,
                    clockwise: true)
        
             let shapeLayer = CAShapeLayer()
            shapeLayer.path = circlePath.cgPath
                
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.strokeColor = UIColor.red.cgColor
            shapeLayer.lineWidth = 2
        
             layer.addSublayer(shapeLayer)
         }
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        self.displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
    }

    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        self.currentTime = (CACurrentMediaTime() - startTime)
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.setNeedsDisplay()
    }
    func animationStart() {
        self.startDisplayLink()
    }
}


class WaveSegment: UIView {
    var phase = 0.0
    var amplitude = 50.0
    var lamda = 300.0
    var T = 10.0
    var shape = CAShapeLayer()
    private weak var displayLink: CADisplayLink?
    private var startTime: CFTimeInterval = 0
    private var currentTime: CFTimeInterval = 0
    
    func drawWave() {
        let totalWidth = self.frame.width
        let totalHeight = self.frame.height
        let k = (2*Double.pi/lamda)
        let w = 2*Double.pi/T
        let midY = self.frame.midY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: midY))
        
        for x in stride(from: 1.0, to: totalWidth, by: 1.0) {
            let expression = k*x - w*Double(currentTime) + phase
            let y = midY - amplitude*cos(expression)
            path.addLine(to: CGPoint(x: x, y: y))
            path.move(to: CGPoint(x: x, y:  y))
        }
        
        path.close()
        shape.path = path.cgPath
        shape.strokeColor = UIColor.black.cgColor
        shape.fillColor = UIColor.clear.cgColor
        self.layer.addSublayer(shape)
    }
    
    private func startDisplayLink() {
        startTime = CACurrentMediaTime()
        self.displayLink?.invalidate()
        let displayLink = CADisplayLink(target: self, selector:#selector(handleDisplayLink(_:)))
        displayLink.add(to: .main, forMode: .common)
        self.displayLink = displayLink
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
    }

    @objc private func handleDisplayLink(_ displayLink: CADisplayLink) {
        self.currentTime = (CACurrentMediaTime() - startTime)
        self.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        self.drawWave()
    }
    func animationStart() {
        self.startDisplayLink()
    }
}

