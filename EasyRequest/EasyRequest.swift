//
//  EasyRequest.swift
//  EasyRequest
//
//  Created by alvin zheng on 17/10/12.
//  Copyright © 2017年 alvin. All rights reserved.
//
// 所有和远端交互的异步请求封装，可以链式调用

import Foundation


//消息或者负载
public protocol Message {
    var identifer: String { get }
}

/*
 发送的请求,
 此类作为所有和remote交互的请求和返回封装。
 */
public class EasyRequest<Op, Result>: Equatable {
    public let operation: Op
    lazy public var response: EasyResponse<Op, Result> = {
        return EasyResponse(op: self.operation)
    }()
    public var message: Message?

    init(op: Op) {
        operation = op
    }

    public static func ==(lhs: EasyRequest, rhs: EasyRequest) -> Bool {
        return lhs.message?.identifer == rhs.message?.identifer
    }
}

/*
 all of the request's response format
 Op, the operation， setting， or message
 Result, the expected result from mqtt
 所有请求的返回抽象
 */
public class EasyResponse<Op, Result> {
    public typealias ProcessionBlock = (Op) -> Void
    public typealias FinishBlock = (Op, Result) -> Void
    public typealias ErrorBlock = (Error) -> Void //error can be your custom error type

    fileprivate var processingCallback: ProcessionBlock?
    fileprivate var finishedCallback: FinishBlock?
    fileprivate var errorCallback: ErrorBlock?

    public let operation: Op

    init(op: Op ) {
        operation = op
    }

    /*
     user call these to add call back
     */
    @discardableResult
    public func onProcessing(_ handle: @escaping ProcessionBlock) -> EasyResponse {
        processingCallback = handle
        return self
    }

    @discardableResult
    public func onFinshed(_ handle: @escaping FinishBlock) -> EasyResponse {
        finishedCallback = handle
        return self
    }

    @discardableResult
    public func onError(_ handle: @escaping ErrorBlock) -> EasyResponse {
        errorCallback = handle
        return self
    }
    /*
     the request excutor(request manager) call this when finished the request
     to call user's call back.
     */
    func handleProcessing(_ op: Op) {
        processingHook.forEach({$0(op)})
        processingCallback?(op)
    }

    func handleFinished(_ op: Op, _ result: Result) {
        finishHook.forEach({$0(op, result)})
        finishedCallback?(op, result)
    }

    func handleError(_ err: Error) {
        errorHook.forEach({$0(err)})
        errorCallback?(err)
    }

    /* internal useage, (for request manager,excutor, or etc.)
     response will call these before calling user's callbacks
     use these to add custom hooks of response
     */
    private var processingHook: [ProcessionBlock] = []
    private var finishHook: [FinishBlock] = []
    private var errorHook: [ErrorBlock] = []

    func addProssessingHook(process: @escaping ProcessionBlock) {
        processingHook.append(process)
    }

    func addFinishHook(process: @escaping FinishBlock) {
        finishHook.append(process)
    }

    func addErrorHook(process: @escaping ErrorBlock) {
        errorHook.append(process)
    }
}
