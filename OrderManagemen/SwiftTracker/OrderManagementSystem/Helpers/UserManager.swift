import UIKit
import CoreData

/// UserManager handles user session management for the application
class UserManager {
    
    // MARK: - Properties
    
    static let shared = UserManager()
    
    var currentUser: User?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - User Session Management
    
    /// Checks if a user is logged in
    /// - Returns: True if a user is logged in, false otherwise
    func isUserLoggedIn() -> Bool {
        return UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    /// Saves the current user's login state
    func saveUserLogin() {
        UserDefaults.standard.set(true, forKey: "isLoggedIn")
        if let username = currentUser?.username {
            UserDefaults.standard.set(username, forKey: "currentUsername")
        }
        UserDefaults.standard.synchronize()
    }
    
    /// Logs out the current user
    func logout() {
        currentUser = nil
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
        UserDefaults.standard.removeObject(forKey: "currentUsername")
        UserDefaults.standard.synchronize()
    }
    
    /// Gets the current user if available, otherwise tries to fetch from Core Data
    /// - Returns: The current user if available, nil otherwise
    func getCurrentUser() -> User? {
        if let currentUser = currentUser {
            return currentUser
        }
        
        // Try to find user from UserDefaults
        if let username = UserDefaults.standard.string(forKey: "currentUsername") {
            // Fetch user from Core Data
            let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "username == %@", username)
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return nil
            }
            
            let context = appDelegate.persistentContainer.viewContext
            
            do {
                let users = try context.fetch(fetchRequest)
                if let user = users.first {
                    currentUser = user
                    return user
                }
            } catch {
                print("Failed to fetch user: \(error)")
            }
        }
        
        return nil
    }
}
