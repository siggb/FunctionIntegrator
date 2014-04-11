//
//  RootViewController.h
//  IntagratingMachine
//
//  Created by sig on 29.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

/** Базовый View-контроллер для *всех* экранов в проекте
 
 Содержит:
 - кастомные конструкторы для сокращенной формы записи при создании новых экземпляров;
 - базовые методы для индикации загрузки данных;
 - различные часто используемые методы.
 
 Реализует протокол UserActivityDelegate, чьи методы позволяют отслеживать макро-действия пользователя (логин, логаут, переключение профиля, etc.).
 
 */
@interface RootViewController : UIViewController 

/** @name Методы инициализации
 
 Вспомогательные методы для инициализации контроллеров (позволяют писать меньше кода при создании новых экземпляров).
 Являются обертками над методом initWithNibName:bundle:
 */
- (id)initWithDefaultNib;
+ (id)controllerWithDefaultNib;

/** Универсальный метод для инициализации полей дочерних контроллеров.
 
 Логика инициализации каждого контроллера должна прописываться именно в этом методе.
 */
- (void)initialize;


/** @name Методы для отображения/скрытия индикация при загрузке и обработке данных */

/** Отображение индикатор загрузки данных из сети (показывается в статус-баре) */
- (void)showLoading;
/** Отображение индикатора поверх всего экрана */
- (void)showScreenLoading;
/** Отображение индикатора с заданным текстом поверх всего экрана */
- (void)showLoadingText:(NSString*)text;
/** Скрытие всех индикаторов */
- (void)hideLoading;


/** Методы протокола UserActivityDelegate */

/** Обработчик сообщения об авторизации пользователя */
- (void)onUserLoginNotification:(NSNotification *)notification;

/** Обработчик сообщения о логауте пользователя */
- (void)onUserLogoutNotification:(NSNotification *)notification;


/** @name Общие методы для работы с сетью */

/** Стандартная обработка ситуации с ошибкой запроса к серверу */
- (void)processRequestFailure:(NSError*)error;


/** @name Методы для работы с subviews */

/** Отображение/скрытие барабана
 
 @param viewForPicker - элемент, который содержит барабан
 @param show - признак того, нужно ли элемент скрыть или же показать
 */
- (void)showPicker:(UIView*)viewForPicker show:(BOOL)show;

/** Метод установки локализованных строк в элементы котроллера */
- (void)setLocalisedStrings;

/** Метод, сигнализирующий о текущей портретной ориентации устройства */
- (BOOL)isPortraitOrientation;

/** Метод, сигнализирующий о выставляемой портретной ориентации устройства */
- (BOOL)isPortraitOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

/** Методы, сигнализирующие о поворотах экрана и требующие определения в потомках */
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

@end
