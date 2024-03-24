//
//  SwiftUIView.swift
//  AEOTPTextFieldExample
//
//  Created by Abdelrhman Eliwa on 01/06/2022.
//
import SwiftUI
import AEOTPTextField

struct SwiftUIView: View {
    // MARK: - PROPERTIES
    //
    @State private var otp: String = ""
    @State private var otp2: String = ""
    @State private var focusables = [false, false]

    @State private var alertIsPresented: Bool = false
    
    // MARK: - BODY
    //
    var body: some View {
        VStack(alignment: .leading) {
            Text("Please, enter the code")
                .padding(.top, 60)
                .padding(.leading, 16)
            
            AEOTPView(
                text: $otp,
                slotsCount: 2,
                width: 190.0,
                height: 40.0,
                otpBackgroundColor: .clear,
                otpFilledBackgroundColor: .clear,
                otpDefaultBorderColor: .gray,
                otpFilledBorderColor: .red,
                otpDefaultBorderWidth: 1,
                otpFilledBorderWidth: 2,
                focusable: $focusables,
                tag: 0
            ) {
                hideKeyboard()
            } //: AEOTPView
            .padding()
            
            AEOTPView(
                text: $otp2,
                slotsCount: 2,
                width: 190.0,
                height: 40.0,
                otpBackgroundColor: .clear,
                otpFilledBackgroundColor: .clear,
                otpDefaultBorderColor: .gray,
                otpFilledBorderColor: .red,
                otpDefaultBorderWidth: 1,
                otpFilledBorderWidth: 2,
                focusable: $focusables,
                tag: 1
            ) {
                alertIsPresented = true
            } //: AEOTPView
            .padding()
            
            Spacer()
        } //: VStack
        .alert(isPresented: $alertIsPresented) {
            otpAlert
        } //: alert
    } //: body
    
    private var otpAlert: Alert {
        Alert(
            title: Text("Verify Result"),
            message: Text(otp == "123456" ? "Success" : "Failure"),
            dismissButton: .default(Text("Done"), action: {
                alertIsPresented = false
            })
        )
    } //: otpAlert
}


#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif
