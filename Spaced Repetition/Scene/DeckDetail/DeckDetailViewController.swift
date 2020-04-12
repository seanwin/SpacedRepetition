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

protocol DeckDetailDisplayLogic: class
{
    func displayDeck(viewModel: DeckDetail.ShowDeck.ViewModel)
}

class DeckDetailViewController: UIViewController, DeckDetailDisplayLogic
{
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
    let interactor = DeckDetailInteractor()
    let presenter = DeckDetailPresenter()
    let router = DeckDetailRouter()
    let view = DeckDetailView()
    
    viewController.interactor = interactor
    viewController.router = router
    viewController.contentView = view
    interactor.presenter = presenter
    presenter.viewController = viewController
    router.viewController = viewController
    router.dataStore = interactor
  }
  
  // MARK: Routing
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?)
  {
    if let scene = segue.identifier {
      let selector = NSSelectorFromString("routeTo\(scene)WithSegue:")
      if let router = router, router.responds(to: selector) {
        router.perform(selector, with: segue)
      }
    }
  }
  
  // MARK: View lifecycle
    
    override func loadView() {
        view = contentView
    }
      
    override func viewDidLoad()
    {
        super.viewDidLoad()
        contentView.collectionView.delegate = self
        contentView.collectionView.dataSource = self
        navigationItem.largeTitleDisplayMode = .automatic
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "+ Card", style: .done, target: self, action: #selector(handleAddCardButton))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getDeck()
        navigationItem.title = displayedDeckName
    }

    // MARK: Display Deck
    
    var displayedDeckName: String = "Untitled Deck"
    var displayedDeckCards: [Card] = []
    
    func displayDeck(viewModel: DeckDetail.ShowDeck.ViewModel) {
        displayedDeckName = viewModel.displayedDeck.nameOfDeck
        displayedDeckCards = viewModel.displayedDeck.cards
    }
    
    // MARK: Get Deck when view appears
    
    func getDeck() {
        let request = DeckDetail.ShowDeck.Request()
        interactor?.getDeck(request: request)
    }
    
    @objc func handleAddCardButton() {
        let request = DeckDetail.CreateCard.Request()
        interactor?.createCard(request: request)
    }

}

// MARK: - Collection view methods

extension DeckDetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 380, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayedDeckCards.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "deckDetailCell", for: indexPath)
        
        let frontLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 30))
            label.text = displayedDeckCards[indexPath.row].frontSide
            
            return label
        }()
        
        let backLabel: UILabel = {
            let label = UILabel(frame: CGRect(x: 20, y: 60, width: 300, height: 30))
            label.text = displayedDeckCards[indexPath.row].backSide
            
            return label
        }()
        
        cell.addSubview(frontLabel)
        cell.addSubview(backLabel)
        cell.backgroundColor = .red
        return cell
    }

    // REMOVE WHEN FINISHED WITH CONFIGURATION
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Tapped collection view cell: \(indexPath.row)")
    }
    
}
