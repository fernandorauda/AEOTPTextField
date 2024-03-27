//
//  AEOTPViewRepresentable.swift
//  AEOTPTextField-SwiftUI
//
//  Created by Abdelrhman Eliwa on 31/05/2022.
//

import SwiftUI

@available(iOS 13.0, *)
struct AEOTPViewRepresentable: UIViewRepresentable {
    @Binding private var text: String
    private let slotsCount: Int
    private let otpDefaultCharacter: String
    private let otpBackgroundColor: UIColor
    private let otpFilledBackgroundColor: UIColor
    private let otpCornerRaduis: CGFloat
    private let otpDefaultBorderColor: UIColor
    private let otpFilledBorderColor: UIColor
    private let otpDefaultBorderWidth: CGFloat
    private let otpFilledBorderWidth: CGFloat
    private let otpTextColor: UIColor
    private let otpFontSize: CGFloat
    private let otpFont: UIFont
    private let isSecureTextEntry: Bool
    private let onCommit: (() -> Void)?
    private let textField: AEOTPTextFieldSwiftUI
    private let toolbar = UIToolbar(frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 50))

    
    var focusable: Binding<[Bool]>?
    var tag: Int?
    
        
    init(
        text: Binding<String>,
        slotsCount: Int = 6,
        otpDefaultCharacter: String = "",
        otpBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1),
        otpFilledBackgroundColor: UIColor = UIColor(red: 0.949, green: 0.949, blue: 0.949, alpha: 1),
        otpCornerRaduis: CGFloat = 10,
        otpDefaultBorderColor: UIColor = .clear,
        otpFilledBorderColor: UIColor = .darkGray,
        otpDefaultBorderWidth: CGFloat = 1,
        otpFilledBorderWidth: CGFloat = 1,
        otpTextColor: UIColor = .black,
        otpFontSize: CGFloat = 14,
        otpFont: UIFont = UIFont.systemFont(ofSize: 14),
        isSecureTextEntry: Bool = false,
        focusable: Binding<[Bool]>?,
        tag: Int = 0,
        inputAccessoryView: UIView?,
        onCommit: (() -> Void)? = nil
    ) {
        self._text = text
        self.slotsCount = slotsCount
        self.otpDefaultCharacter = otpDefaultCharacter
        self.otpBackgroundColor = otpBackgroundColor
        self.otpFilledBackgroundColor = otpFilledBackgroundColor
        self.otpCornerRaduis = otpCornerRaduis
        self.otpDefaultBorderColor = otpDefaultBorderColor
        self.otpFilledBorderColor = otpFilledBorderColor
        self.otpDefaultBorderWidth = otpDefaultBorderWidth
        self.otpFilledBorderWidth = otpFilledBorderWidth
        self.otpTextColor = otpTextColor
        self.otpFontSize = otpFontSize
        self.otpFont = otpFont
        self.isSecureTextEntry = isSecureTextEntry
        self.focusable = focusable
        self.tag = tag
        self.onCommit = onCommit

        self.textField = AEOTPTextFieldSwiftUI(
            slotsCount: slotsCount,
            otpDefaultCharacter: otpDefaultCharacter,
            otpBackgroundColor: otpBackgroundColor,
            otpFilledBackgroundColor: otpFilledBackgroundColor,
            otpCornerRaduis: otpCornerRaduis,
            otpDefaultBorderColor: otpDefaultBorderColor,
            otpFilledBorderColor: otpFilledBorderColor,
            otpDefaultBorderWidth: otpDefaultBorderWidth,
            otpFilledBorderWidth: otpFilledBorderWidth,
            otpTextColor: otpTextColor,
            otpFontSize: otpFontSize,
            otpFont: otpFont,
            isSecureTextEntry: isSecureTextEntry,
            tag: tag,
            inputAccessoryView: toolbar
        )
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text, slotsCount: slotsCount, control: self, onCommit: onCommit)
    }
    
    func makeUIView(context: Context) -> AEOTPTextFieldSwiftUI {
        textField.delegate = context.coordinator
        
        if let tag = tag {
             textField.tag = tag
         }
        
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange(_:)), for: .editingChanged)
        toolbar.items = [
                UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
                UIBarButtonItem(title: (focusable?.wrappedValue.count ?? 0) - 1 == tag ? "Listo" : "Siguiente", style: .plain, target: context.coordinator, action: #selector(Coordinator.textFieldShouldReturn(_:)))]

        toolbar.sizeToFit()
        
        return textField
    }
    
    func updateUIView(_ uiView: AEOTPTextFieldSwiftUI, context: Context) { 
        uiView.text = text

        if let focusable = focusable?.wrappedValue {
            var resignResponder = true
            
            for (index, focused) in focusable.enumerated() {
                if uiView.tag == index && focused {
                    DispatchQueue.main.async {
                        uiView.becomeFirstResponder()
                    }
                    resignResponder = false
                    break
                }
            }
            
            if resignResponder {
                DispatchQueue.main.async {
                    uiView.resignFirstResponder()
                }
            }
        }
    }
    
    class Coordinator: NSObject, UITextFieldDelegate {
        let control: AEOTPViewRepresentable
        
        @Binding private var text: String
        
        private let slotsCount: Int
        private let onCommit: (() -> Void)?
        
        
        init(
            text: Binding<String>,
            slotsCount: Int,
            control: AEOTPViewRepresentable,
            onCommit: (() -> Void)?
        ) {
            self._text = text
            self.slotsCount = slotsCount
            self.onCommit = onCommit
            self.control = control
            
            super.init()
        }
        
        func textFieldDidBeginEditing(_ textField: UITextField) {
            guard var focusable = control.focusable?.wrappedValue else { return }
            
            for i in 0...(focusable.count - 1) {
                focusable[i] = (textField.tag == i)
            }
            
            DispatchQueue.main.async {
                self.control.focusable?.wrappedValue = focusable
            }
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if textField.text?.count == slotsCount {
                onCommit?()
            }
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            guard var focusable = control.focusable?.wrappedValue else {
                DispatchQueue.main.async {
                    textField.resignFirstResponder()
                }
                return true
            }
            
            for i in 0...(focusable.count - 1) {
                focusable[i] = (textField.tag + 1 == i)
            }
            
            control.focusable?.wrappedValue = focusable
            
            if control.tag == focusable.count - 1 {
                DispatchQueue.main.async {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
            }
            
            return true
        }
        
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            guard let characterCount = textField.text?.count else { return false }
            return characterCount < slotsCount || string.isEmpty
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            control.text = textField.text ?? ""
        }
    }
}
