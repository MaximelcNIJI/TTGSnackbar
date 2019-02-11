//
//  TTGSnackbar.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit
import Darwin

// MARK: - Enum

/**
 Snackbar display duration types.

 - short:   1 second
 - middle:  3 seconds
 - long:    5 seconds
 - forever: Not dismiss automatically. Must be dismissed manually.
 */

@objc public enum TTGSnackbarDuration: Int {
  case short = 1
  case middle = 3
  case long = 5
  case forever = 2147483647 // Must dismiss manually.
}

/**
 Snackbar animation types.

 - fadeInFadeOut:               Fade in to show and fade out to dismiss.
 - slideFromBottomToTop:        Slide from the bottom of screen to show and slide up to dismiss.
 - slideFromBottomBackToBottom: Slide from the bottom of screen to show and slide back to bottom to dismiss.
 - slideFromLeftToRight:        Slide from the left to show and slide to rigth to dismiss.
 - slideFromRightToLeft:        Slide from the right to show and slide to left to dismiss.
 - slideFromTopToBottom:        Slide from the top of screen to show and slide down to dismiss.
 - slideFromTopBackToTop:       Slide from the top of screen to show and slide back to top to dismiss.
 */

@objc public enum TTGSnackbarAnimationType: Int {
  case fadeInFadeOut
  case slideFromBottomToTop
  case slideFromBottomBackToBottom
  case slideFromLeftToRight
  case slideFromRightToLeft
  case slideFromTopToBottom
  case slideFromTopBackToTop
}

open class TTGSnackbar: UIView {
  // MARK: - Class property.

  private static let defaultFont: UIFont = UIFont.boldSystemFont(ofSize: 14.0)

