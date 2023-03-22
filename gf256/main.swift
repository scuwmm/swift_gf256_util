//
//  main.swift
//  Test
//
//  Created by zhurukeji on 2023/3/22.
//

import Foundation

//邮箱+密码 生成的16位byte
let y_1: [UInt8] = [83,48,19,14,134,79,32,156,115,183,22,87,50,151,58,197];
//生成助记词的16位byte
let y0: [UInt8] = [54,98,189,49,1,148,35,116,96,13,135,214,46,133,187,70];

//生成守护码
let gdc = calGDC(y_1: y_1, y0: y0)
print("#####")
print("#####")
print("#####")
//生成熵（助记词）
let entropy = calEntropy(y_1: y_1, y1: gdc)


//生成守护码
func calGDC(y_1: [UInt8], y0: [UInt8]) -> [UInt8]{
    if y_1.count < 16 || y0.count < 16 {
        fatalError("y_1/y0 length should be greater than 16")
    }
    
    //初始化有限域
    let f = Field(poly: 0x11d, alpha: 2);
    
    let leftArr = y_1[(y_1.count-16)...]//取后16位
    let midArr = y0[(y0.count - 16)...]//取后16位
    var rightArr = [UInt8](repeating: 1, count: 16);
    
    for idx in 0..<leftArr.count {
        let left = leftArr[idx];
        let mid = midArr[idx];
        let add = f.add(x: left, y: mid);
        let right = f.mul(x: add, y: f.inv(x: 0x2))
        rightArr[idx] = right;
//        print(rightArr[idx]);
    }
    return rightArr;
}

//生成熵（助记词）
func calEntropy(y_1: [UInt8], y1: [UInt8]) -> [UInt8] {
    if y_1.count < 16 || y1.count < 16 {
        fatalError("y_1/y1 length should be greater than 16")
    }
    
    //初始化有限域
    let f = Field(poly: 0x11d, alpha: 2);
    
    let leftArr = y_1[(y_1.count-16)...] //取后16位
    let rightArr = y1[(y1.count - 16)...] //取后16位
    var midArr = [UInt8](repeating: 1, count: 16);
    
    for idx in 0..<leftArr.count {
        let left = leftArr[idx];
        let right = rightArr[idx];
        let mul = f.mul(x: right, y: 0x2);
        let mid = f.add(x: mul, y: left)
        midArr[idx] = mid;
//        print(midArr[idx]);
    }
    
    return midArr;
    
}



