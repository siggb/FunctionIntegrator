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
    // Наборы данных кривых
    WSChart *graphics[4];
    
    // Переменные
    NSInteger y, x0, xn, k, dx, scale, accuracy, r, n;
    float step;
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
        // Custom initialization
    }
    return self;
}

#pragma mark - View Lifecicle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

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
    @try {
        // считываем значения полей
        k = self.firstTF.text.integerValue;
        y = self.secondTF.text.integerValue;
        x0 = self.thirdTF.text.integerValue;
        xn = self.thougthTF.text.integerValue;
        
        step = 0.1;
        accuracy = 6;
        scale = 1;
        
        // формируем значения переменных
        for (int i=0; i<([[NSString stringWithFormat:@"%g",(step - floor(step))] length]-2); i++) {
            scale *= 10;
        }
        if ((scale*step - 1) < 0.001) {
            scale *= 10;
        }
        
        dx = step * scale;
        
        // расчет количества разрядов под приращение
        r = floor(log(step*scale)/log(2)) + 1;
        
        // расчет количества разрядов под остаток
        n = floor(log(10)*accuracy/log(2)) + 1;
        
        NSLog(@"step=%f, accuracy=%d, scale=%d, r=%d, n=%d, dx=%d", step, accuracy, scale, r, n, dx);
        
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
        [self trapezoidMethod];
    }
    
    // рисуем графики
    [self drawFirstPlot:@[dataArrays[0], dataArrays[1]]];
    [self drawSecondPlot:dataArrays[3]];
    [self drawThirdPlot:dataArrays[2]];
}

- (NSArray *)rectangleMethod
{
    NSInteger x = x0;
    WSData *data1, *data2, *data3, *data4;
    
    NSMutableArray *arr1, *arr2, *arr3, *arr4 = [NSMutableArray array];
    NSMutableArray *arr1Y, *arr2Y, *arr3Y, *arr4Y = [NSMutableArray array];
    
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
        
        [arr4 addObject:@(x/scale)];
        [arr4Y addObject:@(buf/scale)];
        
        // переходим к следующей абсциссе
        x += dx;
        
        // точки графиков
        [arr3 addObject:@(x/scale)];
        [arr3Y addObject:@(integral/scale - k*(x/scale))];
        
        [arr4 addObject:@(x/scale)];
        [arr4Y addObject:@(buf/scale)];
        
    } while (x <= xn);
    
    // формируем данные для графиков
    data1 = [WSData dataWithValues:[NSArray arrayWithArray:arr1Y] valuesX:[NSArray arrayWithArray:arr1]];
    data2 = [WSData dataWithValues:[NSArray arrayWithArray:arr2Y] valuesX:[NSArray arrayWithArray:arr2]];
    data3 = [WSData dataWithValues:[NSArray arrayWithArray:arr3Y] valuesX:[NSArray arrayWithArray:arr3]];
    data4 = [WSData dataWithValues:[NSArray arrayWithArray:arr4Y] valuesX:[NSArray arrayWithArray:arr4]];
    
    return @[data1, data2, data3, data4];
}

- (void)trapezoidMethod
{
    
}

#pragma mark - Построение графиков

- (void)drawFirstPlot:(NSArray *)dataArr
{
    int i = 0;
    [self.chart1 removeAllPlots];
    
    for (WSData *data_i in dataArr) {
        // Формируем график по данным
        graphics[i] = [WSChart linePlotWithFrame:[self.chart1 frame]
                                            data:data_i
                                           style:kChartLineGradient
                                       axisStyle:kCSGrid
                                     colorScheme:kColorLight
                                          labelX:@""
                                          labelY:@""];
        [graphics[i] setAllAxisLocationToOriginXD];
        [graphics[i] setAllAxisLocationToOriginYD];
        
        // Добавляем графики на плоскость координат
        [self.chart1 addPlotsFromChart:graphics[i]];
        i++;
    }
}

- (void)drawSecondPlot:(WSData *)data
{
    // Формируем график по данным
    graphics[2] = [WSChart linePlotWithFrame:[self.chart2 frame]
                                        data:data
                                       style:kChartLineGradient
                                   axisStyle:kCSGrid
                                 colorScheme:kColorLight
                                      labelX:@""
                                      labelY:@""];
    [graphics[2] setAllAxisLocationXD:1.328];
    [graphics[2] setAllAxisLocationYD:-0.1];
    
    // Добавляем графики на плоскость координат
    [self.chart2 removeAllPlots];
    [self.chart2 addPlotsFromChart:graphics[2]];
}

- (void)drawThirdPlot:(WSData *)data
{
    // Формируем график по данным
    graphics[3] = [WSChart linePlotWithFrame:[self.chart3 frame]
                                        data:data
                                       style:kChartLineGradient
                                   axisStyle:kCSGrid
                                 colorScheme:kColorLight
                                      labelX:@""
                                      labelY:@""];
    [graphics[3] setAllAxisLocationToOriginXD];
    [graphics[3] setAllAxisLocationToOriginYD];
    
    // Добавляем графики на плоскость координат
    [self.chart3 removeAllPlots];
    [self.chart3 addPlotsFromChart:graphics[3]];
}

@end
