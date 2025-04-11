import UIKit

protocol TaskListView: AnyObject {
    func showTasks(_ tasks: [TaskListEntity])
    func showLoading()
    func hideLoading()
    func showError(_ message: String)
    
}

final class TaskListViewController: UIViewController, TaskListView {
    var presenter: TaskListPresenter?
    let searchController = UISearchController(searchResultsController: nil)
    private var tasks: [TaskListEntity] = []
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private let footerView = TaskListFooterView()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.overrideUserInterfaceStyle = .dark
        setupIndicator()
        setupNavBar()
        setupTableView()
        setupFooter()
        
        presenter?.viewDidLoad()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.register(TaskCell.self, forCellReuseIdentifier: TaskCell.reusedID)
        tableView.backgroundColor = .clear
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.backgroundColor = .systemBackground
        navigationItem.title = "Задачи"
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchResultsUpdater = self
    }
    
    private func setupFooter() {
        view.addSubview(footerView)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerView.heightAnchor.constraint(equalToConstant: 83)
        ])
        
        footerView.updateCount(tasks.count)
        
        footerView.onCreateTapped { [weak self] in
            self?.presenter?.didTapCreate()
        }
    }
    
    private func setupIndicator() {
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func showTasks(_ tasks: [TaskListEntity]) {
        print("Загружено задач: \(tasks.count)")
        self.tasks = tasks
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.footerView.updateCount(tasks.count)
        }
    }
    
    func showLoading() {
        activityIndicator.startAnimating()
    }
    
    func hideLoading() {
        activityIndicator.stopAnimating()
    }
    
    func showError(_ message: String) {
        print("Ошибка: \(message)")
    }
}

extension TaskListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TaskCell.reusedID, for: indexPath) as? TaskCell else {
            return UITableViewCell()
        }
        let task = tasks[indexPath.row]
        cell.delegate = self
        cell.configure(with: task)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let task = tasks[indexPath.row]
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: { return nil}) { _ in
            TaskContextMenuFactory.makeMenu(for: task, presenter: self.presenter, presenterVC: self)
        }
    }
    
}

extension TaskListViewController: TaskCellDelegate {
    func taskCell(_ cell: TaskCell, didToggleIsCompletionFor task: TaskListEntity) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        presenter?.toggleTaskCompletion(for: tasks[indexPath.row])
        
        DispatchQueue.main.async {
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }
}

extension TaskListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        presenter?.didUpdateSearchQuery(searchController.searchBar.text ?? "")
    }
    
    
}