  /// Snackbar default frame
  private static let snackbarDefaultFrame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 44)

  /// Snackbar min height
  private static let snackbarMinHeight: CGFloat = 44.0

  /// Snackbar icon imageView default width
  private static let snackbarIconImageViewWidth: CGFloat = 32.0

  // MARK: - Typealias.

  /// Action callback closure definition.
  public typealias TTGActionBlock = (_ snackbar:TTGSnackbar) -> Void

  /// Dismiss callback closure definition.
  public typealias TTGDismissBlock = (_ snackbar:TTGSnackbar) -> Void

  /// Swipe gesture callback closure
  public typealias TTGSwipeBlock = (_ snackbar: TTGSnackbar, _ direction: UISwipeGestureRecognizer.Direction) -> Void

  // MARK: - Public property.

  /// Tap callback
  @objc open dynamic var onTapBlock: TTGActionBlock?

  /// Swipe callback
  @objc open dynamic var onSwipeBlock: TTGSwipeBlock?

  /// A property to make the snackbar auto dismiss on Swipe Gesture
  @objc open dynamic var shouldDismissOnSwipe: Bool = false

  /// a property to enable left and right margin when using customContentView
  @objc open dynamic var shouldActivateLeftAndRightMarginOnCustomContentView: Bool = false

  /// Action callback.
  @objc open dynamic var actionBlock: TTGActionBlock? = nil

  /// Second action block
  @objc open dynamic var secondActionBlock: TTGActionBlock? = nil

  /// Dismiss callback.
  @objc open dynamic var dismissBlock: TTGDismissBlock? = nil

  /// Snackbar display duration. Default is Short - 1 second.
  @objc open dynamic var duration: TTGSnackbarDuration = TTGSnackbarDuration.short

  /// Snackbar animation type. Default is SlideFromBottomBackToBottom.
  @objc open dynamic var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.slideFromBottomBackToBottom

  /// Show and hide animation duration. Default is 0.3
  @objc open dynamic var animationDuration: TimeInterval = 0.3

  /// Corner radius: [0, height / 2]. Default is 4
  @objc open dynamic var cornerRadius: CGFloat = 4.0 {
    didSet {
      if cornerRadius < 0.0 {
        cornerRadius = 0.0
      }

      layer.cornerRadius = cornerRadius
      layer.masksToBounds = true
    }
  }

  /// Left margin. Default is 4
  @objc open dynamic var leftMargin: CGFloat = 4.0 {
    didSet {
      leftMarginConstraint?.constant = leftMargin
      superview?.layoutIfNeeded()
    }
  }

  /// Right margin. Default is 4
  @objc open dynamic var rightMargin: CGFloat = 4.0 {
    didSet {
      rightMarginConstraint?.constant = -rightMargin
      superview?.layoutIfNeeded()
    }
  }

  /// Bottom margin. Default is 4, only work when snackbar is at bottom
  @objc open dynamic var bottomMargin: CGFloat = 4.0 {
    didSet {
      bottomMarginConstraint?.constant = -bottomMargin
      superview?.layoutIfNeeded()
    }
  }

  /// Top margin. Default is 4, only work when snackbar is at top
  @objc open dynamic var topMargin: CGFloat = 4.0 {
    didSet {
      topMarginConstraint?.constant = topMargin
      superview?.layoutIfNeeded()
    }
  }

  /// Content inset. Default is (0, 4, 0, 4)
  @objc open dynamic var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4) {
    didSet {
      contentViewTopConstraint?.constant = contentInset.top
      contentViewBottomConstraint?.constant = -contentInset.bottom
      contentViewLeftConstraint?.constant = contentInset.left
      contentViewRightConstraint?.constant = -contentInset.right
      layoutIfNeeded()
      superview?.layoutIfNeeded()
    }
  }

  /// Main text shown on the snackbar.
  @objc open dynamic var message: String = "" {
    didSet {
      messageLabel?.text = message
    }
  }

  /// Message text color. Default is white.
  @objc open dynamic var messageTextColor: UIColor = UIColor.white {
    didSet {
      messageLabel?.textColor = messageTextColor
    }
  }

  /// Message text font.
  @objc open dynamic var messageTextFont: UIFont = TTGSnackbar.defaultFont {
    didSet {
      messageLabel?.font = messageTextFont
    }
  }

  /// Message text alignment. Default is left
  @objc open dynamic var messageTextAlign: NSTextAlignment = .left {
    didSet {
      messageLabel.textAlignment = messageTextAlign
    }
  }

  /// Action button title.
  @objc open dynamic var actionText: String = "" {
    didSet {
      actionButton.setTitle(actionText, for: UIControl.State())
    }
  }

  /// Action button image.
  @objc open dynamic var actionIcon: UIImage? = nil {
    didSet {
      actionButton.setImage(actionIcon, for: UIControl.State())
    }
  }

  /// Second action button title.
  @objc open dynamic var secondActionText: String = "" {
    didSet {
      secondActionButton.setTitle(secondActionText, for: UIControl.State())
    }
  }

  /// Action button title color. Default is white.
  @objc open dynamic var actionTextColor: UIColor = UIColor.white {
    didSet {
      actionButton.setTitleColor(actionTextColor, for: UIControl.State())
    }
  }

  /// Second action button title color. Default is white.
  @objc open dynamic var secondActionTextColor: UIColor = UIColor.white {
    didSet {
      secondActionButton.setTitleColor(secondActionTextColor, for: UIControl.State())
    }
  }

  /// Action text font.
  @objc open dynamic var actionTextFont: UIFont = TTGSnackbar.defaultFont {
    didSet {
      actionButton.titleLabel?.font = actionTextFont
    }
  }

  /// Second action text font.
  @objc open dynamic var secondActionTextFont: UIFont = TTGSnackbar.defaultFont {
    didSet {
      secondActionButton.titleLabel?.font = secondActionTextFont
    }
  }

  /// Action button max width, min = 44
  @objc open dynamic var actionMaxWidth: CGFloat = 64.0 {
    didSet {
      actionMaxWidth = actionMaxWidth < 44.0 ? 44.0 : actionMaxWidth
      actionButtonMaxWidthConstraint?.constant = actionButton.isHidden ? 0 : actionMaxWidth
      secondActionButtonMaxWidthConstraint?.constant = secondActionButton.isHidden ? 0 : actionMaxWidth
      layoutIfNeeded()
    }
  }

  /// Action button text number of lines. Default is 1
  @objc open dynamic var actionTextNumberOfLines: Int = 1 {
    didSet {
      actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
      secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
      layoutIfNeeded()
    }
  }

  /// Icon image
  @objc open dynamic var icon: UIImage? = nil {
    didSet {
      iconImageView.image = icon
    }
  }

  /// Icon image content
  @objc open dynamic var iconContentMode: UIView.ContentMode = .center {
    didSet {
      iconImageView.contentMode = iconContentMode
    }
  }

  /// Custom container view
  @objc open dynamic var containerView: UIView?

  /// Custom content view
  @objc open dynamic var customContentView: UIView?

  /// SeparateView background color
  @objc open dynamic var separateViewBackgroundColor: UIColor = UIColor.gray {
    didSet {
      separateView.backgroundColor = separateViewBackgroundColor
    }
  }

  /// ActivityIndicatorViewStyle
  @objc open dynamic var activityIndicatorViewStyle: UIActivityIndicatorView.Style {
    get {
      return activityIndicatorView.style
    }
    set {
      activityIndicatorView.style = newValue
    }
  }

  /// ActivityIndicatorView color
  @objc open dynamic var activityIndicatorViewColor: UIColor {
    get {
      return activityIndicatorView.color ?? .white
    }
    set {
      activityIndicatorView.color = newValue
    }
  }

  /// Animation SpringWithDamping. Default is 0.7
  @objc open dynamic var animationSpringWithDamping: CGFloat = 0.7

  /// Animation initialSpringVelocity
  @objc open dynamic var animationInitialSpringVelocity: CGFloat = 5.0

  // MARK: - Private property.

  private var contentView: UIView!
  private var iconImageView: UIImageView!
  private var messageLabel: UILabel!
  private var separateView: UIView!
  private var actionButton: UIButton!
  private var secondActionButton: UIButton!
  private var activityIndicatorView: UIActivityIndicatorView!

  /// Timer to dismiss the snackbar.
  private var dismissTimer: Timer? = nil

  // Constraints.
  private var leftMarginConstraint: NSLayoutConstraint? = nil
  private var rightMarginConstraint: NSLayoutConstraint? = nil
  private var bottomMarginConstraint: NSLayoutConstraint? = nil
  private var topMarginConstraint: NSLayoutConstraint? = nil // Only work when top animation type
  private var centerXConstraint: NSLayoutConstraint? = nil

  // Content constraints.
  private var iconImageViewWidthConstraint: NSLayoutConstraint? = nil
  private var actionButtonMaxWidthConstraint: NSLayoutConstraint? = nil
  private var secondActionButtonMaxWidthConstraint: NSLayoutConstraint? = nil

  private var contentViewLeftConstraint: NSLayoutConstraint? = nil
  private var contentViewRightConstraint: NSLayoutConstraint? = nil
  private var contentViewTopConstraint: NSLayoutConstraint? = nil
  private var contentViewBottomConstraint: NSLayoutConstraint? = nil

  // MARK: - Deinit
  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  // MARK: - Default init

  public required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  public override init(frame: CGRect) {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    configure()
  }

  /**
   Default init

   - returns: TTGSnackbar instance
   */
  public init() {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    configure()
  }

  /**
   Show a single message like a Toast.

   - parameter message:  Message text.
   - parameter duration: Duration type.

   - returns: TTGSnackbar instance
   */
  @objc public init(message: String, duration: TTGSnackbarDuration) {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    self.duration = duration
    self.message = message
    configure()
  }

  /**
   Show a customContentView like a Toast

   - parameter customContentView: Custom View to be shown.
   - parameter duration: Duration type.

   - returns: TTGSnackbar instance
   */
  public init(customContentView: UIView, duration: TTGSnackbarDuration) {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    self.duration = duration
    self.customContentView = customContentView
    configure()
  }

  /**
   Show a message with action button.

   - parameter message:     Message text.
   - parameter duration:    Duration type.
   - parameter actionText:  Action button title.
   - parameter actionBlock: Action callback closure.

   - returns: TTGSnackbar instance
   */
  public init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: @escaping TTGActionBlock) {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    self.duration = duration
    self.message = message
    self.actionText = actionText
    self.actionBlock = actionBlock
    configure()
  }

  /**
   Show a custom message with action button.

   - parameter message:          Message text.
   - parameter duration:         Duration type.
   - parameter actionText:       Action button title.
   - parameter messageFont:      Message label font.
   - parameter actionButtonFont: Action button font.
   - parameter actionBlock:      Action callback closure.

   - returns: TTGSnackbar instance
   */
  public init(message: String, duration: TTGSnackbarDuration, actionText: String, messageFont: UIFont, actionTextFont: UIFont, actionBlock: @escaping TTGActionBlock) {
    super.init(frame: TTGSnackbar.snackbarDefaultFrame)
    self.duration = duration
    self.message = message
    self.actionText = actionText
    self.actionBlock = actionBlock
    self.messageTextFont = messageFont
    self.actionTextFont = actionTextFont
    configure()
  }

  // Override
  open override func layoutSubviews() {
    super.layoutSubviews()
    if messageLabel.preferredMaxLayoutWidth != messageLabel.frame.size.width {
      messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
      setNeedsLayout()
    }
    super.layoutSubviews()
  }
}

