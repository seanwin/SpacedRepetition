//
//  DeckDetailInteractor.swift
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

protocol DeckDetailBusinessLogic
{
    func getDeck(request: DeckDetail.ShowDeck.Request)
    
//    func createCard(request: DeckDetail.CreateCard.Request)
    
    func showCreateCard(request: DeckDetail.ShowCreateCard.Request)
    
    func showEditTitleAlert(request: DeckDetail.ShowEditTitleAlert.Request)
}

protocol DeckDetailDataStore
{
    var deckInfo: Deck? { get set }
}

class DeckDetailInteractor: DeckDetailBusinessLogic, DeckDetailDataStore
{
    // MARK: Properties
    typealias Factory = DecksWorkerFactory
    var presenter: DeckDetailPresentationLogic?
    var decksWorker: DecksWorkerProtocol
    
    var deckInfo: Deck?
    
    // MARK: Initialization
    
    // pass in a factory, likely a dependency container that has an extension
    // that conforms to the DecksWorkerFactory protocol to make a decks worker
    init(factory: Factory) {
        self.decksWorker = factory.makeDecksWorker()
    }
  
    
    // MARK: Get Deck
    func getDeck(request: DeckDetail.ShowDeck.Request) {
        guard let deckInfo = deckInfo else {
            assertionFailure("No deck info available")
            return
        }
        
        let response = DeckDetail.ShowDeck.Response(deck: deckInfo)
        presenter?.presentDeck(response: response)
    }
    
    
    // MARK: Create Card
//    func createCard(request: DeckDetail.CreateCard.Request) {
//        let cardToCreate = Card(frontSide: request.frontSideText, backSide: request.backSideText)
//        decksWorker.createCard(forDeckID: request.deckID, card: cardToCreate)
//        
//        let response = DeckDetail.CreateCard.Response(card: cardToCreate)
//        presenter?.presentCard(response: response)
//    }
    
    
    // MARK: Show Create Card Alert
    func showCreateCard(request: DeckDetail.ShowCreateCard.Request) {
        let frontTextField = AlertDisplayable.TextField(placeholder: "Front side of Card")
        let backTextField = AlertDisplayable.TextField(placeholder: "Back side of card")
        let displayedDeckID = request.displayedDeckID

        let cancelAction = AlertDisplayable.Action(title: "Cancel", style: .cancel, handler: nil)
        // note: the handler here can be called wherever/whenever we want
        // as long as we pass in a UIAlertAction and UIAlertController
        let saveAction = AlertDisplayable.Action(title: "Done", style: .default) { [weak self] (action, vc) in
            guard let self = self else { return }
            guard let frontSideText = vc.textFields?[0].text, !frontSideText.isEmpty else { return }
            guard let backSideText = vc.textFields?[1].text, !backSideText.isEmpty else { return }
            
            // should we abstract this into a separate function? we have one above
            // (the createCard(request:) function, but it is kinda weird to
            // call an interactor function within the interactor
            let cardToCreate = Card(frontSide: frontSideText, backSide: backSideText)
            self.decksWorker.createCard(forDeckID: displayedDeckID, card: cardToCreate)
            
            // TODO: Save card
            
            let response = DeckDetail.CreateCard.Response(card: cardToCreate)
            self.presenter?.presentCard(response: response)
        }
        
        
        
        let viewModel = AlertDisplayable.ViewModel(title: "New Card", message: "Please enter card details", textFields: [frontTextField, backTextField], actions: [cancelAction, saveAction])
        presenter?.presentAlert(viewModel: viewModel)
    }
    
    // MARK: Show Edit Title Alert
    func showEditTitleAlert(request: DeckDetail.ShowEditTitleAlert.Request) {
        let deckTitleTextField = AlertDisplayable.TextField(placeholder: "New Deck Title")
        let displayedDeckID = request.deckID
        
        let cancelAction = AlertDisplayable.Action(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = AlertDisplayable.Action(title: "Done", style: .default) { [weak self] (action, ac) in
            
            guard let self = self else { return }
            guard let deckTitle = ac.textFields?[0].text else { return }
            
            self.decksWorker.editTitle(forDeckID: displayedDeckID, withNewTitle: deckTitle)
            
            let response = DeckDetail.ShowEditTitleAlert.Response(newDeckTitle: deckTitle)
            self.presenter?.presentEditedDeckTitle(response: response)
            
        }
        
        
        
        let viewModel = AlertDisplayable.ViewModel(title: "Edit Deck title", message: "Please enter new deck title", textFields: [deckTitleTextField], actions: [cancelAction, saveAction])
        presenter?.presentAlert(viewModel: viewModel)
    }
    
}

// MARK: - Delegate methods
extension DeckDetailInteractor: DeckDetailViewDelegate {
    
    func deckDetailViewSelectStudyDeck(request: DeckDetail.StudyDeck.Request) {
        print("tapped study deck button")
    }
    
}
