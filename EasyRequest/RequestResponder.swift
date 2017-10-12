//
//  RequestResponder.swift
//  EasyRequest
//
//  Created by alvin zheng on 17/10/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation

/*
 responder chain definnation
 */

protocol Responder {
    associatedtype Value
    func handle(value: Value)
    var next: Self? { get set}
}

/*
 EasyRequest Responder chain defination
 */
protocol RequestResponder: Responder {
    associatedtype Operation
    associatedtype R
    associatedtype Value = EasyRequest<Operation, R>

    //是否贯穿， true 不会截断，false 截断
    var throughout: Bool {get set}

    var handler: (Value) -> Void {get set}
}

extension RequestResponder {
    func handle(value: Self.Value) {
        self.handler(value)
        if throughout {
            self.next?.handle(value: value)
        }
    }
}

/*
 default request responder.
 */

final class ReqResponder<Op, Result>: RequestResponder {

    typealias Operation = Op
    typealias R = Result

    typealias Value = EasyRequest<Op, Result>

    var next: ReqResponder<Op, Result>?

    //默认不会截断数据流
    var throughout = true

    var handler: (Value) -> Void = {_ in }
}

//final class FocusResponder: RequestResponder {
//    typealias Operation = FocusSetting
//    typealias R = Bool
//    typealias Value = SioRequest<Operation, R>
//}

