//
//  RadioButton.swift
//  BringozTestTask
//
//  Created by Vadim Shikulo on 4/26/18.
//  Copyright © 2018 Bringoz. All rights reserved.
//

import UIKit
import RxSwift

// To extend tappable area of RadioButton use RadioButtonContainer
open class RadioButton: View {
  
  // MARK: Views
  open let outerCircle: UIView = {
    let view = UIView()
    view.backgroundColor = .clear
    view.clipsToBounds = false
    view.layer.contentsScale = UIScreen.main.scale
    view.layer.rasterizationScale = UIScreen.main.scale
    view.layer.shouldRasterize = true
    return view
  }()
  
  open let innerCircle: UIView = {
    let view = UIView()
    view.clipsToBounds = false
    view.layer.contentsScale = UIScreen.main.scale
    view.layer.rasterizationScale = UIScreen.main.scale
    view.layer.shouldRasterize = true
    return view
  }()
  
  // MARK: - Properties
  open var outerCircleDiameter: CGFloat = 25.0 { didSet { updateView() } }
  open var outerCircleBorderWidth: CGFloat = 2.0 { didSet { updateView() } }
  
  private var outerCircleSize: CGSize {
    let outerCircleSide = outerCircleDiameter
    return CGSize(width: outerCircleSide, height: outerCircleSide)
  }
  
  private var outerCircleCornerRadius: CGFloat {
    return outerCircleDiameter / 2
  }
  
  // MARK: -
  open var innerOuterCirclesGap: CGFloat = 3.0 { didSet { updateView() } }
  
  private var innerCircleSize: CGSize {
    let innerCircleSide = outerCircleDiameter - (outerCircleBorderWidth + innerOuterCirclesGap) * 2
    return CGSize(width: innerCircleSide, height: innerCircleSide)
  }
  
  private var innerCircleCornerRadius: CGFloat {
    return outerCircleDiameter / 2 - outerCircleBorderWidth - innerOuterCirclesGap
  }
  
  // MARK: - 
  open var userDeselectionEnabled = false
  
  open var animated = true
  
  open fileprivate(set) var isSelected = false {
    didSet {
      if isSelected != oldValue {
        changeState(selected: isSelected)
      }
    }
  }
  
  open var selectedColor = UIColor.bringozOrange { didSet { updateColor(selected: isSelected) } }
  open var deselectedColor = UIColor.unselectedGray { didSet { updateColor(selected: isSelected) } }
  
  fileprivate lazy var tapGesture: UITapGestureRecognizer = {
    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction))
    tapGesture.numberOfTapsRequired = 1
    tapGesture.numberOfTouchesRequired = 1
    return tapGesture
  }()
  
  override open var intrinsicContentSize: CGSize {
    return outerCircleSize
  }
  
  // MARK: -
  private let stateChangedPublishSubject = PublishSubject<Bool>()
  public var stateChanged: Observable<Bool> {
    return stateChangedPublishSubject.asObservable().distinctUntilChanged()
  }
  public var onSelected: Observable<Void> {
    return stateChanged
      .filter { $0 == true }
      .map { _ in }
  }
  public var onDeselected: Observable<Void> {
    return stateChanged
      .filter { $0 == false }
      .map { _ in }
  }
  
  // MARK: - View lifecycle
  override open func customInit() {
    super.customInit()
    clipsToBounds = false
    
    addGestureRecognizer(tapGesture)
    
    layer.contentsScale = UIScreen.main.scale
    
    addSubview(innerCircle)
    addSubview(outerCircle)
  }
  
  override open func layoutSubviews() {
    super.layoutSubviews()
    updateColor(selected: isSelected)
    
    let rect = bounds
    
    outerCircle.center = CGPoint(x: outerCircleDiameter / 2, y: rect.midY)
    outerCircle.bounds.size = outerCircleSize
    outerCircle.layer.cornerRadius = outerCircleCornerRadius
    outerCircle.layer.borderWidth = outerCircleBorderWidth
    
    innerCircle.center = outerCircle.center
    innerCircle.bounds.size = isSelected ? innerCircleSize : .zero
    innerCircle.layer.cornerRadius = innerCircleCornerRadius
  }
  
  // MARK: - Public methods
  open func updateView() {
    invalidateIntrinsicContentSize()
    setNeedsLayout()
  }
  
  open func select(animated: Bool) {
    guard !isSelected else { return }
    let savedAnimated = self.animated
    self.animated = animated
    isSelected = true
    self.animated = savedAnimated
  }
  
  open func deselect(animated: Bool) {
    guard isSelected else { return }
    let savedAnimated = self.animated
    self.animated = animated
    isSelected = false
    self.animated = savedAnimated
  }
  
  // MARK: - Private methods
  private func updateColor(selected isSelected: Bool) {
    outerCircle.layer.borderColor = isSelected ? selectedColor.cgColor : deselectedColor.cgColor
    innerCircle.backgroundColor = isSelected ? selectedColor : deselectedColor
  }
  
  @objc fileprivate func tapGestureAction() {
    if userDeselectionEnabled {
      return isSelected = !isSelected
    }
    
    if !isSelected {
      isSelected = true
    }
  }
  
  private func changeState(selected isSelected: Bool) {
    updateColor(selected: isSelected)
    innerCircle.bounds.size = isSelected ? innerCircleSize : .zero
    
    stateChangedPublishSubject.onNext(isSelected)
    
    guard animated else { return }
    
    innerCircle.layer.removeAllAnimations()
    innerCircle.layer.add(animationGroupForInnerCircle(selected: isSelected), forKey: "animations")
  }
  
  // MARK: - Animations
  private func animationGroupForInnerCircle(selected: Bool) -> CAAnimationGroup {
    return selected ? innerCircleShowAnimationGroup() : innerCircleHideAnimationGroup()
  }
  
  private func innerCircleHideAnimationGroup() -> CAAnimationGroup {
    let group = CAAnimationGroup()
    
    let sizeAnimation = CABasicAnimation(keyPath: "bounds")
    sizeAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: innerCircleSize.width, height: innerCircleSize.height))
    sizeAnimation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
    cornerRadiusAnimation.fromValue = innerCircleSize.height / 2
    cornerRadiusAnimation.toValue = 0
    
    group.animations = [sizeAnimation, cornerRadiusAnimation]
    group.duration = 0.15
    group.isRemovedOnCompletion = true
    group.repeatCount = 1
    
    return group
  }
  
  private func innerCircleShowAnimationGroup() -> CAAnimationGroup {
    let group = CAAnimationGroup()
    
    let sizeAnimation = CABasicAnimation(keyPath: "bounds")
    sizeAnimation.fromValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: 0, height: 0))
    sizeAnimation.toValue = NSValue(cgRect: CGRect(x: 0, y: 0, width: innerCircleSize.width, height: innerCircleSize.height))
    
    let cornerRadiusAnimation = CABasicAnimation(keyPath: "cornerRadius")
    cornerRadiusAnimation.fromValue = 0
    cornerRadiusAnimation.toValue = innerCircleSize.height / 2
    
    group.animations = [sizeAnimation, cornerRadiusAnimation]
    group.duration = 0.15
    group.isRemovedOnCompletion = true
    group.repeatCount = 1
    
    return group
  }
}

