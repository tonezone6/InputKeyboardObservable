//
//  CustomField.swift
//  CustomLoading
//
//  Created by Alex Stratu on 01/03/2019.
//  Copyright © 2019 Alex Stratu. All rights reserved.
//

import UIKit

// MARK: - Styling

struct TextInputStyle {
    static let placeholderColor = UIColor(white: 200/255, alpha: 1.0)
    static let textColor = UIColor.darkGray
    static let font = UIFont.systemFont(ofSize: 14)
    static let cornerRadius: CGFloat = 4.0
}

// MARK: - Rounded text field

class RoundedTextField: UITextField, InputKeyboardObservable {
    
    public var didBeginEditingHandler: ((_ sender: InputKeyboardObservable) -> ())?
    
    private let padding = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.cornerRadius = TextInputStyle.cornerRadius
        textColor = TextInputStyle.textColor
        font = TextInputStyle.font
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [.foregroundColor: TextInputStyle.placeholderColor]
        )
        delegate = self
    }
}

extension RoundedTextField: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        didBeginEditingHandler?(self)
    }
}


// MARK: - Rounded text view

class RoundedTextView: UITextView, InputKeyboardObservable {
    
    public var didBeginEditingHandler: ((_ sender: InputKeyboardObservable) -> ())?
    private let placeholder = "Placeholder 6"
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        text = placeholder
        font = TextInputStyle.font
        textColor = TextInputStyle.placeholderColor
        layer.cornerRadius = TextInputStyle.cornerRadius
        returnKeyType = .default
        textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textContainer.lineFragmentPadding = 0
        delegate = self
    }
}

extension RoundedTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        didBeginEditingHandler?(self)
        if textView.text == placeholder {
            textView.text = ""
            textView.textColor = TextInputStyle.textColor
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placeholder
            textView.textColor = TextInputStyle.placeholderColor
        }
    }
}
