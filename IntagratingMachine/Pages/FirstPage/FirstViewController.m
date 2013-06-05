//
//  FirstViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "FirstViewController.h"
#import "RCSwitchClone.h"
#import "RCSwitchClone2.h"

@interface FirstViewController ()
{    
    // Переменные
    int scale;
    float step;
    int8_t accuracy, r, n;
    int32_t y, x0, xn, k, dx;
    int64_t buf, integral;
}

// Графики
@property (nonatomic, weak) IBOutlet WSChart *chart1;
@property (nonatomic, weak) IBOutlet WSChart *chart2;
@property (nonatomic, weak) IBOutlet WSChart *chart3;

// Поля ввода
@property (nonatomic, weak) IBOutlet UITextField *firstTF;
@property (nonatomic, weak) IBOutlet UITextField *secondTF;
@property (nonatomic, weak) IBOutlet UITextField *thirdTF;
@property (nonatomic, weak) IBOutlet UITextField *thougthTF;

// Свитчеры
@property (nonatomic, weak) IBOutlet RCSwitchClone *firstSwitch;
@property (nonatomic, weak) IBOutlet RCSwitchClone2 *secondSwitch;

// Контроллеры
@property (nonatomic, strong) SecondViewController *secondVC;

@end




@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // nothing
    }
    return self;
}

#pragma mark - View Lifecicle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.chart1 removeAllPlots];
    [self.chart2 removeAllPlots];
    [self.chart3 removeAllPlots];
    
    self.chart1 = nil;
    self.chart2 = nil;
    self.chart3 = nil;
    
    self.firstSwitch = nil;
    self.secondSwitch = nil;
    
    self.firstTF = nil;
    self.secondTF = nil;
    self.thirdTF = nil;
    self.thougthTF = nil;
}

#pragma mark - Обработка нажатий

- (IBAction)reloadPressed:(id)sender
{
    [self firstPreparing];
    
    @try {
        // считываем значения полей
        k = self.firstTF.text.integerValue;
        y = self.secondTF.text.integerValue;
        x0 = self.thirdTF.text.integerValue;
        xn = self.thougthTF.text.integerValue;
        
        [self processIntegrator];
    }
    @catch (NSException *exception) {
        // transform error
    }
}

- (IBAction)nextPressed:(id)sender
{
    // переходим к следующему контроллеру
    if (self.secondVC == nil) {
        self.secondVC = [SecondViewController controllerWithDefaultNib];
    }
    
    [UIView transitionWithView:self.view.window
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [self.navigationController pushViewController:self.secondVC animated:NO];
                    }
                    completion:NULL];
}

#pragma mark - Работа с интегратором

- (void)firstPreparing
{
    // Показываем заголовки графиков
    [[self.view viewWithTag:100] setHidden:NO];
    [[self.view viewWithTag:200] setHidden:NO];
    [[self.view viewWithTag:300] setHidden:NO];
    
    // Начальные уставки
    step = 0.1;
    accuracy = 6;
    scale = 1;
    buf = 0;
    integral = 0;
    
    // Формируем значения переменных
    for (int i=0; i<([[NSString stringWithFormat:@"%g",(step - floor(step))] length]-2); i++) {
        scale *= 10;
    }
    if ((scale*step - 1) < 0.001) {
        scale *= 10;
    }
    
    dx = step * scale;
    
    // Расчет количества разрядов под приращение
    r = floor(log(step*scale)/log(2)) + 1;
    
    // Расчет количества разрядов под остаток
    n = floor(log(10)*accuracy/log(2)) + 1;
    
    NSLog(@"step=%f, accuracy=%d, scale=%d, r=%d, n=%d, dx=%d", step, accuracy, scale, r, n, dx);
}

- (void)processIntegrator
{
    y *= scale;
    x0 *= scale;
    xn *= scale;
    
    NSLog(@"k=%d, y=%d, x0=%d, xn=%d", k, y, x0, xn);
    
    NSArray *dataArrays = nil;
    
    if (self.firstSwitch.isOn) {
        // выбран метод прямоугольников
        dataArrays = [self rectangleMethod];
    }
    else {
        // выбран метод трапеций
        dataArrays = [self trapezoidMethod];
    }
    
    // очищаем области координат
    [self.chart1 removeAllPlots];
    [self.chart2 removeAllPlots];
    [self.chart3 removeAllPlots];
    
    // рисуем графики
    [self drawFirstPlot:@[dataArrays[0], dataArrays[1]]];
    [self drawSecondPlot:dataArrays[3]];
    [self drawThirdPlot:dataArrays[2]];
}

