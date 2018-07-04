//
//  ClientService.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 4..
//  Copyright © 2018년 ncode. All rights reserved.
//

import Tibei
import RxSwift
import RxCocoa

class ClientService: Disposable {

    private var client: ClientMessenger!
    private var connectedId: ConnectionID?

    let messages = PublishSubject<RemotimerMessage>()
    let connected = BehaviorRelay<Bool>(value: false)

    init() {
        client = ClientMessenger()
    }

    func connectService(serviceName: String) {
        client.registerResponder(self)
        client.browseForServices(withIdentifier: serviceName)
    }

    func disconnectService() {
        client.unregisterResponder(self)
        client.disconnect()
    }

    func dispose() {
        disconnectService()
        messages.onCompleted()
        client = nil
    }

    func sendMessage(command: RemotimerMessage) {
        do {
            try client.sendMessage(command)
        } catch let e {
            print(e)
        }
    }
}

// MARK:- ClientConnectionResponder

extension ClientService: ClientConnectionResponder {

    func availableServicesChanged(availableServiceIDs: [String]) {
        do {
            if let connectableId = availableServiceIDs.first {
                try client.connect(serviceName: connectableId)

            } else if let connectionID = self.connectedId {
                lostConnection(withID: connectionID)
            }
        } catch let e {
            print(e)
        }
    }

    var allowedMessages: [JSONConvertibleMessage.Type] {
        return [RemotimerMessage.self]
    }

    func processMessage(_ message: JSONConvertibleMessage,
                        fromConnectionWithID connectionID: ConnectionID) {
        if let command = message as? RemotimerMessage {
            messages.onNext(command)
        }
    }

    func acceptedConnection(withID connectionID: ConnectionID) {
        self.connectedId = connectionID
        connected.accept(true)
    }

    func lostConnection(withID connectionID: ConnectionID) {
        self.connectedId = nil
        connected.accept(false)
    }

}
