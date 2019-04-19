//
//  Functions.swift
//  ARTanks
//
//  Created by Полин К.С. on 15.03.2019.
//  Copyright © 2019 Tensor. All rights reserved.
//

public func clamp<T>(_ value: T, _ minValue: T, _ maxValue: T) -> T where T: Comparable {
	return min(max(value, minValue), maxValue)
}
