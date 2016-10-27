//
//  CTAlertController.swift
//  CTAlertViewControl
//
//  Created by JiangGuoxi on 16/5/26.
//  Copyright © 2016年 JiangGuoxi. All rights reserved.
//

import UIKit

class CTAlertController: UIViewController {

    internal var message: String?
    internal var attributedMessage: NSAttributedString?
    internal var attributedTitle: NSAttributedString?
    internal var customView: UIView?
    
    var lineColor = UIColor.lightGrayColor()
    var titleColor = UIColor.blueColor()
    var messageColor = UIColor.brownColor()
    var defaultColor = UIColor.blackColor()
    var cancelColor = UIColor.lightGrayColor()
    var cancelHColor = UIColor.lightGrayColor()
    var destructiveColor = UIColor.blueColor()
    var destructiveHColor = UIColor.blueColor()
    var titleFont:CGFloat = 15
    var messageFont:CGFloat = 14
    var buttonFont:CGFloat = 15
    
    private var alertActions = [CTAlertAction]()
    private var marginX:CGFloat = 0.0
    private var style: UIAlertControllerStyle = .Alert
    private var alertView = UIView()
    private var bgView = UIView()
    private var alertHeight:CGFloat = 0.0
    var viewWidth:CGFloat {
        return UIScreen.mainScreen().bounds.width - marginX * 2
    }
    var minHeight:CGFloat {
        if (message != nil || attributedMessage != nil) && (title != nil || attributedTitle != nil) {
            return 40.0
        }
        if (message == nil && attributedMessage == nil) && (title != nil || attributedTitle != nil) {
            return 60.0
        }

        return 45.0
    }
    private let screenHeight:CGFloat = UIScreen.mainScreen().bounds.height
    private let lineWidth: CGFloat = 1 / UIScreen.mainScreen().scale
    private var showing: Bool = false
    
    convenience init(title: String?, message: String?, preferredStyle: UIAlertControllerStyle) {
        self.init()
        self.title = title
        self.message = message
        self.style = preferredStyle
        setView()
    }
    
    convenience init(title: String?, customView: UIView?, preferredStyle: UIAlertControllerStyle) {
        self.init()
        self.title = title
        self.customView = customView
        self.style = preferredStyle
        setView()
    }
    private init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    internal func addAction(action: CTAlertAction) {
        alertActions.append(action)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if showing {
            return
        }
        showing = true
        self.configView()
    }
    
