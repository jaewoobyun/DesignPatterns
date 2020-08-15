//
//  ShareFacade.swift
//  MirrorPad
//
//  Created by 변재우 on 20190401//.
//  Copyright © 2019 Razeware, LLC. All rights reserved.
//

import Foundation
import UIKit

public class ShareFacade {
	
	// MARK: - Instance Properties
	//1
	public unowned var entireDrawing: UIView
	public unowned var inputDrawing: UIView
	public unowned var parentViewController: UIViewController
	
	//2
	private var imageRenderer = ImageRenderer()
	
	// MARK: - Object Lifecycle
	//3
	public init(entireDrawing: UIView, inputDrawing: UIView, parentViewController: UIViewController) {
		self.entireDrawing = entireDrawing
		self.inputDrawing = inputDrawing
		self.parentViewController = parentViewController
	}
	
	// MARK: - Facade Methods
	//4
	public func presentShareController() {
		//1
		let selectionViewController = DrawingSelectionViewController.createInstance(entireDrawing: entireDrawing, inputDrawing: inputDrawing, delegate: self)
		
		//2
		parentViewController.present(selectionViewController, animated: true, completion: nil)
	}
	
}


// MARK: - DrawingSelectionViewControllerDelegate
extension ShareFacade: DrawingSelectionViewControllerDelegate {
	
	//1
	public func drawingSelectionViewControllerDidCancel(_ viewController: DrawingSelectionViewController) {
		parentViewController.dismiss(animated: true, completion: nil)
	}
	
	//2
	public func drawingSelectionViewController(_ viewController: DrawingSelectionViewController, didSelectView view: UIView) {
		parentViewController.dismiss(animated: false, completion: nil)
		let image = imageRenderer.convertViewToImage(view)
		
		let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
		
		parentViewController.present(activityViewController, animated: true, completion: nil)
	}

}
