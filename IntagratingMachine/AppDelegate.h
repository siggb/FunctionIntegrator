//
//  AppDelegate.h
//  IntagratingMachine
//
//  Created by sig on 29.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) UINavigationController *mainNaviController;

@property (strong, nonatomic) FirstViewController *viewController;

@end
