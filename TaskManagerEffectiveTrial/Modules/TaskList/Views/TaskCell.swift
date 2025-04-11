import Foundation
import UIKit

protocol TaskCellDelegate: AnyObject {
    func taskCell(_ cell: TaskCell, didToggleIsCompletionFor task: TaskListEntity)
}
final class TaskCell: UITableViewCell {
    static let reusedID = "TaskCell"
    
    weak var delegate: TaskCellDelegate?
    private var task: TaskListEntity?
    
    
    private let statusButton: UIButton = {
        let button = UIButton(type: .custom)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemGray.cgColor
        button.backgroundColor = .clear
        button.tintColor = .systemYellow
        return button
    }()
    
    private let checkmarkView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .systemYellow
        imageView.alpha = 0
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .label
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .label
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .tertiaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configureCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        statusButton.layer.cornerRadius = statusButton.bounds.height / 2
        statusButton.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.attributedText = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        dateLabel.text = nil
        checkmarkView.alpha = 0
        statusButton.layer.borderColor = UIColor.systemGray.cgColor
    }
    
    
    func configure(with task: TaskListEntity) {
        self.task = task
        titleLabel.text = task.title
        subtitleLabel.text = task.details
        dateLabel.text = task.date
        
        let attributes: [NSAttributedString.Key: Any] = task.isCompleted
        ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
           .foregroundColor: UIColor.secondaryLabel]
        : [.foregroundColor: UIColor.label]
        titleLabel.attributedText = NSAttributedString(string: task.title, attributes: attributes)
        subtitleLabel.textColor = task.isCompleted ? .secondaryLabel : .label
        statusButton.layer.borderColor = (task.isCompleted ? UIColor.systemYellow : UIColor.systemGray).cgColor
        
        checkmarkView.alpha = task.isCompleted ? 1.0 : 0.0
    }
    
    @objc private func didTapStatusButton() {
        guard let task else { return }
        delegate?.taskCell(self, didToggleIsCompletionFor: task)
        animateCheckmark(task.isCompleted)
        animateTextTransition(task.isCompleted)
    }

    private func configureCell() {
        selectionStyle = .none
        backgroundColor = .systemBackground

        
        contentView.addSubview(statusButton)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(dateLabel)
        
        statusButton.addSubview(checkmarkView)
        
        statusButton.addTarget(self, action: #selector(didTapStatusButton), for: .touchUpInside)
        setupConstraints()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            statusButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            statusButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            statusButton.widthAnchor.constraint(equalToConstant: 24),
            statusButton.heightAnchor.constraint(equalToConstant: 24)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: statusButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        NSLayoutConstraint.activate([
            checkmarkView.centerXAnchor.constraint(equalTo: statusButton.centerXAnchor),
            checkmarkView.centerYAnchor.constraint(equalTo: statusButton.centerYAnchor),
            checkmarkView.widthAnchor.constraint(equalToConstant: 14),
            checkmarkView.heightAnchor.constraint(equalToConstant: 14)
        ])
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            subtitleLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            dateLabel.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func animateCheckmark(_ completed: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.checkmarkView.alpha = completed ? 1.0 : 0.0
            self.statusButton.layer.borderColor = (completed ? UIColor.systemYellow : UIColor.systemGray).cgColor
        }
    }
    
    private func animateTextTransition(_ completed: Bool) {
        UIView.transition(with: titleLabel, duration: 0.25, options: .transitionCrossDissolve) {
            let attributes: [NSAttributedString.Key: Any] = completed
                ? [.strikethroughStyle: NSUnderlineStyle.single.rawValue,
                   .foregroundColor: UIColor.secondaryLabel]
                : [.foregroundColor: UIColor.label]
            self.titleLabel.attributedText = NSAttributedString(string: self.task?.title ?? "", attributes: attributes)
        }
        
        UIView.transition(with: subtitleLabel, duration: 0.25, options: .transitionCrossDissolve) {
            self.subtitleLabel.textColor = completed ? .secondaryLabel : .label
        }
    }
}