    private func setView() {
        view.backgroundColor = UIColor.clearColor()
        bgView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        bgView.frame = UIScreen.mainScreen().bounds
        modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        modalPresentationStyle = .OverCurrentContext
        providesPresentationContextTransitionStyle = true
        definesPresentationContext = true
        alertView.backgroundColor = UIColor.whiteColor()
        UIApplication.sharedApplication().delegate?.window??.addSubview(bgView)
        bgView.addSubview(alertView)
        if style == .Alert {
            marginX = 24.0
            alertView.layer.cornerRadius = 2
            alertView.layer.masksToBounds = true
        }
        alertView.addGestureRecognizer(UITapGestureRecognizer(action: { (tap) in }))
        bgView.addGestureRecognizer(UITapGestureRecognizer(action: {[weak self] (tap) in
            guard let _self = self else { return }
            _self.alertView.endEditing(false)
            if _self.style == .ActionSheet {
                _self.dismiss()
            }
        }))

    }
    
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CTAlertController.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(CTAlertController.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    private func configView() {
        if let _ = customView {
            configCustomView()
            addObserver()
        }else {
            configNormalView()
        }
    }
    
    private func configNormalView() {
        if style == .ActionSheet {
            if addTitleLabel() {
                addHLine()
            }
            if addMessageLabel() {
                addHLine()
            }
            addSheetActions()
            addSheetCancel()
        }
        if style == .Alert {
            addTitleLabel()
            addMessageLabel()
            addHLine()
            addAlertActions()
        }
        self.show()
    }
    private func show() {
        if style == .Alert {
            alertView.frame = CGRectMake(marginX, screenHeight/2 - alertHeight/2, viewWidth, alertHeight)
            let center = alertView.center
            alertView.center = center
            let trans = CGAffineTransformMakeScale(0.1, 0.1)
            alertView.transform = trans
            UIView.beginAnimations("trans", context: nil)
            UIView.setAnimationDuration(0.3)
            let deftrans = CGAffineTransformMakeScale(1, 1)
            alertView.transform = deftrans
            UIView.commitAnimations()
        }
        if style == .ActionSheet {
            alertView.frame = CGRectMake(marginX, screenHeight, viewWidth, alertHeight)
            UIView.animateWithDuration(0.3, animations: {
                self.alertView.frame = CGRectMake(self.marginX, self.screenHeight - self.alertHeight, self.viewWidth, self.alertHeight)
            })
        }
    }
    
    private func configCustomView() {
        guard let customView = customView else {return }
        addTitleLabel()
        let vsize = customView.frame.size
        customView.frame = CGRectMake(viewWidth/2 - vsize.width/2, alertHeight, vsize.width, vsize.height)
        alertView.addSubview(customView)
        alertHeight = CGRectGetMaxY(customView.frame)
        if style == .ActionSheet {
            addHLine()
            addSheetActions()
            addSheetCancel()
        }else {
            addAlertActions()
        }
        show()
    }
    
    private func addSheetActions() {
        alertActions.filter { (action) -> Bool in
            return action.style != .Cancel
            }.forEach { (action) in
                let btn = UIButton()
                btn.backgroundColor = UIColor.whiteColor()
                btn.frame = CGRectMake(0, alertHeight, viewWidth, 45)
                btn.setTitle(action.title, forState: .Normal)
                btn.titleLabel?.font = UIFont.systemFontOfSize(buttonFont)
                var tcor = defaultColor
                var hcor = defaultColor
                if action.style == .Destructive {
                    tcor = destructiveColor
                    hcor = destructiveHColor
                }
                btn.setTitleColor(tcor, forState: .Normal)
                btn.setTitleColor(hcor, forState: .Highlighted)
                btn.addAction({[weak self] (control) in
                    self?.dismiss({
                        action.handler?(action)
                    })
                    }, forControlEvents: .TouchUpInside)
                alertView.addSubview(btn)
                alertHeight = CGRectGetMaxY(btn.frame)
                addHLine()
        }
    }
    
    private func addAlertActions() {
        
        addHLine()
        var bx:CGFloat = 0.0
        let bw = viewWidth / CGFloat(alertActions.count)
        
        let cancels = alertActions.filter { (action) -> Bool in
            return action.style == .Cancel
        }
        cancels.forEach { (action) in
            let btn = UIButton()
            btn.backgroundColor = UIColor.whiteColor()
            btn.frame = CGRectMake(bx, alertHeight, bw, 40)
            btn.titleLabel?.font = UIFont.systemFontOfSize(buttonFont)
            btn.setTitle(action.title, forState: .Normal)
            btn.setTitleColor(cancelColor, forState: .Normal)
            btn.setTitleColor(cancelHColor, forState: .Highlighted)
            alertView.addSubview(btn)
            btn.addAction({[weak self] (control) in
                self?.dismiss({
                    action.handler?(action)
                })
                }, forControlEvents: .TouchUpInside)
            bx += bw
        }
        
        alertActions.filter({ (action) -> Bool in
            action.style != .Cancel
        }).forEach { (action) in
            let btn = UIButton()
            btn.frame = CGRectMake(bx, alertHeight, bw, 40)
            btn.setTitle(action.title, forState: .Normal)
            var titleColor:UIColor = defaultColor
            var hcolor = defaultColor
            if action.style == .Cancel {
                titleColor = cancelColor
                hcolor = cancelHColor
            }else if action.style == .Destructive {
                titleColor = destructiveColor
                hcolor = destructiveHColor
            }
            btn.setTitleColor(titleColor, forState: .Normal)
            btn.setTitleColor(hcolor, forState: .Highlighted)
            btn.titleLabel?.font = UIFont.systemFontOfSize(buttonFont)
            btn.addAction({[weak self] (control) in
                self?.dismiss({
                    action.handler?(action)
                })
                }, forControlEvents: .TouchUpInside)
            alertView.addSubview(btn)
            bx += bw
        }
        
        for i in 0 ..< alertActions.count {
            if i == alertActions.count - 1 {break}
            let vline = UIView()
            vline.frame = CGRectMake(bw * CGFloat(i) + bw, alertHeight, lineWidth, 40)
            vline.backgroundColor = lineColor
            alertView.addSubview(vline)
        }
        if alertActions.count > 0 {
            alertHeight += 40
        }
        
    }
    
    private func addSheetCancel() {
        let cancels = alertActions.filter { (action) -> Bool in
            return action.style == .Cancel
        }
        if let cancel = cancels.first {
            addHSepline()
            
            let cbtn = UIButton()
            cbtn.frame = CGRectMake(0, alertHeight, viewWidth, 45)
            alertView.addSubview(cbtn)
            cbtn.setTitle(cancel.title, forState: .Normal)
            cbtn.setTitleColor(cancelColor, forState: .Normal)
            cbtn.setTitleColor(cancelHColor, forState: .Highlighted)
            cbtn.backgroundColor = UIColor.whiteColor()
            cbtn.titleLabel?.font = UIFont.systemFontOfSize(buttonFont)
            cbtn.addAction({[weak self] (act) in
                self?.dismiss({
                    cancel.handler?(cancel)
                })
                }, forControlEvents: .TouchUpInside)
            
            alertHeight = CGRectGetMaxY(cbtn.frame)
        }
        
    }
    
    private func dismiss(block:(()->Void)? = nil) {
        dispatch_async(dispatch_get_main_queue()) {
            self.alertView.endEditing(true)
            if self.style == .Alert {
                UIView.beginAnimations("trans", context: nil)
                UIView.setAnimationDuration(0.3)
                let deftrans = CGAffineTransformMakeScale(0.1, 0.1)
                self.alertView.transform = deftrans
                UIView.commitAnimations()
            }
            if self.style == .ActionSheet {
                UIView.animateWithDuration(0.3, animations: {
                    self.alertView.frame = CGRectMake(self.marginX, self.screenHeight, self.viewWidth, self.alertHeight)
                })
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(300 * NSEC_PER_MSEC)), dispatch_get_main_queue(), {
                self.bgView.removeFromSuperview()
                self.dismissViewControllerAnimated(true, completion: block)
            })
            UIView.animateWithDuration(0.3, animations: {
                self.bgView.alpha = 0.5
            }) { (com) in
            }
        }
        
    }
    
