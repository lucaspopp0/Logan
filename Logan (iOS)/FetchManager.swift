//
//  FetchManager.swift
//  iOS Todo
//
//  Created by Lucas Popp on 2/22/18.
//  Copyright © 2018 Lucas Popp. All rights reserved.
//

import CloudKit

class FetchManager {
    
    var records: [CKRecord] = []
    var fetched: Bool = true
    private var fetching: Bool = false
    
    private var queryResults: [CKRecord] = []
    private var database: CKDatabase?
    private var queryCompletedBlock: ((_ results: [CKRecord]?, _ error: Error?) -> Void)?
    
    var recordType: String
    
    init(recordType: String) {
        self.recordType = recordType
    }
    
    func makeQuery(createdBy creator: CKReference, dataManager: DataManager) {
        if !fetching {
            fetching = true
            queryResults = []
            
            database = dataManager.privateContainer.privateCloudDatabase
            queryCompletedBlock = { (results, error) in
                self.fetched = true
                
                if let queryError = error {
                    Console.shared.print("Error fetching records of type \(self.recordType): \(queryError.localizedDescription)")
                    dataManager.fetchFailed = true
                } else if let fetchedResults = results {
                    self.records = fetchedResults
                }
                
                dataManager.attemptToCompileFetchedRecords()
                
                self.fetching = false
            }
            
            let creatorPredicate = NSPredicate(format: "creatorUserRecordID == %@", creator)
            let basicQuery = CKQuery(recordType: recordType, predicate: creatorPredicate)
            let operation = CKQueryOperation(query: basicQuery)
            
            operation.recordFetchedBlock = self.recordFetched(_:)
            operation.queryCompletionBlock = self.queryOperationCompleted(cursor:error:)
            operation.qualityOfService = QualityOfService.userInitiated
            
            database?.add(operation)
        }
    }
    
    private func recordFetched(_ record: CKRecord) {
        queryResults.append(record)
    }
    
    private func queryOperationCompleted(cursor: CKQueryCursor?, error: Error?) {
        if let queryCursor = cursor {
            let continuingOperation = CKQueryOperation(cursor: queryCursor)
            continuingOperation.recordFetchedBlock = self.recordFetched(_:)
            continuingOperation.queryCompletionBlock = self.queryOperationCompleted(cursor:error:)
            continuingOperation.qualityOfService = QualityOfService.userInitiated

            database?.add(continuingOperation)
        } else {
            self.queryCompletedBlock?(queryResults, error)
        }
    }
    
}

