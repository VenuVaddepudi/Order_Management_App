import UIKit
import CoreData

/// CoreDataManager handles all Core Data operations for the application
class CoreDataManager {
    
    // MARK: - Properties
    
    static let shared = CoreDataManager()
    
    private let context: NSManagedObjectContext
    
    // MARK: - Initialization
    
    private init() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("AppDelegate not found")
        }
        
        context = appDelegate.persistentContainer.viewContext
    }
    
    // MARK: - User Management
    
    /// Creates a new user with the provided username and password
    /// - Parameters:
    ///   - username: The username for the new user
    ///   - password: The password for the new user
    /// - Returns: True if the user was created successfully, false otherwise
    func createUser(username: String, password: String) -> Bool {
        guard let userEntity = NSEntityDescription.entity(forEntityName: "User", in: context) else {
            return false
        }
        
        let user = NSManagedObject(entity: userEntity, insertInto: context) as! User
        user.username = username
        user.password = password
        user.rememberMe = false
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to create user: \(error)")
            return false
        }
    }
    
    /// Checks if a username is already taken
    /// - Parameter username: The username to check
    /// - Returns: True if the username exists, false otherwise
    func isUsernameTaken(username: String) -> Bool {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@", username)
        
        do {
            let count = try context.count(for: fetchRequest)
            return count > 0
        } catch {
            print("Failed to check username: \(error)")
            return false
        }
    }
    
    /// Authenticates a user with the provided username and password
    /// - Parameters:
    ///   - username: The username to authenticate
    ///   - password: The password to authenticate
    /// - Returns: The authenticated User object if successful, nil otherwise
    func authenticateUser(username: String, password: String) -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username == %@ AND password == %@", username, password)
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Failed to authenticate user: \(error)")
            return nil
        }
    }
    
    /// Updates the remember me state for a user
    /// - Parameters:
    ///   - user: The user to update
    ///   - rememberMe: The new remember me state
    /// - Returns: True if the update was successful, false otherwise
    func updateUserRememberMe(user: User, rememberMe: Bool) -> Bool {
        user.rememberMe = rememberMe
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to update user: \(error)")
            return false
        }
    }
    
    // MARK: - Order Management
    
    /// Creates a new order with the provided details
    /// - Parameters:
    ///   - orderNumber: The order number
    ///   - dueDate: The order due date
    ///   - buyerName: The customer name
    ///   - address: The customer address
    ///   - phone: The customer phone number
    ///   - total: The order total
    /// - Returns: True if the order was created successfully, false otherwise
    func createOrder(orderNumber: String, dueDate: Date, buyerName: String, address: String, phone: String, total: Double) -> Bool {
        guard let currentUser = UserManager.shared.currentUser,
              let orderEntity = NSEntityDescription.entity(forEntityName: "Order", in: context) else {
            return false
        }
        
        let order = NSManagedObject(entity: orderEntity, insertInto: context) as! Order
        
        order.orderNumber = orderNumber
        order.dueDate = dueDate
        order.buyerName = buyerName
        order.address = address
        order.phone = phone
        order.total = total
        order.user = currentUser
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to create order: \(error)")
            return false
        }
    }
    
    /// Updates an existing order with the provided details
    /// - Parameters:
    ///   - order: The order to update
    ///   - orderNumber: The new order number
    ///   - dueDate: The new order due date
    ///   - buyerName: The new customer name
    ///   - address: The new customer address
    ///   - phone: The new customer phone number
    ///   - total: The new order total
    /// - Returns: True if the order was updated successfully, false otherwise
    func updateOrder(order: Order, orderNumber: String, dueDate: Date, buyerName: String, address: String, phone: String, total: Double) -> Bool {
        order.orderNumber = orderNumber
        order.dueDate = dueDate
        order.buyerName = buyerName
        order.address = address
        order.phone = phone
        order.total = total
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to update order: \(error)")
            return false
        }
    }
    
    /// Deletes an order
    /// - Parameter order: The order to delete
    /// - Returns: True if the order was deleted successfully, false otherwise
    func deleteOrder(_ order: Order) -> Bool {
        context.delete(order)
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed to delete order: \(error)")
            return false
        }
    }
    
    /// Fetches all orders for a specific user
    /// - Parameter user: The user to fetch orders for
    /// - Returns: An array of Order objects
    func fetchOrdersForUser(user: User) -> [Order] {
        let fetchRequest: NSFetchRequest<Order> = Order.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "user == %@", user)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dueDate", ascending: true)]
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch orders: \(error)")
            return []
        }
    }
}
