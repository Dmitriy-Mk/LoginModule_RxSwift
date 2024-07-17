//
//  ViewController.swift
//  ValidationRX_MVVM_EXample
//
//  Created by Marat Guseynov on 11.02.2024.
//

import UIKit
import RxSwift
import RxCocoa

class LogInViewController: UIViewController {
    
    let userData = UserData()
    let VKColor = #colorLiteral(red: 0.3174450696, green: 0.5025064945, blue: 0.7219160199, alpha: 1)
    
    private let textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.layer.cornerRadius = 10
        stackView.layer.borderWidth = 0.5
        stackView.layer.borderColor = UIColor.lightGray.cgColor
        stackView.layer.masksToBounds = true
        stackView.backgroundColor = .systemGray6
        return stackView
    }()
    
    lazy var loginTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Email"
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor.systemGray
        textField.autocapitalizationType = .none
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        return textField
    }()
    
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Password"
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        textField.tintColor = UIColor.systemGray
        textField.isSecureTextEntry = true
        textField.setLeftPaddingPoints(10)
        textField.setRightPaddingPoints(10)
        return textField
    }()
    
    lazy var loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log in", for: .normal)
        button.backgroundColor = VKColor
        button.layer.cornerRadius = 10
        button.layer.shadowOffset = CGSize(width: 4, height: 4)
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.7
        button.layer.shadowRadius = 4
//        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        button.addTarget(self, action: #selector(touchDown), for: .touchDown)
        button.addTarget(self, action: #selector(touchUp), for: .touchUpInside)
        return button
    }()
    
    private let logoView: UIImageView = {
        let logo = UIImageView()
        logo.translatesAutoresizingMaskIntoConstraints = false
        logo.image = UIImage(named: "logo.png")
        return logo
    }()
    
    private var messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemGray
        return label
    }()
    
    private func addViewLayout() {
        
        view.addSubview(logoView)
        view.addSubview(textFieldStackView)
        view.addSubview(loginButton)
        view.addSubview(messageLabel)
        textFieldStackView.addArrangedSubview(loginTextField)
        textFieldStackView.addArrangedSubview(passwordTextField)
        
        NSLayoutConstraint.activate([
            messageLabel.bottomAnchor.constraint(equalTo: textFieldStackView.topAnchor, constant: -16),
            messageLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            logoView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoView.heightAnchor.constraint(equalToConstant: 100),
            logoView.widthAnchor.constraint(equalToConstant: 100),
            logoView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            
            textFieldStackView.topAnchor.constraint(equalTo: logoView.bottomAnchor, constant: 120),
            textFieldStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            passwordTextField.heightAnchor.constraint(equalToConstant: 50),
            loginTextField.heightAnchor.constraint(equalToConstant: 50),
            
            loginButton.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 16),
            loginButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            loginButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            loginButton.heightAnchor.constraint(equalToConstant: 50),
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        addViewLayout()
        setupInputBindings()
        setupOutputBinding()
    }
    
    //MARK: - RX
    
    var loginViewModel = LoginViewModel()
    private let disposeBag = DisposeBag()
    
    private func setupInputBindings() {
        loginTextField.rx.text.orEmpty.bind(to: loginViewModel.loginText)
            .disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.bind(to: loginViewModel.passwordText)
            .disposed(by: disposeBag)
        loginButton.rx.tap.bind { self.loginViewModel.validate()}
            .disposed(by: disposeBag)
    }
    
    private func setupOutputBinding() {
        loginViewModel.messageText.bind(to: messageLabel.rx.text).disposed(by: disposeBag)
        
        loginViewModel.shakeLoginTextField
            .subscribe (onNext: { [ weak self ] in
                guard let self else { return }
                self.shakeAnimationLoginTextField()
            })
            .disposed(by: disposeBag)
        
        loginViewModel.shakePasswordTextField
            .subscribe (onNext: { [ weak self ] in
                guard let self else { return }
                self.shakeAnimationPasswordTextField()
            })
            .disposed(by: disposeBag)
        
        loginViewModel.goToProfileViewController
            .subscribe (onNext: { [ weak self ] in
                guard let self else { return }
                let vc = ProfileViewController()
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        loginViewModel.triggerAlert
            .subscribe (onNext: { [ weak self ] in
                guard let self else { return }
                
                let allertController = UIAlertController(title: "Wrong data",
                                               message: "You have entered wrong email or password",
                                               preferredStyle: .alert)
                let allertAction = UIAlertAction(title: "Ok", style: .destructive)
                
                allertController.addAction(allertAction)
                self.present(allertController, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