// MARK: - Show methods.

public extension TTGSnackbar {

  /**
   Show the snackbar.
   */
  @objc public func show() {
    // Only show once
    if superview != nil {
      return
    }

    // Create dismiss timer
    dismissTimer = Timer.init(timeInterval: (TimeInterval)(duration.rawValue),
                              target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)
    guard let dismissTimer = self.dismissTimer else { return }
    RunLoop.main.add(dismissTimer, forMode: .common)

    // Show or hide action button
    iconImageView.isHidden = icon == nil

    actionButton.isHidden = (actionIcon == nil || actionText.isEmpty) == false || actionBlock == nil
    secondActionButton.isHidden = secondActionText.isEmpty || secondActionBlock == nil

    separateView.isHidden = actionButton.isHidden

    iconImageViewWidthConstraint?.constant = iconImageView.isHidden ? 0 : TTGSnackbar.snackbarIconImageViewWidth
    actionButtonMaxWidthConstraint?.constant = actionButton.isHidden ? 0 : actionMaxWidth
    secondActionButtonMaxWidthConstraint?.constant = secondActionButton.isHidden ? 0 : actionMaxWidth

    // Content View
    guard let finalContentView = customContentView ?? contentView else { return }
    finalContentView.translatesAutoresizingMaskIntoConstraints = false
    addSubview(finalContentView)

    contentViewTopConstraint = NSLayoutConstraint.init(item: finalContentView, attribute: .top, relatedBy: .equal,
                                                       toItem: self, attribute: .top, multiplier: 1, constant: contentInset.top)
    contentViewBottomConstraint = NSLayoutConstraint.init(item: finalContentView, attribute: .bottom, relatedBy: .equal,
                                                          toItem: self, attribute: .bottom, multiplier: 1, constant: -contentInset.bottom)
    contentViewLeftConstraint = NSLayoutConstraint.init(item: finalContentView, attribute: .left, relatedBy: .equal,
                                                        toItem: self, attribute: .left, multiplier: 1, constant: contentInset.left)
    contentViewRightConstraint = NSLayoutConstraint.init(item: finalContentView, attribute: .right, relatedBy: .equal,
                                                         toItem: self, attribute: .right, multiplier: 1, constant: -contentInset.right)

    addConstraints([
      contentViewTopConstraint.unwrapped,
      contentViewBottomConstraint.unwrapped,
      contentViewLeftConstraint.unwrapped,
      contentViewRightConstraint.unwrapped
      ])

    // Get super view to show
    if let superView = containerView ?? UIApplication.shared.delegate?.window ?? UIApplication.shared.keyWindow {
      superView.addSubview(self)

      // Left margin constraint
      if #available(iOS 11.0, *) {
        leftMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .left, relatedBy: .equal,
          toItem: superView.safeAreaLayoutGuide, attribute: .left, multiplier: 1, constant: leftMargin)
      } else {
        leftMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .left, relatedBy: .equal,
          toItem: superView, attribute: .left, multiplier: 1, constant: leftMargin)
      }

      // Right margin constraint
      if #available(iOS 11.0, *) {
        rightMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .right, relatedBy: .equal,
          toItem: superView.safeAreaLayoutGuide, attribute: .right, multiplier: 1, constant: -rightMargin)
      } else {
        rightMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .right, relatedBy: .equal,
          toItem: superView, attribute: .right, multiplier: 1, constant: -rightMargin)
      }

      // Bottom margin constraint
      if #available(iOS 11.0, *) {
        bottomMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .bottom, relatedBy: .equal,
          toItem: superView.safeAreaLayoutGuide, attribute: .bottom, multiplier: 1, constant: -bottomMargin)
      } else {
        bottomMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .bottom, relatedBy: .equal,
          toItem: superView, attribute: .bottom, multiplier: 1, constant: -bottomMargin)
      }

      // Top margin constraint
      if #available(iOS 11.0, *) {
        topMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .top, relatedBy: .equal,
          toItem: superView.safeAreaLayoutGuide, attribute: .top, multiplier: 1, constant: topMargin)
      } else {
        topMarginConstraint = NSLayoutConstraint.init(
          item: self, attribute: .top, relatedBy: .equal,
          toItem: superView, attribute: .top, multiplier: 1, constant: topMargin)
      }

      // Center X constraint
      centerXConstraint = NSLayoutConstraint.init(
        item: self, attribute: .centerX, relatedBy: .equal,
        toItem: superView, attribute: .centerX, multiplier: 1, constant: 0)

      // Min height constraint
      let minHeightConstraint = NSLayoutConstraint.init(
        item: self, attribute: .height, relatedBy: .greaterThanOrEqual,
        toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarMinHeight)

      // Avoid the "UIView-Encapsulated-Layout-Height" constraint conflicts
      // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
      leftMarginConstraint?.priority = UILayoutPriority.high
      rightMarginConstraint?.priority = UILayoutPriority.high
      topMarginConstraint?.priority = UILayoutPriority.high
      bottomMarginConstraint?.priority = UILayoutPriority.high
      centerXConstraint?.priority = UILayoutPriority.high

      // Add constraints
      superView.addConstraint(leftMarginConstraint)
      superView.addConstraint(rightMarginConstraint)
      superView.addConstraint(bottomMarginConstraint)
      superView.addConstraint(topMarginConstraint)
      superView.addConstraint(centerXConstraint)
      superView.addConstraint(minHeightConstraint)

      // Active or deactive
      topMarginConstraint?.isActive = false // For top animation
      leftMarginConstraint?.isActive = self.shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
      rightMarginConstraint?.isActive = self.shouldActivateLeftAndRightMarginOnCustomContentView ? true : customContentView == nil
      centerXConstraint?.isActive = customContentView != nil

      // Show
      showWithAnimation()
    } else {
      fatalError("TTGSnackbar needs a keyWindows to display.")
    }
  }

  /**
   Show.
   */
  private func showWithAnimation() {
    var animationBlock: (() -> Void)? = nil
    guard let superViewWidth = (superview?.frame)?.width else { return }
    let snackbarHeight = systemLayoutSizeFitting(.init(width: superViewWidth - leftMargin - rightMargin, height: TTGSnackbar.snackbarMinHeight)).height

    switch animationType {

    case .fadeInFadeOut:
      alpha = 0.0
      // Animation
      animationBlock = {
        self.alpha = 1.0
      }

    case .slideFromBottomBackToBottom, .slideFromBottomToTop:
      bottomMarginConstraint?.constant = snackbarHeight

    case .slideFromLeftToRight:
      leftMarginConstraint?.constant = leftMargin - superViewWidth
      rightMarginConstraint?.constant = -rightMargin - superViewWidth
      bottomMarginConstraint?.constant = -bottomMargin
      centerXConstraint?.constant = -superViewWidth

    case .slideFromRightToLeft:
      leftMarginConstraint?.constant = leftMargin + superViewWidth
      rightMarginConstraint?.constant = -rightMargin + superViewWidth
      bottomMarginConstraint?.constant = -bottomMargin
      centerXConstraint?.constant = superViewWidth

    case .slideFromTopBackToTop, .slideFromTopToBottom:
      bottomMarginConstraint?.isActive = false
      topMarginConstraint?.isActive = true
      topMarginConstraint?.constant = -snackbarHeight
    }

    // Update init state
    superview?.layoutIfNeeded()

    // Final state
    bottomMarginConstraint?.constant = -bottomMargin
    topMarginConstraint?.constant = topMargin
    leftMarginConstraint?.constant = leftMargin
    rightMarginConstraint?.constant = -rightMargin
    centerXConstraint?.constant = 0.0

    UIView.animate(withDuration: animationDuration, delay: 0.0,
                   usingSpringWithDamping: animationSpringWithDamping,
                   initialSpringVelocity: animationInitialSpringVelocity, options: .allowUserInteraction,
                   animations: {
                    () -> Void in
                    animationBlock?()
                    self.superview?.layoutIfNeeded()
    }, completion: nil)
  }
}

