import UIKit

class OrderTableViewCell: UITableViewCell {

    static let identifier = "OrderCell" // Reusable identifier

    // --- UI Elements (Add labels for order details) ---
    private let orderNumberLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .systemBlue
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .systemGreen
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 0.1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let customerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dueDateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .systemRed // Example: Highlight due date
        label.textAlignment = .right
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "trash"), for: .normal)
        button.tintColor = .systemRed
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
    
    // Callback for delete action
    var onDelete: (() -> Void)?

    // --- Initialization ---
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        // Remove the disclosure indicator
        accessoryType = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // --- UI Setup ---
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(orderNumberLabel)
        containerView.addSubview(dueDateLabel)
        containerView.addSubview(customerNameLabel)
        containerView.addSubview(totalLabel)
        containerView.addSubview(deleteButton)
        
        // Add action for delete button
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            
            orderNumberLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            orderNumberLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            totalLabel.centerYAnchor.constraint(equalTo: orderNumberLabel.centerYAnchor),
            totalLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            dueDateLabel.topAnchor.constraint(equalTo: orderNumberLabel.bottomAnchor, constant: 8),
            dueDateLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            customerNameLabel.topAnchor.constraint(equalTo: dueDateLabel.bottomAnchor, constant: 8),
            customerNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            customerNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            customerNameLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -40), // Increased bottom space for delete button
            
            deleteButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            deleteButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            deleteButton.widthAnchor.constraint(equalToConstant: 30),
            deleteButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }

    // --- Configuration ---
    func configure(with order: Order) {
        orderNumberLabel.text = "Order \(order.orderNumber ?? "Unknown")"
        
        if let dueDate = order.dueDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dueDateLabel.text = "📅 Due: \(formatter.string(from: dueDate))"
        } else {
            dueDateLabel.text = "Due: Not specified"
        }
        
        customerNameLabel.text = "👤 \(order.buyerName ?? "Unknown")"
        totalLabel.text = "₹\(String(format: "%.2f", order.total))"
    }

    // Prepare for reuse (reset content)
    override func prepareForReuse() {
        super.prepareForReuse()
        orderNumberLabel.text = nil
        customerNameLabel.text = nil
        dueDateLabel.text = nil
        dueDateLabel.textColor = .secondaryLabel // Reset color
        totalLabel.text = nil
        onDelete = nil
    }
}
