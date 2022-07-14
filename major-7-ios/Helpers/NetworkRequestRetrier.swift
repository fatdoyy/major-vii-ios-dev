//
//  NetworkRequestsRetrier.swift
//  major-7-ios
//
//  Created by jason on 27/11/2019.
//  Copyright © 2019 Major VII. All rights reserved.
//

import Alamofire

class NetworkRequestRetrier: RequestInterceptor {
    
    // [Request url: Number of times retried]
    private var retriedRequests: [String: Int] = [:]

    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        guard
            request.task?.response == nil,
            let url = request.request?.url?.absoluteString
        else {
            removeCachedUrlRequest(url: request.request?.url?.absoluteString)
            completion(.doNotRetry)
            return
        }
        
        let errorGenerated = error as NSError
        switch URLError.Code(rawValue: errorGenerated.code) {
        case .timedOut, .notConnectedToInternet, .cannotConnectToHost, .networkConnectionLost:
            guard let retryCount = retriedRequests[url] else {
                retriedRequests[url] = 1
                completion(.retryWithDelay(3)) // retry after 3 second
                print("Retrying request...")
                return
            }
            
            if retryCount < Int.max {
                retriedRequests[url] = retryCount + 1
                completion(.retryWithDelay(3)) // retry after 3 second
                print("Retrying request... (\(retryCount))")
            } else {
                removeCachedUrlRequest(url: url)
                completion(.doNotRetry) // don't retry
            }
            
        default:
            print("error code does not match with cases")
            removeCachedUrlRequest(url: url)
            completion(.doNotRetry)
        }
    }
    
    
//    func should(_ manager: Session,
//                retry request: Request,
//                with error: Error,
//                completion: @escaping RequestRetryCompletion) {
//
//        guard
//            request.task?.response == nil,
//            let url = request.request?.url?.absoluteString
//        else {
//            removeCachedUrlRequest(url: request.request?.url?.absoluteString)
//            completion(false, 0.0) // don't retry
//            return
//        }
//
//        let errorGenerated = error as NSError
//        switch URLError.Code(rawValue: errorGenerated.code) {
//        case .timedOut, .notConnectedToInternet, .cannotConnectToHost, .networkConnectionLost:
//            guard let retryCount = retriedRequests[url] else {
//                retriedRequests[url] = 1
//                completion(true, 3) // retry after 3 second
//                print("Retrying request...")
//                return
//            }
//
//            if retryCount < Int.max {
//                retriedRequests[url] = retryCount + 1
//                completion(true, 3) // retry after 3 second
//                print("Retrying request... (\(retryCount))")
//            } else {
//                removeCachedUrlRequest(url: url)
//                completion(false, 0.0) // don't retry
//            }
//
//        default:
//            print("error code does not match with cases")
//            removeCachedUrlRequest(url: url)
//            completion(false, 0.0)
//        }
//    }
    
    private func removeCachedUrlRequest(url: String?) {
        guard let url = url else {
            return
        }
        retriedRequests.removeValue(forKey: url)
    }
}
