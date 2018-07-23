//
//  EmployeeData.swift
//  iosStudy
//
//  Created by 八木圭一 on 2018/04/30.
//  Copyright © 2018年 Keiichi Yagi. All rights reserved.
//

import UIKit

class EmployeeData: NSObject, UITableViewDataSource {
    struct Data:Codable {
        var result:Result
        struct Result:Codable {
            var error:Int
            var message:String?
            var id:Int?
            var employee:[Employee]
        }
        struct Employee:Codable {
            var id:Int
            var name:String
            var time:String
            var attendance:Int
        }
    }
    
    var employeeData : [Data.Employee]?
    
    func setData(data:[Data.Employee]){
        self.employeeData = data
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "出退勤一覧"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(employeeData != nil){
            return employeeData!.count
        }
        return 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        let attendance = employeeData![indexPath.row].attendance == 1 ? "出勤" : "-"
        cell.textLabel?.text = employeeData![indexPath.row].name + ":" + employeeData![indexPath.row].time + ":" + attendance
        return cell
    }
    
    func getEmployeeList() -> Dictionary<Int, Data.Employee> {
        var result : Dictionary = Dictionary<Int, Data.Employee>()
        
        if(self.employeeData != nil){
            for (index, element) in employeeData!.enumerated()
            {
                result[index] = element
            }
        }
        return result
    }
}
