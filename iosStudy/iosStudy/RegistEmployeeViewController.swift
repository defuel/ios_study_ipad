//
//  RegistEmployeeViewController.swift
//  iosStudy
//
//  Created by 八木圭一 on 2018/04/30.
//  Copyright © 2018年 Keiichi Yagi. All rights reserved.
//

import UIKit

class RegistEmployeeViewController: UIViewController {

    @IBOutlet weak var loginName: UILabel!
    @IBOutlet weak var employeeName: UITextField!
    
    struct Employee:Codable {
        var result:Result
        struct Result:Codable {
            var error:Int
            var message:String?
            var id:Int?
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UserDefaults.standard.object(forKey: "name") != nil {
            loginName.text = "ログイン中:" + UserDefaults.standard.string(forKey: "name")!
            loginName.sizeToFit()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickRegist(_ sender: UIButton) {
        if (employeeName.text?.isEmpty)! {
            return
        }
        let name = employeeName.text!
        
        let url = URL(string: "http://www.defuel.net/ios_study/api/add_employee.php?name=" + employeeName.text!.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        session.dataTask(with: request){(data, response, error) in
            if error == nil {
                let data = data
                _ = response as? HTTPURLResponse
                print(String(data: data!, encoding: String.Encoding.utf8) ?? "")
                
                let employee = try! JSONDecoder().decode(Employee.self, from: data!)
                let result = employee.result
                
                if result.error == 1 {
                    let alert = UIAlertController(title: "error", message: result.message, preferredStyle: .alert)
                    alert.present(alert, animated: true, completion: nil)
                } else {
                    UserDefaults.standard.set(result.id, forKey: "id")
                    UserDefaults.standard.set(name, forKey: "name")
                    DispatchQueue.main.async {
                        self.loginName.text = "ログイン中:" + name
                        self.loginName.sizeToFit()
                    }
                }
            } else {
                let alert = UIAlertController(title: "error", message: "http_error", preferredStyle: .alert)
                alert.present(alert, animated: true, completion: nil)
            }
        }.resume()
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
