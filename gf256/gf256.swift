//
//  gf256_2.swift
//  Test
//
//  Created by scumm on 2023/3/21.
//


import Foundation

class Field {
    private var log: [UInt8] = Array(repeating: 0, count: 256)
    private var exp: [UInt8] = Array(repeating: 0, count: 510)
    
    init(poly: Int, alpha: Int) {
        guard poly >= 0x100 && poly < 0x200 && !reducible(p: poly) else {
            fatalError("gf256: invalid polynomial: \(poly)")
        }
        
        var x = 1
        for i in 0..<255 {
            if x == 1 && i != 0 {
                fatalError("gf256: invalid generator \(alpha) for polynomial \(poly)")
            }
            exp[i] = UInt8(x)
            exp[i+255] = UInt8(x)
            log[x] = UInt8(i)
            x = mul(x: x, y: alpha, poly: poly)
        }
        log[0] = 255
        for i in 0..<255 {
            if log[Int(exp[i])] != UInt8(i) {
                fatalError("bad log")
            }
            if log[Int(exp[i+255])] != UInt8(i) {
                fatalError("bad log")
            }
        }
        for i in 1..<256 {
            if exp[Int(log[i])] != UInt8(i) {
                fatalError("bad log")
            }
        }
    }
    
    private func nbit(p: Int) -> UInt {
        var n: UInt = 0
        var p = p
        while p > 0 {
            n += 1
            p >>= 1
        }
        return n
    }
    
    private func polyDiv(p: Int, q: Int) -> Int {
        var p1 = p
        var np = nbit(p: p1)
        let nq = nbit(p: q)
        while np >= nq {
            if (p1 & (1<<(np-1))) != 0 {
                p1 ^= q << (np - nq)
            }
            np -= 1
        }
        return p1
    }
    
    private func mul(x: Int, y: Int, poly: Int) -> Int {
        var x = x
        var y = y
        var z = 0
        while x > 0 {
            if (x & 1) != 0 {
                z ^= y
            }
            x >>= 1
            y <<= 1
            if (y & 0x100) != 0 {
                y ^= poly
            }
        }
        return z
    }
    
    private func reducible(p: Int) -> Bool {
        let np = nbit(p: p)
        for q in 2..<(1<<(np/2+1)) {
            if polyDiv(p: p, q: q) == 0 {
                return true
            }
        }
        return false
    }
    
    func add(x: UInt8, y: UInt8) -> UInt8 {
        return x ^ y
    }
    
    // If e < 0, Exp returns 0.
    func exp(e: Int) -> UInt8 {
        if e < 0 {
            return 0
        }
        return exp[e%255]
    }
    
    func log(x: UInt8) -> Int {
        if x == 0 {
            return -1
        }
        return Int(log[Int(x)])
    }
    
    func inv(x: UInt8) -> UInt8 {
        if x == 0 {
            return 0
        }
        return exp(e: 255 - log(x: x))
    }
    
    func mul(x: UInt8, y: UInt8) -> UInt8 {
        if x == 0 || y == 0 {
            return 0
        }
        return exp[Int(log(x: x)) + Int(log(x: y))]
    }
}




