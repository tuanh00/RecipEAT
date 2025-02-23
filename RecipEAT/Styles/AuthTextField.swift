import SwiftUI

struct AuthTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String = ""
    var icon: UIImage? = nil
    var isSecure: Bool = false  // when true, behaves like SecureField

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.placeholder = placeholder
        
        // Disable the keyboard for custom input (prevents layout shifting).
        textField.inputView = UIView()
        
        textField.isSecureTextEntry = isSecure
        textField.font = UIFont.systemFont(ofSize: 16)
        textField.backgroundColor = .white
        textField.layer.cornerRadius = 7
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.autocapitalizationType = .none
        
        // For secure fields, set textContentType to .oneTimeCode to disable the strong password overlay.
        if isSecure {
            textField.textContentType = .oneTimeCode
        }
        
        // If an icon is provided, add it as the left view with padding left & right.
        if let icon = icon {
            let imageView = UIImageView(image: icon)
            imageView.contentMode = .scaleAspectFit
            // Icon is positioned with 8 points of padding.
            imageView.frame = CGRect(x: 8, y: 0, width: 24, height: 24)
            // Container view with width 40 (8 + 24 + 8) => both side padding
            let containerView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 24))
            containerView.addSubview(imageView)
            textField.leftView = containerView
            textField.leftViewMode = .always
        }
        
        textField.addTarget(context.coordinator,
                            action: #selector(Coordinator.textChanged(_:)),
                            for: .editingChanged)
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }
    
    class Coordinator: NSObject {
        @Binding var text: String
        init(text: Binding<String>) {
            _text = text
        }
        @objc func textChanged(_ sender: UITextField) {
            text = sender.text ?? ""
        }
    }
}
