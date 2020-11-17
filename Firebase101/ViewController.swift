//
//  ViewController.swift
//  Firebase101
//
//  Created by Seoung Cheol Ryu on 2020/11/15.
//

import UIKit
import Firebase

class ViewController: UIViewController {
      
      @IBOutlet weak var dataLabel: UILabel!
      let db = Database.database().reference()

      override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            updateLabel()
      }
      
      func updateLabel() {
            // 네트워크 작업으로 시간이 오래 걸리므로, main queue 가 아닌 global(qos: .utility) 로 가져와서 작업을 해야 하는게 아닌지?
            DispatchQueue.global(qos: .utility).async {
                  self.db.child("firstData").observeSingleEvent(of: .value) { (snapshot) in    // snapshot 이라는 인자로 데이터를 받아온다.
                        print("\(snapshot)")
                        
                        // 가져올 데이터를 우리가 원하는 타입으로 다운캐스팅해서 가져온다
                        let data = snapshot.value as? String ?? ""
                        // snapshot 의 value 를 String 으로 다운캐스팅하고, 실패하면 "" 값을 data 에 할당.
                        // UI 를 업데이트 하는 작업이므로, main thread 에 일감을 준다.
                        // main thread 에서 처리할 queue 이므로 main.async 를 한다.
                        // main 은 절대 sync 로 해서는 안된다.
                        DispatchQueue.main.async {
                              self.dataLabel.text = data
                        }
                                    
                  }
            }
      }
}

