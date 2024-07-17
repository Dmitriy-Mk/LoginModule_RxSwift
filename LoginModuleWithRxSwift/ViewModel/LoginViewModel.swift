//
//  LoginViewModel.swift
//  ValidationRX_MVVM_EXample
//
//  Created by Dmitry Mkrtumyan on 17.07.24.
//

import Foundation
import RxSwift
import RxCocoa

final class LoginViewModel {
    
    let userData = UserData()
    
    // Inputs
    let loginText = BehaviorRelay<String>(value: "")
    let passwordText = BehaviorRelay<String>(value: "")
    let loginButtonTapped = PublishSubject<Void>()
    
    // Outputs
    let messageText = BehaviorRelay<String?>(value: nil)
    let shakeLoginTextField = PublishSubject<Void>()
    let shakePasswordTextField = PublishSubject<Void>()
    let goToProfileViewController = PublishSubject<Void>()
    let triggerAlert = PublishSubject<Void>()
    
    func validate() {
        if loginText.value.isEmpty
            && passwordText.value.isEmpty {
            messageText.accept("Enter email and password")
            shakeLoginTextField.onNext(())
            shakePasswordTextField.onNext(())
        } else if loginText.value.isEmpty {
            messageText.accept("Enter login")
            shakeLoginTextField.onNext(())
        } else if passwordText.value.isEmpty {
            messageText.accept("Enter password")
            shakePasswordTextField.onNext(())
        } else {
            
            if loginText.value == userData.userLogin &&
                passwordText.value == userData.userPassword {
                
                goToProfileViewController.onNext(())
            } else {
                triggerAlert.onNext(())
            }
        }
    }
}
