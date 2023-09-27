//
//  ViewController.swift
//  test
//
//  Created by Logeshwaran  on 22/09/23.
//

import UIKit
class AthletesVC: UIViewController {
    
    
    
    @IBOutlet weak var tableView: UITableView!
    let refreshControl = UIRefreshControl()
    let flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .horizontal
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        return layout
    }()
    var athletesList:[ModelAthlete]?
    var gamesList:[ModelGame]?
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchData()
    }
    func setupPage(){
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.red]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
        self.title = "Olympic Athletes"
        self.navigationItem.title = "some title"
    }
    func setupTableView(){
        tableView.register(UINib(nibName: "AthletesTableViewCell", bundle: nil), forCellReuseIdentifier: "AthletesTableViewCell")
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tableView.addSubview(refreshControl) // not required when using UITableViewController
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 100
        tableView.reloadData()
    }
    func setupData(){
        gamesList = gamesList?.sorted(by: { $0.yearDate.compare($1.yearDate) == .orderedDescending })
        repeatCall(repeatIndex: 0, gamesList: gamesList ?? [])
//        gamesList?.forEach({ mg in
//            print("\(mg.year ?? 0)")
//            print("\(mg.city ?? "")")
//            print("\(mg.game_id ?? 0)")
//
//        })
    }
    @objc func refresh(_ sender: AnyObject) {
        self.fetchData()
        
    }
    func fetchData(){
        NetworkManager.shared.getAllAthletes { data, error in
            self.athletesList = data
            NetworkManager.shared.getAllGames { data, error in
                self.gamesList = data
                self.setupData()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    func repeatCall(repeatIndex:Int, gamesList:[ModelGame]){
        if repeatIndex < gamesList.count {
            let game = gamesList[repeatIndex]
            NetworkManager.shared.getAthletesWithGame(id: "\(game.game_id ?? 0)", game:game) { data, game, error in
    //                mg.athletesList?.removeAll()
    //                mg.athletesList = data
                if repeatIndex < gamesList.count {
                    var newIndex = repeatIndex + 1
                    self.repeatCall(repeatIndex: newIndex, gamesList: gamesList)
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }else{
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                    print("List Count \(self.gamesList?.filter({$0.athletesList?.count ?? 0 > 0}).count)")
                    self.gamesList = self.gamesList?.filter({$0.athletesList?.count ?? 0 > 0})
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
            print("List Count \(self.gamesList?.filter({$0.athletesList?.count ?? 0 > 0}).count)")
            self.gamesList = self.gamesList?.filter({$0.athletesList?.count ?? 0 > 0})
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
}

extension AthletesVC: UITableViewDataSource, UITableViewDelegate {
    
    //TableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.gamesList?.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return  1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "AthletesTableViewCell") as? AthletesTableViewCell{
            cell.collectionView.tag = indexPath.section
            cell.collectionView.register(UINib(nibName: "AthletesCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "AthletesCollectionViewCell")
            cell.collectionView.dataSource = self
            cell.collectionView.delegate = self
            cell.collectionView.showsHorizontalScrollIndicator = false
            cell.collectionView.showsVerticalScrollIndicator = false
            cell.collectionView.collectionViewLayout = self.flowLayout
            cell.collectionView.layoutIfNeeded()
            cell.collectionView.reloadData()
            return cell
        }
        
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let game = self.gamesList?[indexPath.section]
        return (game?.athletesList?.count ?? 0 >  0) ? 150 : 0
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let game = self.gamesList?[section]
        return (game?.athletesList?.count ?? 0 >  0) ? "\(game?.city ?? "")  \(game?.year ?? 0)" : ""
    }
    
}
extension AthletesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //Collection View
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.gamesList?[collectionView.tag].athletesList?.count ?? 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AthletesCollectionViewCell", for: indexPath) as? AthletesCollectionViewCell, let athlete = self.gamesList?[collectionView.tag].athletesList?[indexPath.row]{
            cell.setCell(data: athlete)
            return cell
        }else{
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width
        let numberOfItemsPerRow: CGFloat = 3
        let spacing: CGFloat = flowLayout.minimumInteritemSpacing
        let availableWidth = width - spacing * (numberOfItemsPerRow + 1)
        let itemDimension = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemDimension, height: 150)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let athlete = self.gamesList?[collectionView.tag].athletesList?[indexPath.row]{
            print(athlete.name)
            let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
            if let vc = storyBoard.instantiateViewController(withIdentifier: "AthleteDetailVC") as? AthleteDetailVC{
                vc.athlete = athlete
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
        }
    }
}



