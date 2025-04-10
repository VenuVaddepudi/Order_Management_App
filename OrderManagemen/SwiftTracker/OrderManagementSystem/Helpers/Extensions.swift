import UIKit

// MARK: - UIViewController Extension

extension UIViewController {
    
    /// Shows an alert with the given title and message
    /// - Parameters:
    ///   - title: The title of the alert
    ///   - message: The message of the alert
    ///   - completion: A completion handler to execute after the alert is dismissed
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?()
        })
        
        present(alertController, animated: true)
    }
    
    /// Adds tap gesture to dismiss keyboard when tapping outside text fields
    func addKeyboardDismissGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - Date Extension

extension Date {
    
    /// Returns a formatted string for the date
    /// - Parameter format: The date format
    /// - Returns: A string representation of the date
    func formatted(with format: String = "MM/dd/yyyy") -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}

// MARK: - String Extension

extension String {
    
    /// Returns a date from a string
    /// - Parameter format: The date format
    /// - Returns: A Date object if the conversion is successful, nil otherwise
    func toDate(format: String = "MM/dd/yyyy") -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.date(from: self)
    }
}

// MARK: - UITextField Extension

extension UITextField {
    
    /// Adds a done button to the keyboard
    func addDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        
        toolBar.items = [flexibleSpace, doneButton]
        
        self.inputAccessoryView = toolBar
    }
    
    @objc private func dismissKeyboard() {
        self.resignFirstResponder()
    }
}
