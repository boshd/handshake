import Firebase
import PhoneNumberKit
import Contacts
import SDWebImage

protocol UsersUpdatesDelegate: class {
    func users(shouldBeUpdatedTo users: [User])
}

class UsersFetcher: NSObject {
    
    weak var delegate: UsersUpdatesDelegate?
    fileprivate let phoneNumberKit = PhoneNumberKit()
    lazy var functions = Functions.functions()

    var currentUserUserIdsListener: ListenerRegistration?
    
    func loadAndSyncUsers() {
        userDefaults.updateObject(for: userDefaults.contactsSyncronizationStatus, with: false)
        removeAllUsersObservers()
        requestUsers()
    }
    
    func prepareNumber(from number: String) -> String? {
        var preparedNumber: String?
        do {
            let countryCode = try phoneNumberKit.parse(number).countryCode
            let nationalNumber = try phoneNumberKit.parse(number).nationalNumber
            preparedNumber = "+" + String(countryCode) + String(nationalNumber)
        } catch {
            if number == "5555555555" {
                preparedNumber = "+15555555555"
            } else if number == "3333333333" {
                preparedNumber = "+13333333333"
            } else if number == "4444444444" {
                preparedNumber = "+14444444444"
            }
        }
        
        return preparedNumber
    }
    
    func prepareNumberTuples(from contacts: [String:CNContact]) -> [(String, String)] {
        var preparedNumberTuples = [(String, String)]()
        for (_, contact) in contacts {
            let contactPhones = contact.phoneNumbers.map({$0.value.stringValue.digits})
            if !contactPhones.isEmpty {
                for contactPhone in contactPhones {
                    do {
                        let countryCode = try phoneNumberKit.parse(contactPhone).countryCode
                        let nationalNumber = try phoneNumberKit.parse(contactPhone).nationalNumber
                        preparedNumberTuples.append((contact.identifier, ("+" + String(countryCode) + String(nationalNumber))))
                    } catch {
                        if contactPhone == "2222222222" {
                            preparedNumberTuples.append((contact.identifier, "+12222222222"))
                        } else if contactPhone == "3333333333" {
                            preparedNumberTuples.append((contact.identifier, "+13333333333"))
                        } else if contactPhone == "4444444444" {
                            preparedNumberTuples.append((contact.identifier, "+14444444444"))
                        } else if contactPhone == "5555555555" {
                            preparedNumberTuples.append((contact.identifier, "+15555555555"))
                        } else if contactPhone == "6666666666" {
                            preparedNumberTuples.append((contact.identifier, "+16666666666"))
                        } else if contactPhone == "7777777777" {
                            preparedNumberTuples.append((contact.identifier, "+17777777777"))
                        } else if contactPhone == "8888888888" {
                            preparedNumberTuples.append((contact.identifier, "+18888888888"))
                        } else if contactPhone == "9999999999" {
                            preparedNumberTuples.append((contact.identifier, "+19999999999"))
                        }
                    }
                }
            }
        }
        return preparedNumberTuples
    }// AA009ZPCW3
    
    fileprivate func requestUsers() {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        
        let tuples = prepareNumberTuples(from: globalVariables.localContactsDict)
        
        
        functions.httpsCallable("getUsersWithPreparedNumbers").call(["preparedNumbers": tuples.map({ $0.1 })]) { (result, error) in
            if error != nil {
                print(error?.localizedDescription ?? "error in https call - getUsersWithPreparedNumbers")
                return
            }
            guard let response = result?.data as? [[String: AnyObject]] else { return }
            var fetchedUsers = [User]()
            var fetchedUsersTuples = [(User, String)]()
            
            for object in response {
                let user = User(dictionary: object)
                
                if let uid = user.id, uid != currentUserID {
                    fetchedUsers.append(user)
                    if let userLocalContactId = tuples.first(where: { $0.1 == user.phoneNumber })?.0 {
                        fetchedUsersTuples.append((user, userLocalContactId))
                    }
                }
            }
            
            userDefaults.updateObject(for: userDefaults.contactsSyncronizationStatus, with: true)
            self.updateUsers(with: fetchedUsersTuples)
        }
    }
    