// MARK: - Dismiss methods.

public extension TTGSnackbar {

  /**
   Dismiss the snackbar manually.
   */
  @objc public func dismiss() {
    // On main thread
    DispatchQueue.main.async {
      () -> Void in
      self.dismissAnimated(true)
    }
  }

  /**
   Dismiss.

   - parameter animated: If dismiss with animation.
   */
  private func dismissAnimated(_ animated: Bool) {
    // If the dismiss timer is nil, snackbar is dismissing or not ready to dismiss.
    if dismissTimer == nil {
      return
    }

    invalidDismissTimer()
    activityIndicatorView.stopAnimating()

    guard let superViewWidth = (superview?.frame)?.width else { return }
    let snackbarHeight = frame.size.height
    var safeAreaInsets = UIEdgeInsets.zero

    if #available(iOS 11.0, *) {
      safeAreaInsets = self.superview?.safeAreaInsets ?? UIEdgeInsets.zero
    }

    if !animated {
      dismissBlock?(self)
      removeFromSuperview()
      return
    }

    switch animationType {

    case .fadeInFadeOut: break

    case .slideFromBottomBackToBottom:
      bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom

    case .slideFromBottomToTop:
      bottomMarginConstraint?.constant = -snackbarHeight - bottomMargin

    case .slideFromLeftToRight:
      leftMarginConstraint?.constant = leftMargin + superViewWidth + safeAreaInsets.left
      rightMarginConstraint?.constant = -rightMargin + superViewWidth - safeAreaInsets.right
      centerXConstraint?.constant = superViewWidth

    case .slideFromRightToLeft:
      leftMarginConstraint?.constant = leftMargin - superViewWidth + safeAreaInsets.left
      rightMarginConstraint?.constant = -rightMargin - superViewWidth - safeAreaInsets.right
      centerXConstraint?.constant = -superViewWidth

    case .slideFromTopToBottom:
      topMarginConstraint?.isActive = false
      bottomMarginConstraint?.isActive = true
      bottomMarginConstraint?.constant = snackbarHeight + safeAreaInsets.bottom

    case .slideFromTopBackToTop:
      topMarginConstraint?.constant = -snackbarHeight - safeAreaInsets.top
    }

