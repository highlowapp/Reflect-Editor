//
//  ReflectEditor.swift
//  HighLow
//
//  Created by Caleb Hester on 6/27/20.
//  Copyright © 2020 Caleb Hester. All rights reserved.
//

import UIKit
import WebKit
import Gridicons

class ReflectEditor: WKWebView, UITextFieldDelegate {
    
    var currentLink: String = ""

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        
    }
    
    func load() {
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        self.loadFileURL(url, allowingReadAccessTo: url)
        self.addInputAccessoryView(toolbar: getToolbar(height: 44))
    }
    
    func getToolbar(height: Int) -> UIToolbar? {
        let toolBar = UIToolbar()
        toolBar.frame = CGRect(x: 0, y: 50, width: 320, height: height)
        toolBar.barStyle = .default
        toolBar.barTintColor = .white
        toolBar.tintColor = AppColors.primary

        let bold = UIBarButtonItem(image: .gridicon(.bold), style: .plain, target: self, action: #selector(toggleBoldface(_:)))
        let italics = UIBarButtonItem(image: .gridicon(.italic), style: .plain, target: self, action: #selector(toggleItalics(_:)))
        let underline = UIBarButtonItem(image: .gridicon(.underline), style: .plain, target: self, action: #selector(toggleUnderline(_:)))
        let strikeThrough = UIBarButtonItem(image: .gridicon(.strikethrough), style: .plain, target: self, action: #selector(toggleStrikethrough))
        let link = UIBarButtonItem(image: .gridicon(.link), style: .plain, target: self, action: #selector(createLink))

        toolBar.setItems([bold, italics, underline, strikeThrough, link], animated: false)
    
        toolBar.isUserInteractionEnabled = true

        toolBar.sizeToFit()
        return toolBar
    }
    
    @objc func toggleStrikethrough() {
        self.evaluateJavaScript("document.execCommand('strikeThrough')") { results, error in
            
        }
    }
    
    @objc func createLink() {
        let alert = UIAlertController(title: "Enter URL:", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "https://example.com"
            textField.addTarget(self, action: #selector(self.updateLink(_:)), for: .editingChanged)
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            let command = "clicker.onclick()"
            self.evaluateJavaScript(command, completionHandler: nil)
        }))
            
        window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    @objc func onToolbarDoneClick(sender: UIBarButtonItem) {
        self.resignFirstResponder()
    }
    
    @objc func updateLink(_ sender: UITextField) {
        currentLink = sender.text ?? ""
    }

}



var ToolbarHandle: UInt8 = 0

extension WKWebView {

    func addInputAccessoryView(toolbar: UIView?) {
        guard let toolbar = toolbar else {return}
        objc_setAssociatedObject(self, &ToolbarHandle, toolbar, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        var candidateView: UIView? = nil
        for view in self.scrollView.subviews {
            let description : String = String(describing: type(of: view))
            if description.hasPrefix("WKContent") {
                candidateView = view
                break
            }
        }
        guard let targetView = candidateView else {return}
        let newClass: AnyClass? = classWithCustomAccessoryView(targetView: targetView)

        guard let targetNewClass = newClass else {return}

        object_setClass(targetView, targetNewClass)
    }

    func classWithCustomAccessoryView(targetView: UIView) -> AnyClass? {
        guard let _ = targetView.superclass else {return nil}
        let customInputAccesoryViewClassName = "_CustomInputAccessoryView"

        var newClass: AnyClass? = NSClassFromString(customInputAccesoryViewClassName)
        if newClass == nil {
            newClass = objc_allocateClassPair(object_getClass(targetView), customInputAccesoryViewClassName, 0)
        } else {
            return newClass
        }

        let newMethod = class_getInstanceMethod(WKWebView.self, #selector(WKWebView.getCustomInputAccessoryView))
        class_addMethod(newClass.self, #selector(getter: WKWebView.inputAccessoryView), method_getImplementation(newMethod!), method_getTypeEncoding(newMethod!))

        objc_registerClassPair(newClass!)

        return newClass
    }

    @objc func getCustomInputAccessoryView() -> UIView? {
        var superWebView: UIView? = self
        while (superWebView != nil) && !(superWebView is WKWebView) {
            superWebView = superWebView?.superview
        }

        guard let webView = superWebView else {return nil}

        let customInputAccessory = objc_getAssociatedObject(webView, &ToolbarHandle)
        return customInputAccessory as? UIView
    }
}
