//
//  MyNewsTableViewController.swift
//  vk
//
//  Created by Alexandr Evtodiy on 02.09.2020.
//  Copyright © 2020 Alexandr Evtodiy. All rights reserved.
//

import UIKit
import RealmSwift

class MyNewsTableViewController: UITableViewController {

    internal let newRefreshControl = UIRefreshControl()
    var myNews: [VkApiNewItem]?
    let vkService = VKService ()
    var token: NotificationToken?
    var photoService: PhotoService?
    
    var nextFrom = ""
    var isLoading = false
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        photoService = PhotoService(container: tableView)
        setupTableView ()
        setupRefreshControl ()
        // очищаем базу данных от новостей
        clearNewsFromRealm {
            //отправим запрос для получения  новостей пользователя
            self.fetchNewsData ()
        }
        pairTableAndRealm { [weak self] myNews in
            guard let tableView = self?.tableView else { return }
            self?.myNews = myNews.sorted {$0.date > $1.date}
            tableView.reloadData()
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
        // Начинаем обновление новостей
        self.newRefreshControl.beginRefreshing()
        // Определяем время самой свежей новости
        // или берем текущее время
        if let mostFreshNewDate = self.myNews?.first?.date {
            fetchNewsData (startTime: mostFreshNewDate + 1)
        }
        else {
            fetchNewsData (startTime: Int(Date().timeIntervalSince1970 + 1))
        }
    }
    
    private func fetchNewsData (startTime: Int = 0) {
        DispatchQueue.global().async { [weak self] in
            // отправляем сетевой запрос загрузки новостей
            self?.vkService.loadNewsData(startTime: startTime, typeNew: .post,.photo) { [weak self] result,nextFrom  in
                guard let self = self else { return }
                // выключаем вращающийся индикатор
                self.newRefreshControl.endRefreshing()
                
                switch result {
                case .success (let news):
                    // проверяем, что более свежие новости действительно есть
                    guard news!.count > 0 else { return }
                    // Save user array to Database
                    // Working with Realm
                    if (startTime == 0) {
                        // Если не было рефреша и был первый запрос после загрузки приложения
                        if let nextFrom = nextFrom {
                            self.nextFrom = nextFrom
                        }
                    }
                        //Если был рефреш
                    if let news = news {
                        self.vkService.realmSaveService.saveNews(news: news)
                    }
                case .failure (let error):
                    debugPrint ("Error of News")
                    debugPrint (error)
                }
            }
        }
    }

    private func pairTableAndRealm(completion: @escaping  ([VkApiNewItem]) -> Void ) {
            guard let realm = try? Realm() else { return }
        let objects = realm.objects(VkApiNewItem.self)
        token = objects.observe { (changes: RealmCollectionChange) in
               // guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial (let results):
                    guard !results.isInvalidated else {return}
                    //let myNews = [VkApiNewItem](results)
                    let myNews = self.transRealmAnswerToArray(answer: results)
                    debugPrint(".initial : \(myNews.count) myNews loaded from DB")
                    completion(myNews)
                case .update (let results, _, _, _):
                    guard !results.isInvalidated else {return}
                    //let myNews = [VkApiNewItem](results)
                    let myNews = self.transRealmAnswerToArray(answer: results)
                    debugPrint(".update : \(myNews.count) myNews loaded from DB")
                    completion(myNews)
                case .error(let error):
                    fatalError("\(error)")
                }
            }
        }
    
    private func transRealmAnswerToArray (answer: Results<VkApiNewItem>) -> [VkApiNewItem]  {
        var array:[VkApiNewItem] = [VkApiNewItem] ()
        for object in answer {
            let new: VkApiNewItem = VkApiNewItem ()
            new.avatarImageURL = object.avatarImageURL
            new.nameGroupOrUser = object.nameGroupOrUser
            new.type = object.type
            new.sourceId = object.sourceId
            new.date = object.date
            new.text =  object.text
            new.commentsCount =  object.commentsCount
            new.likesCount =  object.likesCount
            new.userLikes = object.userLikes
            new.repostCount = object.repostCount
            new.userReposted = object.userReposted
            new.typeAttachment =  object.typeAttachment
            new.listPhotoImageURL =  object.listPhotoImageURL
            new.listPhotoAttachmentImageURL = object.listPhotoAttachmentImageURL
            array.append(new)
        }
        return array
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
           !isLoading {
            // Начинаем загрузку данных и меняем флаг isLoading
            isLoading = true
            // Обратите внимание, что сетевой сервис должен уметь обрабатывать входящий параметр nextFrom
            vkService.loadNewsData(startFrom: nextFrom, typeNew: .photo,.post)
            // и в качестве результата возвращать не только свежераспарсенные новости, но и nextFrom для будущего запроса
            {[weak self] (result, nextFrom) in
                guard let self = self else { return }
                switch result {
                case .success(let news):
                    if let nextFrom = nextFrom {
                        self.nextFrom = nextFrom
                    }
                    if let news = news {
                        self.vkService.realmSaveService.saveNews(news: news)
                    }
                case .failure (let error):
                    debugPrint ("Error of News")
                    debugPrint (error)
                }
                // Выключаем статус isLoading
                self.isLoading = false
            }
        }
    }
}