    setNeedsLayout()

    self.dismissBlock?(self)
    self.removeFromSuperview()
  }

  /**
   Invalid the dismiss timer.
   */
  private func invalidDismissTimer() {
    dismissTimer?.invalidate()
    dismissTimer = nil
  }
}

// MARK: - Init configuration.

private extension TTGSnackbar {

  func configure() {
    // Clear subViews
    _ = self.subviews.map { $0.removeFromSuperview() }

    // Notification
    NotificationCenter.default.addObserver(self, selector: #selector(onScreenRotateNotification),
                                           name: UIDevice.orientationDidChangeNotification, object: nil)

    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor.init(white: 0, alpha: 0.8)
    layer.cornerRadius = cornerRadius
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale

    layer.shadowOpacity = 0.4
    layer.shadowRadius = 2.0
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0, height: 2)

    contentView = UIView()
    contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.frame = TTGSnackbar.snackbarDefaultFrame
    contentView.backgroundColor = UIColor.clear

    iconImageView = UIImageView()
    iconImageView.translatesAutoresizingMaskIntoConstraints = false
    iconImageView.backgroundColor = UIColor.clear
    iconImageView.contentMode = iconContentMode
    contentView.addSubview(iconImageView)

    messageLabel = UILabel()
    messageLabel.accessibilityIdentifier = "messageLabel"
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    messageLabel.textColor = UIColor.white
    messageLabel.font = messageTextFont
    messageLabel.backgroundColor = UIColor.clear
    messageLabel.lineBreakMode = .byTruncatingTail
    messageLabel.numberOfLines = 0
    messageLabel.textAlignment = .left
    messageLabel.text = message
    contentView.addSubview(messageLabel)

