/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

class ViewController: UIViewController {

  // MARK: - IBOutlets
  @IBOutlet var toDoListCollectionView: UICollectionView!
  @IBOutlet var warriorPath: UIView!
  @IBOutlet var warriorCatImageView: UIImageView!

  // MARK: - Properties
  var toDos: [ToDo] = []
  var completedToDos: [ToDo] = []

  // MARK: - View Life Cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    toDoListCollectionView.register(UINib(nibName: "ToDoCell", bundle: nil),
                                    forCellWithReuseIdentifier: "cell")
    setWarriorPosition()
  }
}

// MARK: - IBActions
extension ViewController {

  @IBAction func addToDo(_ sender: UIBarButtonItem) {
    let alertController = UIAlertController(title: "Create Task",
                                            message: "What kind of task would you like to create?",
                                            preferredStyle: .alert)

    alertController.addAction(UIAlertAction(title: "Task without Checklist", style: .default) { [weak self] action in
      self?.createDefaultTask()
    })
		
		alertController.addAction(UIAlertAction(title: "Task with Checklist", style: .default, handler: { [weak self](action) in
				self?.createTaskWithChecklist()
			}))

    present(alertController, animated: true)
  }
}

// MARK: - Internal
extension ViewController {

  func setWarriorPosition() {
    var percentageComplete = 0.0
    let completed = Double(completedToDos.count)
    let all = Double(toDos.count)
    
    if !completedToDos.isEmpty {
      percentageComplete = completed / all
    }
    
    let x = warriorPath.frame.width * CGFloat(percentageComplete)
    
    warriorCatImageView.frame = CGRect(x: x,
                                       y: warriorPath.frame.midY - 50,
                                       width: 100,
                                       height: 100)
  }

  func createDefaultTask() {
    let alertController = UIAlertController(title: "Task Name",
                                            message: "",
                                            preferredStyle: .alert)
    
    alertController.addTextField { textField in
      textField.placeholder = "Enter Task Title"
    }
    
    let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] alert in
      let titleTextField = alertController.textFields![0]
      
      if titleTextField.text != "" {
        let currentToDo = ToDoItem(name: titleTextField.text!)
				self?.toDos.append(currentToDo)
        self?.toDoListCollectionView.reloadData()
        self?.setWarriorPosition()
      }
    }
    
    let cancelAction = UIAlertAction(title: "Cancel", style: .default)
    
    alertController.addAction(saveAction)
    alertController.addAction(cancelAction)
    
    present(alertController, animated: true)
  }
	
	func createTaskWithChecklist() {
		let alertController = UIAlertController(title: "Task Name", message: "", preferredStyle: .alert)
		alertController.addTextField { (textField) in
			textField.placeholder = "Enter Task Title"
		}
		
		for _ in 1...4 {
			alertController.addTextField { (textField) in
				textField.placeholder = "Add Subtask"
			}
		}
		
		let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self](alert) in
			let titleTextField = alertController.textFields![0]
			let firstTextField = alertController.textFields![1]
			let secondTextField = alertController.textFields![2]
			let thirdTextField = alertController.textFields![3]
			let fourthTextField = alertController.textFields![4]
			
			let textFields = [firstTextField, secondTextField, thirdTextField, fourthTextField]
			var subtasks: [ToDo] = []
			
			for textField in textFields {
				if textField.text != "" {
					let currentSubtask = ToDoItem(name: textField.text!)
					subtasks.append(currentSubtask)
				}
			}
			
			let currentToDo = ToDoItemWithCheckList(name: titleTextField.text!, subtasks: subtasks)
			self?.toDos.append(currentToDo)
			self?.toDoListCollectionView.reloadData()
			self?.setWarriorPosition()
			
		}
		
		let cancelAction = UIAlertAction(title: "Cancel", style: .default)
		alertController.addAction(saveAction)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true)
		
	}
	
}

// MARK: - UICollectionViewDataSource
extension ViewController: UICollectionViewDataSource {

  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return toDos.count
  }

  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ToDoCell

    let currentToDo = toDos[indexPath.row]

    cell.toDoLabel.text = currentToDo.name

    if currentToDo.isComplete {
      cell.checkBoxView.backgroundColor = UIColor(red:0.24, green:0.56, blue:0.30, alpha:1.0)
    } else {
      cell.checkBoxView.backgroundColor = UIColor.white
    }

    cell.layoutSubviews()
		
		if currentToDo is ToDoItemWithCheckList {
			cell.subtasks = currentToDo.subtasks as! [ToDoItem]///////
		}
		
    return cell
  }
}

// MARK: - UICollectionViewDelegate
extension ViewController: UICollectionViewDelegate {

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    var currentToDo = toDos[indexPath.row]

    if currentToDo.isComplete {
      currentToDo.isComplete = false
      completedToDos = completedToDos.filter { $0.name != currentToDo.name }
    } else {
      currentToDo.isComplete = true
      completedToDos.append(currentToDo)
    }

    setWarriorPosition()
    collectionView.reloadData()
  }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension ViewController: UICollectionViewDelegateFlowLayout {

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    let width = collectionView.frame.width    
//    let height = collectionView.frame.height * 0.15
		
		let currentTodo = toDos[indexPath.row]
		
		let heightVariance = 60 * (currentTodo.subtasks.count)
		let addedHeight = CGFloat(heightVariance)
		
		let height = collectionView.frame.height * 0.15 + addedHeight
		
    return CGSize(width: width, height: height)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
  
  func collectionView(_ collectionView: UICollectionView, layout
    collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 0.0
  }
}
