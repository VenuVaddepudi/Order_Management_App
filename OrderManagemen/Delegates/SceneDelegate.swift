import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        
        // Check if user is logged in
        if UserManager.shared.isUserLoggedIn() {
            // Try to restore the current user
            if let user = UserManager.shared.getCurrentUser() {
                UserManager.shared.currentUser = user
                let ordersVC = OrdersViewController()
                let navigationController = UINavigationController(rootViewController: ordersVC)
                window?.rootViewController = navigationController
            } else {
                // If we can't restore the user, show login screen
                let loginVC = LoginViewController()
                let navigationController = UINavigationController(rootViewController: loginVC)
                window?.rootViewController = navigationController
            }
        } else {
            let loginVC = LoginViewController()
            let navigationController = UINavigationController(rootViewController: loginVC)
            window?.rootViewController = navigationController
        }
        
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}
