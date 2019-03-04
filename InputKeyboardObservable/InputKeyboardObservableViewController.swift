//
//  InputKeyboardObservableViewController.swift
//  InputKeyboardObservable
//
//  Created by Alex Stratu on 01/03/2019.
//  Copyright © 2019 Alex Stratu. All rights reserved.
//

import UIKit

protocol InputKeyboardObservable {
    /**
    Inform 'InputKeyboardObservableViewController' when text input did begin editing
    in order to adjust scroll view content offset to display text input just above keyboard */
    var didBeginEditingHandler: ((_ sender: InputKeyboardObservable) -> Void)? { get set }
}

class InputKeyboardObservableViewController: UIViewController {
    
    private weak var scrollView: UIScrollView?
    
    private var textInputArray: [InputKeyboardObservable] = []
    private var currentTextInputIndex = 0
    
    private var previousButton: UIBarButtonItem?
    private var nextButton: UIBarButtonItem?
    
    private let distanceFromTextField: CGFloat = 16
    private var keyboardHeight: CGFloat = 0

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupScrollAndTextInput()
        setupTapToDismiss()
        setupToolbar()
        
        registerToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unregisterFromKeyboardNotifications()
    }
}


// MARK: - Setup

extension InputKeyboardObservableViewController {
    
    private func setupScrollAndTextInput() {
        for subview in view.subviews {
            if let scrollView = subview as? UIScrollView {
                self.scrollView = scrollView
            } else { return }
        }
        textInputArray = findTextInput(inView: self.view)
        textInputArray.forEach { setupHandler(textInputItem: $0) }
    }
    
    private func findTextInput(inView view: UIView) -> [InputKeyboardObservable] {
        var array: [InputKeyboardObservable] = []
        for subview in view.subviews {
            array += findTextInput(inView: subview)
            if let subview = subview as? InputKeyboardObservable  {
                array.append(subview)
            }
        }
        return array
    }
}


// MARK: - KB notifications

extension InputKeyboardObservableViewController {
    
    private func registerToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboard(notification:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(self,
            selector: #selector(handleKeyboard(notification:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    private func unregisterFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.removeObserver(self,
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
    }
    
    @objc private func handleKeyboard(notification: NSNotification) {
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            guard
                let userInfo = notification.userInfo,
                let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.size.height
            else { return }
            keyboardHeight = height
            scrollView?.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: height + distanceFromTextField, right: 0)
            scrollView?.scrollIndicatorInsets.bottom = height
        case UIResponder.keyboardWillHideNotification:
            scrollView?.contentInset = .zero
            scrollView?.scrollIndicatorInsets = .zero
        default: ()
        }
    }
}


// MARK: - Text input keyboard observable handler

extension InputKeyboardObservableViewController {
    
    func setupHandler(textInputItem: InputKeyboardObservable) {
        var textInput = textInputItem
        textInput.didBeginEditingHandler = { [unowned self] sender in
            var contentOffset = CGPoint.zero
            // UITextField
            if let textField = sender as? UITextField {
                contentOffset = CGPoint(x: 0, y: textField.frame.origin.y - textField.frame.height - self.keyboardHeight - self.distanceFromTextField)
                if let index = self.textInputArray.index(where: { ($0 as? UITextField) == textField }) {
                    self.currentTextInputIndex = index
                    self.handleToolbarButtons()
                }
            }
            // UITextView
            if let textView = sender as? UITextView {
                contentOffset = CGPoint(x: 0, y: textView.frame.origin.y - self.keyboardHeight)
                if let index = self.textInputArray.index(where: { ($0 as? UITextView) == textView }) {
                    self.currentTextInputIndex = index
                    self.handleToolbarButtons()
                }
            }
            if self.keyboardHeight > 0 {
                self.scrollView?.setContentOffset(contentOffset, animated: true)
            }
        }
    }
}

// MARK: - Toolbar

extension InputKeyboardObservableViewController {
    
    private func setupToolbar() {
        // Toolbar
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        // Toolbar buttons
        previousButton = UIBarButtonItem(
            title: "Previous", style: .plain, target: self, action: #selector(goToPrevious(sender:))
        )
        nextButton = UIBarButtonItem(
            title: "Next", style: .plain, target: self, action: #selector(goToNext(sender:))
        )
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace, target: nil, action: nil
        )
        let doneButton = UIBarButtonItem(
            title: "Done", style: .done, target: self, action: #selector(dismissKeyboard(sender:))
        )
        guard let previous = previousButton, let next = nextButton else { return }
        textInputArray.count == 1 ?
            (toolbar.items = [flexibleSpace, doneButton]) :
            (toolbar.items = [previous, next, flexibleSpace, doneButton])
        toolbar.sizeToFit()
        // Setup input fields toolbar
        for item in textInputArray {
            if let textfield = item as? UITextField {
                textfield.inputAccessoryView = toolbar
                textfield.autocorrectionType = .no
            }
            if let textview = item as? UITextView {
                textview.inputAccessoryView = toolbar
                textview.autocorrectionType = .no
            }
        }
    }
    
    @objc private func goToPrevious(sender: UIBarButtonItem) {
        let previous = currentTextInputIndex - 1
        guard previous >= 0 else { return }
        if let textField = textInputArray[previous] as? UITextField {
            textField.becomeFirstResponder()
        }
        if let textView = textInputArray[previous] as? UITextView {
            textView.becomeFirstResponder()
        }
    }
    
    @objc private func goToNext(sender: UIBarButtonItem) {
        let next = currentTextInputIndex + 1
        guard next < textInputArray.count else { return }
        if let textField = textInputArray[next] as? UITextField {
            textField.becomeFirstResponder()
        }
        if let textView = textInputArray[next] as? UITextView {
            textView.becomeFirstResponder()
        }
    }
    
    @objc private func dismissKeyboard(sender: UIBarButtonItem) {
        view.endEditing(true)
        scrollToBottom()
    }
    
    private func handleToolbarButtons() {
        switch currentTextInputIndex {
        case 0:
            previousButton?.isEnabled = false
            nextButton?.isEnabled = true
        case textInputArray.count - 1:
            previousButton?.isEnabled = true
            nextButton?.isEnabled = false
        default:
            previousButton?.isEnabled = true
            nextButton?.isEnabled = true
        }
    }
}

// MARK: - Tap outside dismissable keyboard

extension InputKeyboardObservableViewController {
    
    private func setupTapToDismiss() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(handleDismiss(tap:)))
        tap.cancelsTouchesInView = false
        scrollView?.addGestureRecognizer(tap)
    }
    
    private func scrollToBottom() {
        guard let scroll = scrollView else { return }
        let bottomOffset = CGPoint(x: 0, y: scroll.contentSize.height - scroll.bounds.size.height)
        scroll.setContentOffset(bottomOffset, animated: true)
    }
    
    @objc private func handleDismiss(tap: UITapGestureRecognizer) {
        view.endEditing(true)
        scrollToBottom()
    }
}
