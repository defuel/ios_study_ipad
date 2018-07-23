//
//  MainViewController.swift
//  iosStudy
//
//  Created by 八木圭一 on 2018/05/06.
//  Copyright © 2018年 Keiichi Yagi. All rights reserved.
//

import UIKit
import SwiftSocket

class MainViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    struct Employee:Codable {
        var result:Result
        struct Result:Codable {
            var error:Int
            var message:String?
            var name:String?
            var time:String?
            var attendance:Int?
        }
    }

    @IBOutlet var employeeData: EmployeeData!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var selectEmployee : Int? = nil
    
    var alert:UIAlertController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.nowTime()
        Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.nowTime), userInfo: nil, repeats: true)
        
        DispatchQueue.global(qos: .default).async {
            self.startServer()
        }

        self.updateTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func nowTime(){
        let date = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .weekday, .hour, .minute, .second], from: date)
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        self.dateLabel.text = String(format: "%4d/%02d/%02d(%@)", components.year!, components.month!, components.day!, dateFormatter.shortWeekdaySymbols[components.weekday!-1])
        self.dateLabel.sizeToFit()
        self.timeLabel.text = String(format: "%02d:%02d:%02d", components.hour!, components.minute!, components.second!)
        self.timeLabel.sizeToFit()
    }

    func updateTable(){
        let url = URL(string: "http://www.defuel.net/ios_study/api/get_attendance.php")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let receiveData = try! JSONDecoder().decode(EmployeeData.Data.self, from: data!)
                let result = receiveData.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.employeeData.setData(data: result.employee)
                    DispatchQueue.main.async {
                        self.tableView.reloadData();
                    }
                }
            }
        }.resume()
    }
    
    func addAttendance(id : Int){
        let url = URL(string: "http://www.defuel.net/ios_study/api/add_attendance.php?id=\(id)")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let receiveData = try! JSONDecoder().decode(Employee.self, from: data!)
                let result = receiveData.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let attendance = result.attendance == 1 ? "出勤" : "退勤"
                    let alert = UIAlertController(title: attendance, message: result.time! + ":" + attendance, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: {
                        (action:UIAlertAction!) in
                        self.updateTable()
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }.resume()
    }
    
    func addAttendanceCard(uid : String){
        let url = URL(string: "http://www.defuel.net/ios_study/api/add_attendance_card.php?uid=\(uid)")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let receiveData = try! JSONDecoder().decode(Employee.self, from: data!)
                let result = receiveData.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let attendance = result.attendance == 1 ? "出勤" : "退勤"
                    let alert = UIAlertController(title: attendance, message: result.time! + ":" + attendance, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: {
                        (action:UIAlertAction!) in
                        self.updateTable()
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            }.resume()
    }
    
    @IBAction func clickAddAttendance(_ sender: UIButton) {
        let alert = UIAlertController(title: "社員選択", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler : { (action:UIAlertAction!) -> Void in
            self.addAttendance(id: self.selectEmployee!)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil);
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {
                pickerView.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.width, height: alert.view.bounds.height * 0.8)
                alert.view.addSubview(pickerView)
            }
        )
    }
    
    @IBAction func clickUpdate(_ sender: UIButton) {
        self.updateTable()
    }
    @IBAction func clickAddCard(_ sender: UIButton) {
        let alert = UIAlertController(title: "社員選択", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler : { (action:UIAlertAction!) -> Void in
            self.alert = UIAlertController(title: "カード登録", message: "カードリーダーに登録するカードをタッチしてください", preferredStyle: .alert)
            let cancel = UIAlertAction(title: "キャンセル", style: .cancel, handler: nil)
            self.alert.addAction(cancel)
            self.present(self.alert, animated: true, completion: nil)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil);
        
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {
            pickerView.frame = CGRect(x: 0, y: 20, width: alert.view.bounds.width, height: alert.view.bounds.height * 0.8)
            alert.view.addSubview(pickerView)
        })
    }
    
    @IBAction func clickAddEmployee(_ sender: UIButton) {
        let nameInput = UITextField()
        let alert = UIAlertController(title: "社員登録", message: "\n\n\n\n\n\n\n\n\n\n", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler : { (action:UIAlertAction!) -> Void in
            self.addEmployee(name: nameInput.text!)
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .default, handler: nil);
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: {
            nameInput.frame = CGRect(x: 0, y: 50, width: alert.view.bounds.width, height: 30)
            nameInput.borderStyle = .roundedRect
            alert.view.addSubview(nameInput)
        })
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.employeeData.getEmployeeList().count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let list =  self.employeeData.getEmployeeList()
        return list[row]!.name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let list = self.employeeData.getEmployeeList()
        self.selectEmployee = list[row]?.id
    }
    
    func startServer() {
        let server = TCPServer(address: "127.0.0.1", port: 12345)
        switch server.listen() {
        case .success:
            while true {
                if let client = server.accept() {
                    let array = client.read(1024*10)
                    let data = Data(bytes: array!)
                    let cardUid = String(data: data, encoding: .utf8)
                    if(self.alert != nil){
                        DispatchQueue.main.async {
                            self.alert.dismiss(animated: true, completion: nil)
                        }
                        
                        addCard(cardUid: cardUid!)
                    } else {
                        addAttendanceCard(uid: cardUid!)
                    }
                    client.close()
                } else {
                    print("accept error")
                }
            }
        case .failure(let error):
            print(error)
        }
    }
        
    func addEmployee(name : String){
        var urlString = "http://www.defuel.net/ios_study/api/add_employee.php?name=\(name)"
        urlString = urlString.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let receiveData = try! JSONDecoder().decode(Employee.self, from: data!)
                let result = receiveData.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "登録完了", message: "社員登録が完了しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: {
                        (action:UIAlertAction!) in
                        self.updateTable()
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            }.resume()
    }
    
    func addCard(cardUid : String){
        let url = URL(string: "http://www.defuel.net/ios_study/api/add_nfc_card.php?id=\(selectEmployee!)&uid=\(cardUid)")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let receiveData = try! JSONDecoder().decode(Employee.self, from: data!)
                let result = receiveData.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: nil)
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "登録完了", message: "カード登録が完了しました", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "ok", style: .cancel, handler: {
                        (action:UIAlertAction!) in
                        self.updateTable()
                    })
                    alert.addAction(ok)
                    self.present(alert, animated: true, completion: nil)
                }
            }
            }.resume()
    }
}
