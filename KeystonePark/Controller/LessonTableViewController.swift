//
//  LessonTableViewController.swift
//  KeystonePark
//
//  Created by Patel, Vandan (ETW - FLEX) on 11/9/18.
//  Copyright © 2018 Patel, Vandan (ETW - FLEX). All rights reserved.
//

import UIKit
import CoreData

class LessonTableViewController: UITableViewController {

    var moc: NSManagedObjectContext? {
        didSet {
            if let moc = moc {
                lessonService = LessonService(moc: moc)
            }
        }
    }

    private var lessonService: LessonService?
    private var studentsList = [Student]()
    private var studentToUpdate: Student?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudents()
    }

    @IBAction func addStudentAction(_ sender: UIBarButtonItem) {
        present(alertController(actionType: "Add"), animated: true, completion: nil)
    }
    

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return studentsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentCell", for: indexPath)

        cell.textLabel?.text = studentsList[indexPath.row].name
        cell.detailTextLabel?.text = studentsList[indexPath.row].lesson?.type
        return cell
    }

    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        studentToUpdate = studentsList[indexPath.row]
        present(alertController(actionType: "update"), animated: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            lessonService?.delete(student: studentsList[indexPath.row])
            studentsList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

    // MARK: - Private
    private func alertController(actionType: String) -> UIAlertController {
        let alertController = UIAlertController(title: "Keystone Park Lesson",
                                                message: "Student Info",
                                                preferredStyle: .alert)
        alertController.addTextField { [weak self] (textField) in
            textField.placeholder = "Name"
            textField.text = self?.studentToUpdate == nil ? "" : self?.studentToUpdate?.name
        }

        alertController.addTextField { [weak self] (textField) in
            textField.placeholder = "Lesson Type: Ski | Snowboard"
            textField.text = self?.studentToUpdate == nil ? "" : self?.studentToUpdate?.lesson?.type
        }

        let defaultAction = UIAlertAction(title: actionType.uppercased(),
                                          style: .default) { [weak self] (action) in
            guard
                let studentName = alertController.textFields?.first?.text,
                let lesson = alertController.textFields?.last?.text
                else { return }

                if actionType.caseInsensitiveCompare("add") == .orderedSame {
                    if let lessonType = LessonType(rawValue: lesson.lowercased()) {
                        self?.lessonService?.addStudent(name: studentName, for: lessonType, completion: { (success, students) in
                            if success {
                                self?.studentsList = students
                            }
                        })
                    }
                } else {
                    guard let name = alertController.textFields?.first?.text, !name.isEmpty,
                    let studentToUpdate = self?.studentToUpdate,
                        let lessonType = alertController.textFields?.last?.text, !lessonType.isEmpty else {
                            return
                    }
                    self?.lessonService?.update(currentStudent: studentToUpdate, withName: name, forLesson: lessonType)
                    self?.studentToUpdate = nil
                }
                DispatchQueue.main.async {
                    self?.loadStudents()
                }
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { [weak self] (action) in
            self?.studentToUpdate = nil
        }

        alertController.addAction(defaultAction)
        alertController.addAction(cancelAction)

        return alertController
    }

    private func loadStudents() {
        if let students = lessonService?.getAllStudents() {
            studentsList = students
            tableView.reloadData()
        }
    }

}
