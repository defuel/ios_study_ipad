//
//  ViewController.swift
//  iosStudy
//
//  Created by 八木圭一 on 2018/04/30.
//  Copyright © 2018年 Keiichi Yagi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
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
    @IBOutlet weak var loginName: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.updateTable()
        
        if UserDefaults.standard.object(forKey: "name") != nil {
            loginName.text = "ログイン中:" + UserDefaults.standard.string(forKey: "name")!
            loginName.sizeToFit()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        // 画面遷移判定
        if identifier == "runRegistEmployee" {
            
        }
        
        return true;
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 画面遷移前処理
        if segue.identifier == "runRegistEmployee" {
            
        }
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
    
    @IBAction func backToTop(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func clickRegistAttendance(_ sender: UIButton) {
        if UserDefaults.standard.object(forKey: "id") != nil {
            let id = UserDefaults.standard.integer(forKey: "id")
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
    }
    @IBAction func clickGetEmployee(_ sender: UIButton) {
        if UserDefaults.standard.object(forKey: "id") != nil {
            let id = UserDefaults.standard.integer(forKey: "id")
            let url = URL(string: "http://www.defuel.net/ios_study/api/get_employee.php?id=\(id)")
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
                        let alert = UIAlertController(title: attendance, message: result.name! + ":" + result.time! + ":" + attendance, preferredStyle: .alert)
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
    @IBAction func clickUpdateEmployeeList(_ sender: Any) {
        self.updateTable()
    }
}

