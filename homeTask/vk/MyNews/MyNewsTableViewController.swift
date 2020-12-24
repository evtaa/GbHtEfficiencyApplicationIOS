//
//  MyNewsTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 02.09.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import RealmSwift

enum TypeFetchNewsData {
    case pullToRefresh
    case infiniteScrolling
    case firstFetch
}

class MyNewsTableViewController: UITableViewController {
    
    internal let newRefreshControl = UIRefreshControl()
    var myNews: [VkApiNewItem]?
    let vkService = VKService ()
    let newsAdapter = NewsAdapter ()
    var token: NotificationToken?
    var photoService: PhotoService?
    var isLoadingFetchInfiniteScrolling: Bool = false
    
    var nextFrom = ""
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoService = PhotoService(container: tableView)
        setupTableView ()
        setupRefreshControl ()
        // очищаем базу данных от новостей
        clearNewsFromRealm {
            //отправим запрос для получения  новостей пользователя
            self.fetchNewsData (typeFetch: .firstFetch)
        }
    }
    
    private func clearNewsFromRealm (completion: @escaping ()-> Void) {
        self.vkService.realmSaveService.deleteNews()
        completion ()
    }
    private func setupTableView () {
        
        tableView.prefetchDataSource = self
        
        self.tableView.register(UINib (nibName: "MyNewsTableViewCellForOnePhoto", bundle: nil), forCellReuseIdentifier: "MyNewsCellForOnePhoto")
        self.tableView.register(UINib (nibName: "MyNewsTableViewCellForTwoPhotos", bundle: nil), forCellReuseIdentifier: "MyNewsCellForTwoPhotos")
        self.tableView.register(UINib (nibName: "MyNewsTableViewCellForThreePhotos", bundle: nil), forCellReuseIdentifier: "MyNewsCellForThreePhotos")
        self.tableView.register(UINib (nibName: "MyNewsTableViewCellForFourPhotos", bundle: nil), forCellReuseIdentifier: "MyNewsCellForFourPhotos")
        self.tableView.register(UINib (nibName: "MyNewsTableViewCell", bundle: nil), forCellReuseIdentifier: "MyNewsCell")
        
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = UITableView.automaticDimension
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = newRefreshControl
        } else {
            tableView.addSubview(newRefreshControl)
        }
        
        // Убираем разделительные линии между пустыми ячейками
        tableView.tableFooterView = UIView ()
    }
    
    private func setupRefreshControl () {
        // Configure Refresh Control
        newRefreshControl.addTarget(self, action: #selector(refreshNewsData(_:)), for: .valueChanged)
        newRefreshControl.tintColor = UIColor(red: 0.25, green: 0.72, blue: 0.85, alpha: 0.7)
    }
    
    @objc func refreshNewsData(_ sender: Any) {
        fetchNewsData(typeFetch: .pullToRefresh)
    }
    
    private func fetchNewsData (typeFetch: TypeFetchNewsData) {
        var startTime: Int = 0
        var startFrom: String = ""
        switch typeFetch {
        case .firstFetch:
            startTime = 0
            startFrom = ""
        case .pullToRefresh:
            self.newRefreshControl.beginRefreshing()
            startFrom = ""
            // Определяем время самой свежей новости
            // или берем текущее время
            if let mostFreshNewDate = self.myNews?.first?.date {
                startTime = mostFreshNewDate + 1
            }
            else {
                startTime = Int(Date().timeIntervalSince1970 + 1)
            }
        case .infiniteScrolling:
            isLoadingFetchInfiniteScrolling = true
            startTime = 0
            startFrom = self.nextFrom
        }
        newsAdapter.getNewsData(startTime: startTime, startFrom: startFrom , typeNew: .post,.photo) { [weak self] result, nextFrom in
            guard let self = self else { return }
            switch result {
            case .success (let news):
                // проверяем, что запрашиваемые новости действительно есть
                guard news!.count > 0 else { return }
                // Save user array to Database
                // Working with Realm
                switch typeFetch {
                case .firstFetch:
                    if let nextFrom = nextFrom {
                        self.nextFrom = nextFrom
                    }
                case .pullToRefresh:
                    self.newRefreshControl.endRefreshing()
                case .infiniteScrolling:
                    if let nextFrom = nextFrom {
                        self.nextFrom = nextFrom
                    }
                    self.isLoadingFetchInfiniteScrolling = false
                }
                
                //Если был рефреш
                if let news = news {
                    self.myNews = news
                    self.myNews = self.myNews?.sorted {$0.date > $1.date}
                    self.tableView.reloadData()
                }
            case .failure (let error):
                debugPrint ("Error of News")
                debugPrint (error)
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let count  = self.myNews?.count else {
            return 0
        }
        return count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        guard let myNew  = self.myNews? [indexPath.row] else {return cell}
        guard let type = myNew.type else {return cell}
        var countImages: Int
        
        switch type {
        case "photo":
            countImages = myNew.listPhotoImageURL.count
        case "post":
            countImages = myNew.listPhotoAttachmentImageURL.count
        default:
            return cell
        }
        
        if countImages == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyNewsCell", for: indexPath) as! MyNewsTableViewCell
            cell.config (new: myNew, photoService: photoService, indexPath: indexPath)
            cell.tap = { [weak self] new in
                if let myNews = self?.myNews,
                   let index = myNews.firstIndex(where: { $0.id == new.id }) {
                    myNews [index].isExpanded.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                debugPrint (new.id)
            }
            return cell
        }
        else if countImages == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyNewsCellForOnePhoto", for: indexPath) as! MyNewsTableViewCellForOnePhoto
            cell.config (new: myNew, photoService: photoService, indexPath: indexPath)
            cell.tap = { [weak self] new in
                if let myNews = self?.myNews,
                   let index = myNews.firstIndex(where: { $0.id == new.id }) {
                    myNews [index].isExpanded.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                debugPrint (new.id)
            }
            
            return cell
        } else if countImages == 2  {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyNewsCellForTwoPhotos", for: indexPath) as! MyNewsTableViewCellForTwoPhotos
            cell.config (new: myNew, photoService: photoService, indexPath: indexPath)
            cell.tap = { [weak self] new in
                if let myNews = self?.myNews,
                   let index = myNews.firstIndex(where: { $0.id == new.id }) {
                    myNews [index].isExpanded.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                debugPrint (new.id)
            }
            return cell
        } else if countImages == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyNewsCellForThreePhotos", for: indexPath) as! MyNewsTableViewCellForThreePhotos
            cell.config(new: myNew, photoService: photoService, indexPath: indexPath)
            cell.tap = { [weak self] new in
                if let myNews =  self?.myNews,
                   let index = myNews.firstIndex(where: { $0.id == new.id }) {
                    myNews [index].isExpanded.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                debugPrint (new.id)
            }
            return cell
        } else if countImages > 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyNewsCellForFourPhotos", for: indexPath) as! MyNewsTableViewCellForFourPhotos
            cell.config (new: myNew, photoService: photoService, indexPath: indexPath)
            cell.tap = { [weak self] new in
                if let myNews = self?.myNews,
                   let index = myNews.firstIndex(where: { $0.id == new.id }) {
                    myNews [index].isExpanded.toggle()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                debugPrint (new.id)
            }
            return cell
        } else{
            return cell
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }    
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MyNewsTableViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        // Выбираем максимальный номер секции, которую нужно будет отобразить в ближайшее время
        guard let maxRow = indexPaths.map({ $0.row }).max() else { return }
        // Проверяем,является ли эта секция одной из трех ближайших к концу
        if let myNews = self.myNews,
           maxRow > myNews.count - 3,
           // Убеждаемся, что мы уже не в процессе загрузки данных
           !isLoadingFetchInfiniteScrolling {
            fetchNewsData(typeFetch: .infiniteScrolling)
        }
    }
}


