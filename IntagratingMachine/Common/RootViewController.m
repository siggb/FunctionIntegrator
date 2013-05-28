//
//  RootViewController.m
//
//  Created by tyler on 14.03.13.
//  Copyright (c) 2012 ru.digipeople. All rights reserved.
//

#import "RootViewController.h"

@implementation RootViewController

#pragma mark - Инициализация

/*
 * Используйте этот метод для инициализации полей дочерних контроллеров
 */
- (void)initialize
{
    //...
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (id)initWithDefaultNib
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (self) {
        [self initialize];
    }
    return self;
}

+ (id)controllerWithDefaultNib
{
    id object = [[self.class alloc] initWithNibName:NSStringFromClass(self.class) bundle:nil];
    if (object) {
        [object initialize];
    }
    return object;
}

#pragma mark - Autorotation

- (BOOL)shouldAutorotate
{
    return YES;
}

/*
 * Поворот экрана для ios 5
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

/*
 * Поворот экрана для ios 6
 */
- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - View lifecicle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // установка локализованных строк
    [self setLocalisedStrings];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // позиционирование элементов под нужную ориентацию устройства
    [self willRotateToInterfaceOrientation:[self interfaceOrientation] duration:1.f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //[[LocalyticsManager instance] sendEvent:THIS_METHOD from:NSStringFromClass(self.class)];
}

// Установка локализованных строк
- (void)setLocalisedStrings
{
    // define me
}

#pragma mark - Управление памятью

- (void)didReceiveMemoryWarning
{
    //NSLog(@"%@. %@", NSStringFromClass(self.class), THIS_METHOD);
    
    //[[LocalyticsManager instance] sendEvent:THIS_METHOD from:NSStringFromClass(self.class)];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - UserActivity Delegate

/*
 * Обработчик сообщения об авторизации пользователя
 */
- (void)onUserLoginNotification:(NSNotification *)notification
{
    // override me
}

/*
 * Обработчик сообщения о логауте пользователя
 */
- (void)onUserLogoutNotification:(NSNotification *)notification
{
    // override me
}

/*
 * Обработчик сообщения о смене активного профиля пользователя
 */
- (void)onUserSwitchProfileNotification:(NSNotification *)notification
{
    // override me
}

#pragma mark - Индикация загрузки данных

- (void)showLoading
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - Методы работы с Picker view

// Скрываем/показываем слой с барабаном и кнопками
- (void)showPicker:(UIView*)viewForPicker show:(BOOL)show
{
    CGRect frame = viewForPicker.frame;
    frame.origin.y = show ? 216 : 480;
    
    [UIView animateWithDuration:0.5 animations:^{
        viewForPicker.frame = frame;
    }];
}

#pragma mark - Методы для работы с поворотами экрана

- (BOOL)isPortraitOrientation
{    
    return [self isPortraitOrientation:[self interfaceOrientation]];
}

- (BOOL)isPortraitOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{    
    return ((toInterfaceOrientation == UIInterfaceOrientationPortrait)
            || (toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown));
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // define me
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // define me
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    // define me
}

@end




