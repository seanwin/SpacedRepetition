//
//  DeckDetailModels.swift
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

enum DeckDetail
{
  // MARK: Use cases
    
    enum ShowDeck {
        struct Request {
            
        }
        struct Response {
            let deck: Deck
        }
        enum ViewModel {
            struct DeckNameModel {
                let displayedDeckName: String
            }
            struct DeckCardModels {
                let displayedCards: [DeckDetailCollectionViewCell.CardCellModel]
            }
        }
        
    }
    
    // used to show/present the alert controller to prompt users to enter the card they want
    enum ShowCreateCard {
        struct Request {
            
        }
        struct Response {
            
        }
        struct ViewModel {
            let acTitle: String
        }
    }
    // this use case should show a UIAlertController
    // do I show the UIAlertController from the view controller directly and then pass that data through the VIP cycle or should I handle the add/create card button tap through the VIP cycle first to present the UIAlertController and then when the UIAlertController is finished, pass that data through the VIP cycle?
    // always go through VIP, handleAddCardButton will go to interactor -> presenter -> VC
    // interactor should provide a variable block that gets passed through VIP (like a var didFinishCreatingCard = {}) and then when it is finished, call the block to go back to screen?
    enum CreateCard {
        struct Request {
            
        }
        struct Response {
            let card: Card
        }
        struct ViewModel {
            let displayedCard: DeckDetailCollectionViewCell.CardCellModel
        }
    }
    
    enum StudyDeck {
        struct Request {
            
        }
        struct Response {
            
        }
        struct ViewModel {
            
        }
    }
}