    actionButton = UIButton()
    actionButton.accessibilityIdentifier = "actionButton"
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    actionButton.backgroundColor = UIColor.clear
    actionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    actionButton.titleLabel?.font = actionTextFont
    actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
    actionButton.setTitle(actionText, for: UIControl.State())
    actionButton.setTitleColor(actionTextColor, for: UIControl.State())
    actionButton.addTarget(self, action: #selector(doAction(_:)), for: .touchUpInside)
    contentView.addSubview(actionButton)

    secondActionButton = UIButton()
    secondActionButton.accessibilityIdentifier = "secondActionButton"
    secondActionButton.translatesAutoresizingMaskIntoConstraints = false
    secondActionButton.backgroundColor = UIColor.clear
    secondActionButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
    secondActionButton.titleLabel?.font = secondActionTextFont
    secondActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
    secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
    secondActionButton.setTitle(secondActionText, for: UIControl.State())
    secondActionButton.setTitleColor(secondActionTextColor, for: UIControl.State())
    secondActionButton.addTarget(self, action: #selector(doAction(_:)), for: .touchUpInside)
    contentView.addSubview(secondActionButton)

    separateView = UIView()
    separateView.translatesAutoresizingMaskIntoConstraints = false
    separateView.backgroundColor = separateViewBackgroundColor
    contentView.addSubview(separateView)

    activityIndicatorView = UIActivityIndicatorView(style: .white)
    activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    activityIndicatorView.stopAnimating()
    contentView.addSubview(activityIndicatorView)

    // Add constraints
    let hConstraints = NSLayoutConstraint.constraints(
      withVisualFormat: "H:|-0-[iconImageView]-2-[messageLabel]-2-[seperateView(0.5)]-2-[actionButton(>=44@999)]-0-[secondActionButton(>=44@999)]-0-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["iconImageView": iconImageView, "messageLabel": messageLabel, "seperateView": separateView, "actionButton": actionButton, "secondActionButton": secondActionButton])

    let vConstraintsForIconImageView = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-2-[iconImageView]-2-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["iconImageView": iconImageView])

    let vConstraintsForMessageLabel = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-0-[messageLabel]-0-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["messageLabel": messageLabel])

    let vConstraintsForSeperateView = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-4-[seperateView]-4-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["seperateView": separateView])