    fileprivate func updateUsers(with fetchedUsersTuples: [(User, String)]) {
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let usersCollectionReference = Firestore.firestore().collection("users")
        
        let userIDs = fetchedUsersTuples.map({ $0.0.id ?? ""})
        
        let batch = Firestore.firestore().batch()
        
        for userID in userIDs {
            let currentUserUserIdsDocumentReference = usersCollectionReference.document(currentUserID).collection("userIds").document(userID)
            let connectionUserConnectionUserIdsDocumentReference = usersCollectionReference.document(userID).collection("connectionUserIds").document(currentUserID)
            batch.setData([
                "userId": userID,
                "localContactId": fetchedUsersTuples.first(where: { $0.0.id == userID })?.1 ?? ""
            ], forDocument: currentUserUserIdsDocumentReference)
            batch.setData([:], forDocument: connectionUserConnectionUserIdsDocumentReference)
            // myid -> connectionuserids -> personid
            // personid -> userids -> remove myid
        }
        
        batch.commit { (error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            self.loadUsers()
        }
    }
    
    fileprivate var users = [User]()
    fileprivate var usersReference: CollectionReference!
    fileprivate var usersLoadingGroup = DispatchGroup()
    fileprivate var isUsersLoadingGroupFinished = false
    
    func loadUsers() {
        removeAllUsersObservers()
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .denied || status == .restricted { return }
        guard let currentUserID = Auth.auth().currentUser?.uid else { return }
        let currentUserReference = Firestore.firestore().collection("users").document(currentUserID)
        currentUserUserIdsListener = currentUserReference.collection("userIds").addSnapshotListener({ (snapshot, error) in
            if error != nil {
                print(error?.localizedDescription ?? "")
                return
            }
            
            guard let docs = snapshot?.documents, !docs.isEmpty else {
                self.isUsersLoadingGroupFinished = true
                self.updateDataSource(newUsers: [User]())
                return
            }
            
            var userIDsAndContactIDs = [(String, String)]()
            
            for doc in docs {
                let data = doc.data()
                guard let contactId = data["localContactId"] as? String else { return }
                userIDsAndContactIDs.append((doc.documentID, contactId))
            }
            
            if let index = userIDsAndContactIDs.map({ $0.0 }).firstIndex(of: currentUserID) {
                userIDsAndContactIDs.remove(at: index)
            }
            self.loadData(for: userIDsAndContactIDs)
        })
    }
    
    fileprivate func loadData(for userIDsAndContactIDs: [(String, String)]) {
        usersLoadingGroup = DispatchGroup()
        userIDsAndContactIDs.forEach { (_) in usersLoadingGroup.enter() }
        usersLoadingGroup.notify(queue: .main, execute: {
            self.isUsersLoadingGroupFinished = true
            self.updateDataSource(newUsers: self.users)
        })
        
        let usersReference = Firestore.firestore().collection("users")
        
        userIDsAndContactIDs.forEach { (userID, contactID) in
            
            usersReference.document(userID).getDocument { (snapshot, error) in
                if error != nil {
                    print(error?.localizedDescription ?? "")
                    return
                }
                
                guard var dict = snapshot?.data() as [String: AnyObject]? else {
                    self.updateDataSource(newUsers: self.users)
                    return
                }
                
                dict.updateValue(userID as AnyObject, forKey: "id")
                let user = User(dictionary: dict)
                
                user.localContactIdentifier = contactID
                
                user.localName = globalVariables.localContactsDict.values.first(where: { $0.identifier == contactID })?.givenName
                
                if let thumbnail = user.userThumbnailImageUrl, let url = URL(string: thumbnail) {
                    SDWebImagePrefetcher.shared.prefetchURLs([url])
                }

                if let index = self.users.firstIndex(where: { (indexedUser) -> Bool in
                    return indexedUser.id == user.id
                }) {
                    self.users[index] = user
                } else {
                    self.users.append(user)
                }
                self.updateDataSource(newUsers: self.users)
                
            }
        }
    }
    
    fileprivate func updateDataSource(newUsers: [User]?) {
        guard isUsersLoadingGroupFinished == true else { usersLoadingGroup.leave(); return }
        guard let newUsers = newUsers else { return }
        self.delegate?.users(shouldBeUpdatedTo: newUsers)
    }
    
    fileprivate func removeAllUsersObservers() {
        users.removeAll()
        isUsersLoadingGroupFinished = false
        guard currentUserUserIdsListener != nil else { return }
        currentUserUserIdsListener?.remove()
    }
    
    // user fetching method
    public static func fetchUser(id: String, completion: @escaping (User?, Error?) -> ()) {
        Firestore.firestore().collection("users").document(id).getDocument { snapshot, error in
            if error != nil {
                print(error?.localizedDescription ?? "error")
                completion(nil, error)
                return
            }
            guard let userData = snapshot?.data() as [String : AnyObject]? else { completion(nil, error); return }
            completion(User(dictionary: userData), nil)
        }
    }
    
}
