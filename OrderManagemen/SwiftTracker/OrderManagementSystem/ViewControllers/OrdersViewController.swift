import UIKit
import CoreData

class OrdersViewController: UIViewController {

    // MARK: - Properties

    private var orders: [Order] = []
    private let tableView = UITableView()
    private let emptyStateLabel: UILabel = { // Label for empty state
        let label = UILabel()
        label.text = "No orders found.\nTap '+' to add a new order."
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18)
        label.isHidden = true // Initially hidden
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addOrderButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+ Add Orders", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground // Use system background
        setupNavigationBar()
        setupUI() // Setup the add order button first
        setupTableView() // Then setup the table view
        setupEmptyStateView() // Setup the empty state label
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.prefersLargeTitles = true // Use large titles
        fetchOrders() // Fetch orders every time the view appears
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        title = "My Orders"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let logoutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonTapped))
        navigationItem.leftBarButtonItem = logoutButton
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(newOrderButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }

    private func setupUI() {
        // Add the add order button
        view.addSubview(addOrderButton)
        
        NSLayoutConstraint.activate([
            addOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addOrderButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Add action for the button
        addOrderButton.addTarget(self, action: #selector(newOrderButtonTapped), for: .touchUpInside)
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(OrderTableViewCell.self, forCellReuseIdentifier: "OrderCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemGroupedBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        
        view.backgroundColor = .systemGroupedBackground
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 180),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: addOrderButton.topAnchor, constant: -16)
        ])
    }

     private func setupEmptyStateView() {
        view.addSubview(emptyStateLabel) // Add to the main view, above the table view initially

        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 30),
            emptyStateLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -30)
        ])
    }

    // MARK: - Data Management

    private func fetchOrders() {
        guard let user = UserManager.shared.currentUser else {
            print("Error: No current user found.")
            orders = [] // Clear orders if no user
            updateEmptyState()
            tableView.reloadData()
            // Optionally, force logout or show an error
            return
        }

        orders = CoreDataManager.shared.fetchOrdersForUser(user: user)
        // Optional: Sort orders (e.g., by due date)
        orders.sort { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }

        updateEmptyState() // Show/hide empty state label
        tableView.reloadData()
    }

    private func updateEmptyState() {
        emptyStateLabel.isHidden = !orders.isEmpty
    }


    // MARK: - Actions

    @objc private func newOrderButtonTapped() {
        let orderDetailVC = OrderDetailViewController(order: nil)
        orderDetailVC.delegate = self
        navigationController?.pushViewController(orderDetailVC, animated: true)
    }

    @objc private func logoutButtonTapped() {
        UserManager.shared.logout()
        
        let loginVC = LoginViewController()
        let navigationController = UINavigationController(rootViewController: loginVC)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }

    private func editOrder(_ order: Order) {
        let orderDetailVC = OrderDetailViewController(order: order)
        orderDetailVC.delegate = self
        navigationController?.pushViewController(orderDetailVC, animated: true)
    }

    private func deleteOrder(_ order: Order) {
        let alert = UIAlertController(title: "Delete Order", 
                                    message: "Are you sure you want to delete Order #\(order.orderNumber ?? "")? This action cannot be undone.", 
                                    preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            if CoreDataManager.shared.deleteOrder(order) {
                // Show success message
                let successAlert = UIAlertController(title: "Success", 
                                                   message: "Order #\(order.orderNumber ?? "") has been deleted.", 
                                                   preferredStyle: .alert)
                successAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(successAlert, animated: true) {
                    self?.fetchOrders()
                }
            } else {
                // Show error message
                let errorAlert = UIAlertController(title: "Error", 
                                                 message: "Failed to delete the order. Please try again.", 
                                                 preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(errorAlert, animated: true)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension OrdersViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orders.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as? OrderTableViewCell else {
            fatalError("Could not dequeue OrderTableViewCell") // Use fatalError in dev
        }

        let order = orders[indexPath.row]
        cell.configure(with: order)
        
        // Set up delete action
        cell.onDelete = { [weak self] in
            self?.deleteOrder(order)
        }

        return cell
    }

    // Set dynamic height or a fixed height based on your cell design
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160 // Increased height for better spacing
    }

    // Handle row selection (e.g., view details, could be same as edit)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedOrder = orders[indexPath.row]
        editOrder(selectedOrder) // Or navigate to a read-only view if desired
    }

    // Swipe Actions (Edit and Delete)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let order = orders[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completion) in
            self?.deleteOrder(order)
            completion(true)
        }
        deleteAction.backgroundColor = .systemRed
        
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [weak self] (_, _, completion) in
            self?.editOrder(order)
            completion(true)
        }
        editAction.backgroundColor = .systemBlue
        
        return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .systemGroupedBackground
        
        let headerLabel = UILabel()
        headerLabel.text = "Total Orders: \(orders.count)"
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        headerLabel.textColor = .secondaryLabel
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        headerView.addSubview(headerLabel)
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

// MARK: - OrderDetailViewControllerDelegate

extension OrdersViewController: OrderDetailViewControllerDelegate {
    func didSaveOrder() {
        fetchOrders() // Refetch data when an order is saved (created or updated)
    }
}