    let vConstraintsForActionButton = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-0-[actionButton]-0-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["actionButton": actionButton])

    let vConstraintsForSecondActionButton = NSLayoutConstraint.constraints(
      withVisualFormat: "V:|-0-[secondActionButton]-0-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["secondActionButton": secondActionButton])

    iconImageViewWidthConstraint = NSLayoutConstraint.init(
      item: iconImageView, attribute: .width, relatedBy: .equal,
      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarIconImageViewWidth)

    actionButtonMaxWidthConstraint = NSLayoutConstraint.init(
      item: actionButton, attribute: .width, relatedBy: .lessThanOrEqual,
      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: actionMaxWidth)

    secondActionButtonMaxWidthConstraint = NSLayoutConstraint.init(
      item: secondActionButton, attribute: .width, relatedBy: .lessThanOrEqual,
      toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: actionMaxWidth)

    let vConstraintForActivityIndicatorView = NSLayoutConstraint.init(
      item: activityIndicatorView, attribute: .centerY, relatedBy: .equal,
      toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)

    let hConstraintsForActivityIndicatorView = NSLayoutConstraint.constraints(
      withVisualFormat: "H:[activityIndicatorView]-2-|",
      options: NSLayoutConstraint.FormatOptions(rawValue: 0),
      metrics: nil,
      views: ["activityIndicatorView": activityIndicatorView])

    iconImageView.addConstraint(iconImageViewWidthConstraint)
    actionButton.addConstraint(actionButtonMaxWidthConstraint)
    secondActionButton.addConstraint(secondActionButtonMaxWidthConstraint)

    contentView.addConstraints(hConstraints)
    contentView.addConstraints(vConstraintsForIconImageView)
    contentView.addConstraints(vConstraintsForMessageLabel)
    contentView.addConstraints(vConstraintsForSeperateView)
    contentView.addConstraints(vConstraintsForActionButton)
    contentView.addConstraints(vConstraintsForSecondActionButton)
    contentView.addConstraint(vConstraintForActivityIndicatorView)
    contentView.addConstraints(hConstraintsForActivityIndicatorView)

    messageLabel.setContentHuggingPriority(UILayoutPriority.maximum, for: .vertical)
    messageLabel.setContentCompressionResistancePriority(UILayoutPriority.maximum, for: .vertical)

    actionButton.setContentHuggingPriority(UILayoutPriority.important, for: .horizontal)
    actionButton.setContentCompressionResistancePriority(UILayoutPriority.high, for: .horizontal)
    secondActionButton.setContentHuggingPriority(UILayoutPriority.important, for: .horizontal)
    secondActionButton.setContentCompressionResistancePriority(UILayoutPriority.high, for: .horizontal)

    // add gesture recognizers
    // tap gesture
    self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.didTapSelf)))

    self.isUserInteractionEnabled = true

    // swipe gestures
    [UISwipeGestureRecognizer.Direction.up, .down, .left, .right].forEach { (direction) in
      let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.didSwipeSelf(_:)))
      gesture.direction = direction
      self.addGestureRecognizer(gesture)
    }
  }
}

