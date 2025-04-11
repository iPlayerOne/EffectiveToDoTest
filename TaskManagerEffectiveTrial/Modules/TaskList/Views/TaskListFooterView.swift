import Foundation
import UIKit

final class TaskListFooterView: UIView {
    private let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 13)
        return label
    }()
    
    private let createButton: UIButton = {
        var config = UIButton.Configuration.plain()
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        let image = UIImage(systemName: "square.and.pencil")?.withConfiguration(symbolConfig)
        
        config.image = image
        config.baseForegroundColor = .systemYellow
        
        let button = UIButton(configuration: config, primaryAction: nil)
        
        return button
    }()
    
    private let stack = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .secondarySystemBackground
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        addSubview(countLabel)
        addSubview(createButton)
        
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        createButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            countLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            countLabel.centerYAnchor.constraint(equalTo: createButton.centerYAnchor),
            
            createButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            createButton.bottomAnchor.constraint(equalTo:  safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    func updateCount(_ count: Int) {
        countLabel.text = "\(count) задач"
    }
    
    func onCreateTapped(_ action: @escaping () -> Void) {
        createButton.addAction(UIAction(handler: { _ in action() }), for: .touchUpInside)
    }
}
