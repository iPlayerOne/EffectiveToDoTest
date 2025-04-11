import Foundation
import UIKit

protocol TaskEditView: AnyObject {
    func showTask(_ task: TaskListEntity?)
    func showError(_ message: String)
    func close()
}

final class TaskEditViewController: UIViewController, TaskEditView, UITextViewDelegate {

    var presenter: TaskEditPresenter?

    private let titleField: UITextField = {
        let field = UITextField()
        field.placeholder = "Задача"
        field.font = .systemFont(ofSize: 34, weight: .bold)
        field.textColor = .label
        field.autocorrectionType = .no
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()

    private let detailsView: UITextView = {
        let textView = UITextView()
        textView.font = .systemFont(ofSize: 16)
        textView.textColor = .label
        textView.backgroundColor = .systemBackground
        textView.autocorrectionType = .no
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.heightTracksTextView = true
        return textView
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        detailsView.delegate = self
        setupLayout()
        presenter?.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
            backButton.setTitle("Назад", for: .normal)
            backButton.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            backButton.tintColor = .systemYellow
            backButton.sizeToFit()
            
            backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

            let barButtonItem = UIBarButtonItem(customView: backButton)
            navigationItem.leftBarButtonItem = barButtonItem
    }


    func showTask(_ task: TaskListEntity?) {
        titleField.text = task?.title
        detailsView.text = task?.details
        dateLabel.text = task?.date
    }

    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ок", style: .default))
        present(alert, animated: true)
    }

    func close() {
        navigationController?.popViewController(animated: true)
    }

    private func setupLayout() {
        view.addSubview(titleField)
        view.addSubview(dateLabel)
        view.addSubview(detailsView)

        NSLayoutConstraint.activate([
            titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            titleField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),

            detailsView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            detailsView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
            detailsView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
            detailsView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    @objc private func didTapBack() {
        presenter?.didTapBack(
            title: titleField.text,
            details: detailsView.text
        )
    }

    func populate(title: String, description: String?) {
        titleField.text = title
        detailsView.text = description
    }
}
