//
//  RequestResponderChain.swift
//  EasyRequest
//
//  Created by alvin zheng on 17/10/12.
//  Copyright © 2017年 alvin. All rights reserved.
//

import Foundation

/*
 default request responder chain.
 to mannager responder.
 */
class ReqResponderChain<Op, Result> {

    typealias V = EasyRequest<Op, Result> //响应链处理的值类型
    typealias R = ReqResponder<Op, Result> //响应者类型

    private var first: R

    required init(first: R) {
        self.first = first
    }

    func getFirst() -> R {
        return first
    }

    /*
     寻址链尾
     */
    func getLast() -> R {
        var last: R = self.first
        var next = last.next
        while next != nil {
            last = next!
            next = next!.next
        }
        return last
    }

    // the last appended be the first
    //最后加的，最先执行
    func append(responder: R) {
        responder.next = responder
        self.first = responder
    }

    func handle(value: V) {
        self.first.handle(value: value)
    }
}
