//
//  ThirdViewController.h
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "RootViewController.h"

@interface ThirdViewController : RootViewController

/*
 Здесь нам удалось минимизировать:
 - погрешность квантования
 - погрешность методическую (в незначительной мере)
 
 Погрешность исходных данных и инструментальную погрешность
 находятся в допустимом диапазоне yE-6 благодаря используемому
 типу данных float с мантиссой в 24 бита.
 (порядок 8 бит и 1 скрытый знаковый бит)
 */

@end
