//
//  DecryptionHandlerProtocol.swift
//  RWSecret
//
//  Created by 변재우 on 20190404//.
//  Copyright © 2019 Joshua Greene. All rights reserved.
//

import Foundation

public protocol DecryptionHandlerProtocol {
	var next: DecryptionHandlerProtocol? { get }
	func decrypt(data encryptedData: Data) -> String?
}
