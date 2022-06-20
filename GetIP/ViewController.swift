//
//  ViewController.swift
//  GetIP
//
//  Created by Emoticbox on 2022/06/20.
//

import UIKit

class ViewController: UIViewController {
    struct ExternalIPForm: Codable {
        let ip: String
    }
    
    lazy var ipTextField: UITextField = {
        let view: UITextField = .init(frame: .zero)
        
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        
        view.backgroundColor = .white
        view.font = .systemFont(ofSize: 15, weight: .semibold)
        view.textColor = .black
        view.textAlignment = .center
        view.isUserInteractionEnabled = false
        
        let placeholderAttributedString: NSAttributedString = .init(string: "\"GET External IP\" 버튼을 눌러주세요!",
                                                                    attributes: [NSAttributedString.Key.foregroundColor : UIColor.lightGray])
        view.attributedPlaceholder = placeholderAttributedString
        return view
    }()
    
    lazy var getButton: UIButton = {
        let button: UIButton = .init(frame: .zero)
        
        button.setTitle("GET External IP", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(getButtonAction), for: .touchUpInside)
        
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 5
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        layout()
    }
    
    private func layout() {
        let safe: UILayoutGuide = view.safeAreaLayoutGuide
        
        view.addSubview(ipTextField)
        ipTextField.translatesAutoresizingMaskIntoConstraints = false
        [
            ipTextField.centerYAnchor.constraint(equalTo: safe.centerYAnchor),
            ipTextField.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            ipTextField.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            ipTextField.heightAnchor.constraint(equalToConstant: 50)
        ].forEach { $0.isActive = true }
        
        view.addSubview(getButton)
        getButton.translatesAutoresizingMaskIntoConstraints = false
        [
            getButton.topAnchor.constraint(equalTo: ipTextField.bottomAnchor, constant: 20),
            getButton.leadingAnchor.constraint(equalTo: safe.leadingAnchor, constant: 20),
            getButton.trailingAnchor.constraint(equalTo: safe.trailingAnchor, constant: -20),
            getButton.heightAnchor.constraint(equalToConstant: 50)
        ].forEach { $0.isActive = true }
        
    }
    
    func getExternalIP(_ completionHandler: @escaping (ExternalIPForm?, Error?) -> Void) {
        let apiString: String = "https://api.ipify.org?format=json"
        guard let url: URL = .init(string: apiString) else {
            completionHandler(nil, NSError.create(code: -1, description: "이 값은 URL이 아닙니다! \(apiString)"))
            return
        }
        
        var request: URLRequest = .init(url: url)
        request.httpMethod = "GET"
        
        DispatchQueue.global(qos: .background).async {
            URLSession.shared.dataTask(with: request) { data, response, error in
                print("reiceved...")
                
                if let error = error {
                    completionHandler(nil, error)
                    return
                }
                
                if let data = data {
                    do {
                        let ipValue: ExternalIPForm = try JSONDecoder().decode(ExternalIPForm.self, from: data)
                        completionHandler(ipValue, nil)
                    } catch let _error {
                       completionHandler(nil, _error)
                    }
                }// if data
            }.resume()
        }// DispatchQueue-background
    }
    
    @objc
    func getButtonAction( _ sender: UIButton) {
        print("push getButtonAction")
        DispatchQueue.main.async {
            self.ipTextField.text = "Loading..."
            self.ipTextField.setNeedsDisplay()
        }
        
        
        
        getExternalIP { resultValue, error in
            print("output value", resultValue?.ip ?? "e?", error?.localizedDescription ?? "")
            guard error == nil else {
                print(error!.localizedDescription)
                DispatchQueue.main.async {
                    self.ipTextField.text = "에러! 다시 시도해주세요!"
                }
                return
            }
            if let resultValue = resultValue {
                DispatchQueue.main.async {
                    self.ipTextField.text = resultValue.ip
                }
            }// if resultValue
        }// getExternalIP
    }
}
extension NSError {
    static func create(code: Int, description: String) -> Error {
        let nserror:NSError = .init(domain: "kr.dy.getip", code: code, userInfo: [NSLocalizedDescriptionKey:description])
        return nserror as Error
    }
}
