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
      @IBOutlet weak var statusLabel: UILabel!
      
      let db = Database.database().reference()
      // update 를 할 때 유용하게 하기 위해서 customers 프로퍼티를 가진다.
      var customers: [Customer] = []

      override func viewDidLoad() {
            super.viewDidLoad()
            // Do any additional setup after loading the view.
            updateLabel()
//            saveBasicType()
//            saveCustomers()
            fetchCustomers()
//            updateBasicTypes()
//            deleteBasicTypes()
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
      
      @IBAction func createCustomer(_ sender: Any) {
            saveCustomers()
      }
      
      @IBAction func readCustomer(_ sender: Any) {
            fetchCustomers()
      }
      
      func updateCustomers() {
            guard customers.isEmpty == false else { return }
            customers[0].name = "Min"
            // update 된 data 들을 dictionary 로 만들어 db 에 update 시킨다.(firebase 에 쓸 수 있는 타입: String, Number, Array, Dictionary 이므로)
            
            
            let dictionary = customers.map { $0.toDictionary }
            // db 에 update
            // customers 키의 value 를 dictionary 상수에 저장된 데이터로 update.
            db.updateChildValues(["customers": dictionary])
      }
      
      @IBAction func updpateCustomer(_ sender: Any) {
            updateCustomers()
      }
      
      func deleteCustomers() {
            db.child("customers").removeValue()
      }
      
      @IBAction func deleteCustomer(_ sender: Any) {
            deleteCustomers()
      }
      
}

extension ViewController {
      // DB Write
      // Firebase child("key").setValue(value) 로 data write
      // write 할 수 있는 type : String, Number, Dictionary, Array
      func saveBasicType() {  // 메서드 정의
            db.child("int").setValue(3)
            db.child("double").setValue(3.5)
            db.child("str").setValue("string Value: Hi")
            db.child("array").setValue(["A", "b", "C"])
            db.child("dict").setValue(["ID": "anyID", "age": 10, "city": "seoul"])
      }
      
      func saveCustomers() {
            // sample data
            // Model = Customer + Book
            let books = [Book(title: "Good to Great", author: "Someone"), Book(title: "Hacking Growth", author: "Somebody")]
            
            let customer1 = Customer(id: "\(Customer.id)", name: "son", books: books)
            Customer.id += 1
            
            let customer2 = Customer(id: "\(Customer.id)", name: "Dele", books: books)
            Customer.id += 1
            
            let customer3 = Customer(id: "\(Customer.id)", name: "Kane", books: books)
            Customer.id += 1
            
            db.child("customers").child(customer1.id).setValue(customer1.toDictionary)
            db.child("customers").child(customer2.id).setValue(customer2.toDictionary)
            db.child("customers").child(customer3.id).setValue(customer3.toDictionary)
            
            
            
      }
      
}

// custom object data read func
// MARK: Read(fetch: 가지고오다) Data
extension ViewController {
      func fetchCustomers() {
            // 데이터 가져오기
            // customers 에 해당하는 data 들이 snapshot 을 통해 전닫된다.
            db.child("customers").observeSingleEvent(of: .value) { (snapshot) in
                  print("\(snapshot.value)")
                  
                  
                  do {
                        // codable 을 사용하기 위해 data 를 JSON 으로 만들기
                        let data = try JSONSerialization.data(withJSONObject: snapshot.value, options: [])
                        let decoder = JSONDecoder()
                        
                        // decode(type: 파싱하고 싶은 타입, from: 파싱할 data)
                        let customers: [Customer] = try decoder.decode([Customer].self, from: data)
                        // fetch(가져온) customers 정보를 self.customers 에 할당.
                        self.customers = customers
                        
                        DispatchQueue.main.async {
                              self.statusLabel.text = "Data Count : \(customers.count)"
                        }
//                        print(customers.count)
                        
                  } catch let error {
                        print(error.localizedDescription)
                  }
            }
      }
}


// update, delete
extension ViewController {
      func updateBasicTypes() {
//            db.child("int").setValue(3)
//            db.child("double").setValue(3.5)
//            db.child("str").setValue("string value: Hi")
            db.updateChildValues(["int": 6])
            db.updateChildValues(["double": 5.4])
            db.updateChildValues(["str": "변경된 String"])
      }
      
      func deleteBasicTypes() {
            db.child("int").removeValue()
            db.child("double").removeValue()
            db.child("str").removeValue()
      }
}


// 저장할 데이터를 오브젝트로 만들기 (custom Object)
struct Customer: Codable {    // db 로부터 전달받는 데이터의 키와 프로퍼티의 이름이 같아야 한다.
      /*
       db.child("customers") 의 키(id, name, books) 와 프로퍼티의 이름 (id, name, books) 가 같아야 하고, 만약 다르다면 enum Codingkeys: T, CodingKey 로 맞춰줘야 한다.
       
       enum Codingkeys: String, CodingKey {
            case 프로퍼티 = "DB 키"
            case id = "id"
       }
       */
      let id: String
      var name: String
      var books: [Book]
      
      // 위의 형태로는 firebase 로 바로 전송할 수 없기 때문에(firebase 에 저장할 수 있는 타입 : String, Number, Dictionary, Array) firebase 로 보낼 수 있는 타입으로 변환해줘야 한다.
      // Dictionary 로 변환.
      var toDictionary: [String: Any] {
            let booksArray = books.map { $0.toDictionary }
            let dict: [String: Any] = ["id": id, "name": name, "books": booksArray]
            return dict
      }
      
      static var id: Int = 0
}

struct Book: Codable {
      let title: String
      let author: String
      // Book struct 또한 마찬가지
      var toDictionary: [String: Any] {
            let dict: [String: Any] = ["title": title, "author": author]
            return dict
      }
}