    internal func hide() {
        dismiss()
    }
    
    private func addTitleLabel() ->Bool{
        var attTitle = attributedTitle
        if attTitle == nil && title != nil {
            attTitle = NSAttributedString(string: title!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(titleFont), NSForegroundColorAttributeName: titleColor])
        }
        if attTitle?.length > 0 {
            createLabel(attTitle!)
            return true
        }
        return false
    }
    
    private func addMessageLabel() ->Bool{
        var attStr = attributedMessage
        if attStr == nil && message != nil {
            attStr = NSAttributedString(string: message!, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(messageFont), NSForegroundColorAttributeName: messageColor])
        }
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 6
        style.alignment = .Center
        if attStr?.length > 0 {
            if alertHeight < 10 {
                alertHeight = 10
            }
            let attm = NSMutableAttributedString(attributedString: attStr!)
            attm.addAttribute(NSParagraphStyleAttributeName, value: style, range: NSMakeRange(0, attm.length))
            createLabel(attm)
            alertHeight += 10
            return true
        }
        return false
    }
    
    private func createLabel(att:NSAttributedString) {
        let tlabel = UILabel()
        tlabel.lineBreakMode = .ByCharWrapping
        tlabel.numberOfLines = 0
        tlabel.textAlignment = .Center
        tlabel.contentMode = .Center
        tlabel.attributedText = att
        let size = att.boundingRectWithSize(CGSizeMake(viewWidth, 999), options: [NSStringDrawingOptions.UsesFontLeading, .UsesLineFragmentOrigin], context: nil)
        tlabel.frame = CGRectMake(0, alertHeight, viewWidth, size.height > 30 ? size.height + 20: minHeight)
        alertView.addSubview(tlabel)
        alertHeight = CGRectGetMaxY(tlabel.frame)
    }
    private func addHLine() {
        let line = UIView()
        line.backgroundColor = lineColor
        line.frame = CGRectMake(0, alertHeight, viewWidth, lineWidth)
        alertView.addSubview(line)
        alertHeight = CGRectGetMaxY(line.frame)
    }
    private func addHSepline() {
        let line = UIView()
        line.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        line.frame = CGRectMake(0, alertHeight, viewWidth, 5)
        alertView.addSubview(line)
        alertHeight = CGRectGetMaxY(line.frame)
    }
    
    func keyboardWillShow(notic: NSNotification) {
        let beginRect = notic.userInfo![UIKeyboardFrameBeginUserInfoKey]
        let beginY = beginRect?.CGRectValue().origin.y ?? 0.0
        let endRect = notic.userInfo![UIKeyboardFrameEndUserInfoKey]
        let endY = endRect?.CGRectValue().origin.y ?? 0.0
        
        let margin = beginY - endY
        if (margin == lastDeltakeyboardMargin) {
            return;
        }
        lastDeltakeyboardMargin = margin
        layoutHeight(margin)
    }
    private var keyBoardHeight:CGFloat = 0.0
    private var lastDeltakeyboardMargin:CGFloat = 0.0
    
    func keyboardWillHide(notic: NSNotification) {
        lastDeltakeyboardMargin = -1
        keyBoardHeight = 0
        UIView.animateWithDuration(0.25) { 
            self.alertView.frame = CGRectMake(self.marginX, self.screenHeight/2 - self.alertHeight/2, self.viewWidth, self.alertHeight)
        }
    }
    private func layoutHeight(height:CGFloat) {
        keyBoardHeight += height
        let bottomY:CGFloat = screenHeight/2 - alertHeight/2
        if keyBoardHeight < bottomY {
            return
        }
        let needMoveY:CGFloat = keyBoardHeight - bottomY
        UIView.animateWithDuration(0.25) {
            self.alertView.frame = CGRectMake(self.marginX, self.screenHeight/2 - self.alertHeight/2 - needMoveY, self.viewWidth, self.alertHeight)
        }
    }
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        print("alertControllerDeinit")
    }
    
}

class CTAlertAction: NSObject {
    internal var title: String?
    internal var style: UIAlertActionStyle
    internal var enabled: Bool = true
    internal var handler:((CTAlertAction)->Void)?
    
    init(title: String?, style: UIAlertActionStyle, handler: ((CTAlertAction) -> Void)?) {
        self.title = title
        self.style = style
        self.handler = handler
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}