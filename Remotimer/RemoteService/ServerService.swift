//
//  ServerService.swift
//  Remotimer
//
//  Created by iamchiwon on 2018. 7. 4..
//  Copyright © 2018년 ncode. All rights reserved.
//

import Tibei
import RxSwift
import RxCocoa

class ServerService: Disposable {

    private var server: ServerMessenger!

    let messages = PublishSubject<RemotimerMessage>()
    let accepted = PublishSubject<ConnectionID>()
    let lost = PublishSubject<ConnectionID>()
    let clients = BehaviorRelay<[ConnectionID]>(value: [])

    init(serviceName: String) {
        server = ServerMessenger(serviceIdentifier: serviceName)
    }

    func startServer() {
        server.registerResponder(self)
        server.publishService()
    }

    func stopServer() {
        server.unregisterResponder(self)
        server.unpublishService()
    }

    func dispose() {
        stopServer()
        accepted.onCompleted()
        lost.onCompleted()
        messages.onCompleted()
        server = nil
    }

    func sendMessage(command: RemotimerMessage, connectionId: ConnectionID) {
        guard clients.value.filter({ id in id == connectionId }).count > 0 else { return }
        do {
            try server.sendMessage(command, toConnectionWithID: connectionId)
        } catch let e {
            print(e)
        }
    }

    func broadcast(command: RemotimerMessage) {
        clients.value.forEach({ id in
            do {
                try server.sendMessage(command, toConnectionWithID: id)
            } catch let e {
                print(e)
            }
        })
    }
}

// MARK:- ConnectionResponder

extension ServerService: ConnectionResponder {

    var allowedMessages: [JSONConvertibleMessage.Type] {
        return [RemotimerMessage.self]
    }

    func processMessage(_ message: JSONConvertibleMessage, fromConnectionWithID connectionID: ConnectionID) {
        if let command = message as? RemotimerMessage {
            messages.onNext(command)
        }
    }

    func acceptedConnection(withID connectionID: ConnectionID) {
        var appended = clients.value
        appended.append(connectionID)
        clients.accept(appended)
        accepted.onNext(connectionID)
    }

    func lostConnection(withID connectionID: ConnectionID) {
        let removed = clients.value.filter({ id in connectionID != id })
        clients.accept(removed)
        lost.onNext(connectionID)
    }

    func processError(_ error: Error, fromConnectionWithID connectionID: ConnectionID?) {
        messages.onError(error)
    }
}
