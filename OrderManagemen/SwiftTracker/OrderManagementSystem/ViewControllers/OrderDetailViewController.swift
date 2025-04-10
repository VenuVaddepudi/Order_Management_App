import UIKit
import CoreData

protocol OrderDetailViewControllerDelegate: AnyObject {
    func didSaveOrder() // Renamed for clarity (implies both create and update)
}

class OrderDetailViewController: UIViewController {

    // MARK: - Properties

    weak var delegate: OrderDetailViewControllerDelegate?
    private var order: Order? // Holds the order being edited, or nil for new

    // MARK: - UI Components

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // Removed titleLabel, using navigationItem.title instead

    private let orderNumberLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Number:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium) // Slightly styled
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let orderNumberTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Order Number"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .allCharacters // Common for order numbers
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.text = "Due Date:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dueDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.minimumDate = Date() // Often, due dates are in the future
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        return datePicker
    }()

    private let buyerNameLabel: UILabel = {
        let label = UILabel()
        label.text = "Customer Name:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let buyerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Customer Name"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let addressLabel: UILabel = {
        let label = UILabel()
        label.text = "Customer Address:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let addressTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Customer Address"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .words
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let phoneLabel: UILabel = {
        let label = UILabel()
        label.text = "Customer Phone:"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let phoneTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Customer Phone"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .phonePad
        textField.textContentType = .telephoneNumber // Helps with autofill
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Total (₹):" // Added currency hint
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter Order Total"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Order", for: .normal) // More descriptive
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8 // Slightly larger radius
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // MARK: - Initialization

    init(order: Order?) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        setupActions()
        setupKeyboardDismissTap()
        populateOrderDetails() // Populate fields if editing
    }

    // MARK: - Setup

    private func setupNavigationBar() {
        // Set title based on whether creating or editing
        title = (order == nil) ? "New Order" : "Edit Order"
        navigationItem.largeTitleDisplayMode = .never // Prefer smaller title here
    }

    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground // Use system background

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)

        // Add subviews to content view
        contentView.addSubview(orderNumberLabel)
        contentView.addSubview(orderNumberTextField)
        contentView.addSubview(dueDateLabel)
        contentView.addSubview(dueDatePicker)
        contentView.addSubview(buyerNameLabel)
        contentView.addSubview(buyerNameTextField)
        contentView.addSubview(addressLabel)
        contentView.addSubview(addressTextField)
        contentView.addSubview(phoneLabel)
        contentView.addSubview(phoneTextField)
        contentView.addSubview(totalLabel)
        contentView.addSubview(totalTextField)
        contentView.addSubview(saveButton)

        let standardPadding: CGFloat = 20.0
        let verticalSpacing: CGFloat = 8.0
        let sectionSpacing: CGFloat = 16.0
        let textFieldHeight: CGFloat = 44.0

        // Setup constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            // --- Order Number ---
            orderNumberLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: standardPadding), // Adjusted top anchor
            orderNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            orderNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            orderNumberTextField.topAnchor.constraint(equalTo: orderNumberLabel.bottomAnchor, constant: verticalSpacing),
            orderNumberTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            orderNumberTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            orderNumberTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            // --- Due Date ---
            dueDateLabel.topAnchor.constraint(equalTo: orderNumberTextField.bottomAnchor, constant: sectionSpacing),
            dueDateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            dueDateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            dueDatePicker.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: verticalSpacing),
            dueDatePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            dueDatePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            // Let date picker size itself vertically

            // --- Buyer Name ---
            buyerNameLabel.topAnchor.constraint(equalTo: dueDatePicker.bottomAnchor, constant: sectionSpacing),
            buyerNameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            buyerNameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            buyerNameTextField.topAnchor.constraint(equalTo: buyerNameLabel.bottomAnchor, constant: verticalSpacing),
            buyerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            buyerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            buyerNameTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            // --- Address ---
            addressLabel.topAnchor.constraint(equalTo: buyerNameTextField.bottomAnchor, constant: sectionSpacing),
            addressLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            addressLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            addressTextField.topAnchor.constraint(equalTo: addressLabel.bottomAnchor, constant: verticalSpacing),
            addressTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            addressTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            addressTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            // --- Phone ---
            phoneLabel.topAnchor.constraint(equalTo: addressTextField.bottomAnchor, constant: sectionSpacing),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            phoneTextField.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: verticalSpacing),
            phoneTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            phoneTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            phoneTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            // --- Total ---
            totalLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: sectionSpacing),
            totalLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            totalLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),

            totalTextField.topAnchor.constraint(equalTo: totalLabel.bottomAnchor, constant: verticalSpacing),
            totalTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            totalTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            totalTextField.heightAnchor.constraint(equalToConstant: textFieldHeight),

            // --- Save Button ---
            saveButton.topAnchor.constraint(equalTo: totalTextField.bottomAnchor, constant: 30),
            saveButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: standardPadding),
            saveButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -standardPadding),
            saveButton.heightAnchor.constraint(equalToConstant: 50), // Slightly taller button
            saveButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -standardPadding) // Ensure content scrolls
        ])
    }

    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
    }

    // Populate fields if an existing order was passed in
    private func populateOrderDetails() {
        guard let order = order else { return } // Only populate if editing

        orderNumberTextField.text = order.orderNumber
        if let dueDate = order.dueDate {
            dueDatePicker.date = dueDate
        }
        buyerNameTextField.text = order.buyerName
        addressTextField.text = order.address
        phoneTextField.text = order.phone
        // Format total nicely for display, ensuring locale correctness if needed
        totalTextField.text = String(format: "%.2f", order.total)
    }

    // MARK: - Keyboard Handling

    private func setupKeyboardDismissTap() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false // Allow interaction with controls like buttons
        view.addGestureRecognizer(tapGesture)
    }

    @objc internal override func dismissKeyboard() {
        view.endEditing(true) // Resigns first responder for any text field
    }

    // MARK: - Actions

    @objc private func saveButtonTapped() {
        dismissKeyboard() // Dismiss keyboard before validation

        // --- Input Validation ---
        guard let orderNumber = orderNumberTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !orderNumber.isEmpty else {
            showValidationError(message: "Order Number cannot be empty.")
            return
        }
        guard let buyerName = buyerNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !buyerName.isEmpty else {
            showValidationError(message: "Customer Name cannot be empty.")
            return
        }
        guard let address = addressTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !address.isEmpty else {
            showValidationError(message: "Customer Address cannot be empty.")
            return
        }
        guard let phone = phoneTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !phone.isEmpty else {
            showValidationError(message: "Customer Phone cannot be empty.")
            return
        }
        // Optional: Add phone number format validation here if needed

        guard let totalText = totalTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !totalText.isEmpty, let total = Double(totalText) else {
            showValidationError(message: "Valid Order Total is required.")
            return
        }
        guard total >= 0 else {
            showValidationError(message: "Order Total must be a positive number.")
            return
        }

        // --- Save Logic ---
        let dueDate = dueDatePicker.date
        var success = false

        if let existingOrder = order {
            // Update existing order
            success = CoreDataManager.shared.updateOrder(
                order: existingOrder,
                orderNumber: orderNumber,
                dueDate: dueDate,
                buyerName: buyerName,
                address: address,
                phone: phone,
                total: total
            )
        } else {
            // Create new order
            success = CoreDataManager.shared.createOrder(
                orderNumber: orderNumber,
                dueDate: dueDate,
                buyerName: buyerName,
                address: address,
                phone: phone,
                total: total
            )
        }

        // --- Post-Save Actions ---
        if success {
            delegate?.didSaveOrder()
            
            if let navigationController = navigationController {
                navigationController.popViewController(animated: true) // Navigate back if using navigation controller
            } else {
                dismiss(animated: true) // Dismiss if presented modally
            }
        } else {
            let alert = UIAlertController(title: "Save Error", message: "Could not save the order. Please try again.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }


    // Helper for showing validation errors
    private func showValidationError(message: String) {
        let alert = UIAlertController(title: "Validation Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
