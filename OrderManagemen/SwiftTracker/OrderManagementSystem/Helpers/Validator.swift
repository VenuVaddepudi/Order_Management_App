import Foundation

/// Validator handles validation logic for the application
class Validator {
    
    /// Validates a username
    /// - Parameter username: The username to validate
    /// - Returns: True if the username is valid, false otherwise
    static func isValidUsername(_ username: String) -> Bool {
        return !username.isEmpty && username.count >= 3
    }
    
    /// Validates a password
    /// - Parameter password: The password to validate
    /// - Returns: True if the password is valid, false otherwise
    static func isValidPassword(_ password: String) -> Bool {
        return !password.isEmpty && password.count >= 6
    }
    
    /// Validates whether two passwords match
    /// - Parameters:
    ///   - password: The first password
    ///   - confirmPassword: The second password
    /// - Returns: True if the passwords match, false otherwise
    static func doPasswordsMatch(_ password: String, _ confirmPassword: String) -> Bool {
        return password == confirmPassword
    }
    
    /// Validates an order number
    /// - Parameter orderNumber: The order number to validate
    /// - Returns: True if the order number is valid, false otherwise
    static func isValidOrderNumber(_ orderNumber: String) -> Bool {
        return !orderNumber.isEmpty
    }
    
    /// Validates a customer name
    /// - Parameter name: The customer name to validate
    /// - Returns: True if the customer name is valid, false otherwise
    static func isValidCustomerName(_ name: String) -> Bool {
        return !name.isEmpty
    }
    
    /// Validates a customer address
    /// - Parameter address: The customer address to validate
    /// - Returns: True if the customer address is valid, false otherwise
    static func isValidAddress(_ address: String) -> Bool {
        return !address.isEmpty
    }
    
    /// Validates a phone number
    /// - Parameter phone: The phone number to validate
    /// - Returns: True if the phone number is valid, false otherwise
    static func isValidPhoneNumber(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9+]{10,15}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
    
    /// Validates an order total
    /// - Parameter total: The order total to validate
    /// - Returns: True if the order total is valid, false otherwise
    static func isValidOrderTotal(_ total: String) -> Bool {
        if let totalValue = Double(total), totalValue > 0 {
            return true
        }
        return false
    }
}
