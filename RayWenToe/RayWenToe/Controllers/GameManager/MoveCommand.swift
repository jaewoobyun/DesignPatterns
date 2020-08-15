//
//  MoveCommand.swift
//  RayWenToe
//
//  Created by 변재우 on 20190403//.
//  Copyright © 2019 Razeware, LLC. All rights reserved.
//

import Foundation


//1
public struct MoveCommand {
	
	//2
	public var gameboard: Gameboard
	
	//3
	public var gameboardView: GameboardView
	
	//4
	public var player: Player
	
	//5
	public var position: GameboardPosition
	
	public func execute(completion: (() -> Void)? = nil) {
		//1
		gameboard.setPlayer(player, at: position)
		
		//2
		gameboardView.placeMarkView(player.markViewPrototype.copy(), at: position, animated: true, completion: completion)
	}
}
