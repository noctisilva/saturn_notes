//
//  MainController.swift
//  Saturn_InterviewProj_THM
//
//  Created by Tae Hong Min on 7/3/20.
//  Copyright © 2020 Interview. All rights reserved.
//

import Foundation
import UIKit
import Reachability
import SnapKit
import SDWebImage


class NotesViewController: UIViewController, UINavigationControllerDelegate {
    
    var network:NetworkService?
    var notes: [LocalNote] = []
    public var screenWidth: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    var notesTable: UITableView = {
        let tableView = UITableView()
        tableView.isEditing = false
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorStyle = .none
        return tableView
    }()
    
    init(network: NetworkService){
        self.network = network
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        network?.delegate = self
        setUpNavigation()
        setup()
    }
    
    func setup() {
        self.view.addSubview(notesTable)
        notesTable.register(NoteCell.self, forCellReuseIdentifier: "NoteCell")
        notesTable.dataSource = self
        notesTable.delegate = self
        notesTable.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func setUpNavigation() {
        navigationItem.title = "Notes"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(goToNoteConstruction))
    }
    
    @objc func goToNoteConstruction() {
        let vc = NoteConstructionViewController()
        vc.delegate = self
        let navController = UINavigationController(rootViewController: vc)
        present(navController, animated: true)
    }
    
    func networkError() {
        let alertController = UIAlertController(title: "You are not connected to the internet", message: "Please connect to the internet and try again.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
            alertController.dismiss(animated: true, completion: nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }

}

extension NotesViewController: UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteCell.reuseIdentifier, for: indexPath) as? NoteCell else {
            let cell = UITableViewCell(style: .default, reuseIdentifier: NoteCell.reuseIdentifier)
            return cell
        }
        let note = notes[indexPath.row]
        cell.bind(note)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return screenWidth / 4
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        defer {
          tableView.isUserInteractionEnabled = true
        }

        tableView.isUserInteractionEnabled = false
        
        let note = notes[indexPath.row]
        let hasNetwork = SReachability.shared.isNetworkAvailable
        if note.status == .local {
            if hasNetwork {
                let note = note.updateStatusStartLoading()
                network?.retryUploadingNote(note: note) { updatedNote in
                    self.notes[indexPath.row] = updatedNote
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }
            } else {
                networkError()
                return
            }
        }

    }
}

extension NotesViewController: NetworkDelegate {
    func refreshData() {
        DispatchQueue.main.async {
            self.notesTable.reloadData() //Cheap operation that works very well =]
        }
    }
    
    func getNotes(notes: [LocalNote]) {
//        print("note: \(notes)")
        DispatchQueue.main.async {
            self.notes = notes
            self.notesTable.reloadData()
        }
    }
}

extension NotesViewController: SaveNoteDelegate {
    func saveNote(note: LocalNote, image: UIImage) {
        if note.id != self.notes.first?.id {
            self.network?.uploadNoteLocal(img: image, note: note)
            DispatchQueue.main.async {
                self.notes.insert(note, at: 0)
                self.notesTable.reloadData()
            }
        }
    }
}
