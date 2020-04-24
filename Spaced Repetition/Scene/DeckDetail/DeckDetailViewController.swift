//
//  DeckDetailViewController.swift
//  Spaced Repetition
//
//  Created by Kevin Vu on 4/3/20.
//  Copyright (c) 2020 An Nguyen. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

// MARK: Display Logic protocol
protocol DeckDetailDisplayLogic: class
{
    func displayDeckName(viewModel: DeckDetail.ShowDeck.ViewModel.DeckInfoModel)
    func displayDeckCards(viewModel: DeckDetail.ShowDeck.ViewModel.DeckCardModels)
    
    func displayCreatedCard(viewModel: DeckDetail.CreateCard.ViewModel)
    func displayEditedDeckTitle(viewModel: DeckDetail.ShowEditTitleAlert.ViewModel)
}


// MARK: AlertDisplayable protocol
public protocol AlertDisplayableViewController {
    func displayAlert(viewModel: AlertDisplayable.ViewModel)
}

extension AlertDisplayableViewController where Self: UIViewController {
    public func displayAlert(viewModel: AlertDisplayable.ViewModel) {
        let vc = UIAlertController(title: viewModel.title, message: viewModel.message, preferredStyle: .alert)
        
        viewModel.textFields.forEach { (alertTextField) in
            vc.addTextField { (textField) in
                textField.placeholder = alertTextField.placeholder
            }
        }
        
        viewModel.actions.forEach { action in
            vc.addAction(UIAlertAction(title: action.title, style: action.style, handler: { actionIgnore in
                guard let handler = action.handler else { return }
                /*
                 we call the action's handler here if it has one
                 
                 we don't really need the alert action parameter but it requires it
                 so we pass one in anyway - the important one is the vc/alertcontroller
                 since we need to access the alert controller's textfields property
                 
                 then, we can access the alert controller's textfields property
                 wherever we declared the handler (i.e. the interactor in this case)
                 */
                
                handler(actionIgnore, vc)
            }))
        }
        present(vc, animated: true, completion: nil)
    }
}


// MARK: - DeckDetailVC
class DeckDetailViewController: UIViewController, DeckDetailDisplayLogic, AlertDisplayableViewController
{
    
    // MARK: Properties
    
    var interactor: DeckDetailBusinessLogic?
    var router: (NSObjectProtocol & DeckDetailRoutingLogic & DeckDetailDataPassing)?
    var contentView: DeckDetailView!

    // MARK: Object lifecycle
  
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
  
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
  
    // MARK: Setup
  
    private func setup()
    {
        let viewController = self
        let interactor = DeckDetailInteractor(factory: DependencyContainer())
        let presenter = DeckDetailPresenter()
        let router = DeckDetailRouter()
        let view = DeckDetailView()
        
        viewController.interactor = interactor
        viewController.router = router
        viewController.contentView = view
        interactor.presenter = presenter
        presenter.viewController = viewController
        presenter.alertDisplayableViewController = viewController
        router.viewController = viewController
        router.dataStore = interactor
        view.delegate = interactor
    }
    
    private func configureNavBar() {
        navigationItem.largeTitleDisplayMode = .automatic
        // replace title with a barbuttonitem to edit deck name
        navigationItem.title = "Untitled Deck"
        
        
        let plusImage = UIImage(systemName: "plus.rectangle")
        let addCardBarButton = UIBarButtonItem(image: plusImage, style: .done, target: self, action: #selector(handleAddCardButton))
//        let editImage = UIImage(systemName: "pencil.circle.fill")
//        let editDeckTitleButton = UIBarButtonItem(image: editImage, style: .done, target: self, action: #selector(didTapEditTitleButton))
        let editDeckTitleButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(didTapEditTitleButton))
        
        navigationItem.rightBarButtonItems = [addCardBarButton, editDeckTitleButton]
        
        // TODO: to be used for converting the title view into a tappable view for
        // editing deck title?
//        navigationItem.titleView?.addGestureRecognizer(navBarTitleTapRecognizer)
//        navigationItem.titleView?.layer.borderWidth = 1.0
//        navigationItem.titleView?.layer.borderColor = UIColor.black.cgColor
    }
    
    
    
    private func configureCollectionDataSource() {
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
    }
  
  // MARK: Routing
  
    
    
  // MARK: View lifecycle
    
    override func loadView() {
        super.loadView()
        view = contentView
    }
      
    override func viewDidLoad()
    {
        super.viewDidLoad()
        configureCollectionDataSource()
        configureNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDeck()
    }
    
    // MARK: Get Deck
    
    func getDeck() {
        let request = DeckDetail.ShowDeck.Request()
        interactor?.getDeck(request: request)
    }

    // MARK: Display Logic
    
    // should viewcontroller hold deckID like this?
    // could use name to filter when creating a card but has issue if user has
    // multiple decks with the same deck name
    var displayedDeckID: UUID?
    
    func displayDeckName(viewModel: DeckDetail.ShowDeck.ViewModel.DeckInfoModel) {
        navigationItem.title = viewModel.displayedDeckName
        displayedDeckID = viewModel.displayedDeckID
    }
    
    var displayedDeckCards: [DeckDetailCollectionViewCell.CardCellModel]?
    
    func displayDeckCards(viewModel: DeckDetail.ShowDeck.ViewModel.DeckCardModels) {
        displayedDeckCards = viewModel.displayedCards
        contentView.collectionView.reloadData()
    }
    
    func displayCreatedCard(viewModel: DeckDetail.CreateCard.ViewModel) {
        displayedDeckCards?.append(viewModel.displayedCard)
        contentView.collectionView.reloadData()
    }
    
    func displayEditedDeckTitle(viewModel: DeckDetail.ShowEditTitleAlert.ViewModel) {
        navigationItem.title = viewModel.newDeckTitle
    }
    
    // MARK: Button methods
    
    @objc func handleAddCardButton() {
        guard let displayedDeckID = displayedDeckID else { return }
        let request = DeckDetail.ShowCreateCard.Request(displayedDeckID: displayedDeckID)
        
        interactor?.showCreateCard(request: request)
    }
    
    @objc func didTapEditTitleButton() {
        // TODO: Allow user to change deck title
        // 1) Display alert controller with one text field,
        // 2) Submit request with the text from the text field
        // 3) Change deck title
        guard let displayedDeckID = displayedDeckID else { return }
        let request = DeckDetail.ShowEditTitleAlert.Request(deckID: displayedDeckID)
        interactor?.showEditTitleAlert(request: request)
    }

}

// MARK: - Collection view methods

extension DeckDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let displayedDeckCards = displayedDeckCards else { return 0 }
        return displayedDeckCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: DeckDetailCollectionViewCell.identifier, for: indexPath) as! DeckDetailCollectionViewCell
        
        guard let displayedDeckCards = displayedDeckCards else { return cell }
        cell.configureWithModel(displayedDeckCards[indexPath.row])
        cell.delegate = self
        
        // use this if you want to use a callback variable instead
//        cell.didTapDeleteButton = {
//            print("Test")
//            return
//        }
        
        return cell
    }

    /*
     TODO: Remove or configure such that tapping allows editing
     */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped collection view cell: \(indexPath.row)")

    }
    
}


// MARK: - DeckDetailCollectionCellDelegate
protocol DeckDetailCollectionCellDelegate: class {
    func deleteButtonTapped()
}

extension DeckDetailViewController: DeckDetailCollectionCellDelegate {
    // TODO: implement delete card
    func deleteButtonTapped() {
        print("Delete button tapped")
    }
}