// MARK: - Actions

private extension TTGSnackbar {

  /**
   Action button callback

   - parameter button: action button
   */
  @objc func doAction(_ button: UIButton) {
    // Call action block first
    button == actionButton ? actionBlock?(self) : secondActionBlock?(self)

    // Show activity indicator
    if duration == .forever && actionButton.isHidden == false {
      actionButton.isHidden = true
      secondActionButton.isHidden = true
      separateView.isHidden = true
      activityIndicatorView.isHidden = false
      activityIndicatorView.startAnimating()
    } else {
      dismissAnimated(true)
    }
  }

  /// tap callback
  @objc private func didTapSelf() {
    self.onTapBlock?(self)
  }

  /**
   Action button callback

   - parameter gesture: the gesture that is sent to the user
   */
  @objc func didSwipeSelf(_ gesture: UISwipeGestureRecognizer) {
    self.onSwipeBlock?(self, gesture.direction)

    if self.shouldDismissOnSwipe {
      switch gesture.direction {
      case .right: self.animationType = .slideFromLeftToRight
      case .left: self.animationType = .slideFromRightToLeft
      case .up: self.animationType = .slideFromTopBackToTop
      case .down: self.animationType = .slideFromTopBackToTop
      default: break
      }
      self.dismiss()
    }
  }
}

// MARK: - Rotation notification

private extension TTGSnackbar {
  @objc func onScreenRotateNotification() {
    messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
    layoutIfNeeded()
  }
}

// MARK: - UILayoutPriority
extension UILayoutPriority {

  static let maximum: UILayoutPriority = UILayoutPriority(1000.0)

  static let high: UILayoutPriority = UILayoutPriority(999.0)

  static let important: UILayoutPriority = UILayoutPriority(998.0)

  /* Ask the owner (zekunyan) about this magic numbers */
}

// MARK: - UIView
extension UIView {

  func addConstraint(_ constraint: NSLayoutConstraint?) {
    self.addConstraint(constraint ?? NSLayoutConstraint())
  }
}

// MARK: - NSLayoutConstraint
extension Optional where Wrapped == NSLayoutConstraint {

  var unwrapped: NSLayoutConstraint {
    return self ??  NSLayoutConstraint()
  }
}