- (NSArray *)rectangleMethod
{
    NSInteger x = x0;
    WSData *data1, *data2, *data3, *data4;
    
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    NSMutableArray *arr3 = [NSMutableArray array];
    NSMutableArray *arr4 = [NSMutableArray array];
    
    NSMutableArray *arr1Y = [NSMutableArray array];
    NSMutableArray *arr2Y = [NSMutableArray array];
    NSMutableArray *arr3Y = [NSMutableArray array];
    NSMutableArray *arr4Y = [NSMutableArray array];
    
    do {
        // точки графиков
        [arr1 addObject:@(x/scale)];
        [arr1Y addObject:@(integral/scale)];
        
        [arr4 addObject:@(x/scale)];
        [arr4Y addObject:@(buf/scale)];
        
        // формула прямоугольников
        int64_t temp = k * dx;
        
        // расчет количества разрядов под остаток
        n = floor(log(k)/log(2)) + 1;
        
        if (self.secondSwitch.isOn) {
            // интегрирование с учетом остатка
            temp += buf;
        }
        
        // вычисляем новый остаток
        buf = temp;
        buf = buf << (64-n); // остаток перешел в старшую часть
        buf = buf >> (64-n); // остаток перешел в младную часть
        
        // отбрасываем остаток от значения интеграла
        temp = temp >> n;
        temp = temp << n;
        
        // аккумулирование остатка
        integral += temp;
        
        // точки графиков
        [arr1 addObject:@(x/scale)];
        [arr1Y addObject:@(integral/scale)];
        
        [arr2 addObject:@(x/scale)];
        [arr2Y addObject:@(y + k*(x/scale))];
        
        [arr3 addObject:@(x/scale)];
        [arr3Y addObject:@(integral/scale - k*(x/scale))];
        
        [arr4 addObject:[NSNumber numberWithDouble:x/scale]];
        [arr4Y addObject:@(buf/scale)];
        
        // переходим к следующей абсциссе
        x += dx;
        
        // точки графиков
        [arr3 addObject:@(x/scale)];
        [arr3Y addObject:@(integral/scale - k*(x/scale))];
        
        [arr4 addObject:@(x/scale)];
        [arr4Y addObject:@(buf/scale)];
        
    } while (x <= xn);
    
    NSLog(@"arr1 = %@, \n\n\narr1Y = %@", arr1, arr1Y);
    
    // формируем данные для графиков
    data1 = [WSData dataWithValues:[NSArray arrayWithArray:arr1Y] valuesX:[NSArray arrayWithArray:arr1]];
    data2 = [WSData dataWithValues:[NSArray arrayWithArray:arr2Y] valuesX:[NSArray arrayWithArray:arr2]];
    data3 = [WSData dataWithValues:[NSArray arrayWithArray:arr3Y] valuesX:[NSArray arrayWithArray:arr3]];
    data4 = [WSData dataWithValues:[NSArray arrayWithArray:arr4Y] valuesX:[NSArray arrayWithArray:arr4]];
    
    return @[data1, data2, data3, data4];
}

- (NSArray *)trapezoidMethod
{
    // TODO: сделать
    return [NSArray array];
}

#pragma mark - Построение графиков

- (void)drawFirstPlot:(NSArray *)dataArr
{    
    // Формируем 1 график по данным
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart1 frame]
                                        data:dataArr[0]
                                       style:kChartLineScientific
                                   axisStyle:kCSGrid
                                 colorScheme:kColorLight
                                      labelX:@""
                                      labelY:@""];
    
    // Добавляем 2 график на плоскость координат
    [self.chart1 addPlotsFromChart:chart];    
    [self.chart1 generateControllerWithData:dataArr[1]
                                  plotClass:[WSPlotData class]
                                      frame:self.chart1.frame];
    
    [self.chart1 autoscaleAllAxisX];
    [self.chart1 autoscaleAllAxisY];
    [self.chart1 setAllAxisLocationXD:0.0];
    [self.chart1 setAllAxisLocationYD:0.0];
}

- (void)drawSecondPlot:(WSData *)data
{
    // Формируем график по данным
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart2 frame]
                                           data:data
                                          style:kChartLineScientific
                                      axisStyle:kCSGrid
                                    colorScheme:kColorLight
                                         labelX:@""
                                         labelY:@""];
    
    [chart setAllAxisLocationXD:1.328];
    [chart setAllAxisLocationYD:-0.1];
    
    [chart autoscaleAllAxisX];
    [chart autoscaleAllAxisY];
    
    // Добавляем графики на плоскость координат
    [self.chart2 addPlotsFromChart:chart];
}

- (void)drawThirdPlot:(WSData *)data
{
    // Формируем график по данным
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart3 frame]
                                           data:data
                                          style:kChartLineScientific
                                      axisStyle:kCSGrid
                                    colorScheme:kColorLight
                                         labelX:@""
                                         labelY:@""];
    [chart autoscaleAllAxisX];
    [chart autoscaleAllAxisY];
    
    [chart setAllAxisLocationXD:0.0];
    [chart setAllAxisLocationYD:0.0];
    
    // Добавляем графики на плоскость координат
    [self.chart3 addPlotsFromChart:chart];
}

@end
