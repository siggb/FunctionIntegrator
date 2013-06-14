//
//  SecondViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "SecondViewController.h"
#import <math.h>

#define MAX_X 637
#define MAX_Y 240

@interface SecondViewController ()
{
    int x0, y0;
    float w, xn, xm, hx, hy;
}

// Контроллеры
@property (nonatomic, strong) ThirdViewController *thirdVC;

// Графики
@property (nonatomic, weak) IBOutlet WSChart *chart1;
@property (nonatomic, weak) IBOutlet WSChart *chart2;
@property (nonatomic, weak) IBOutlet WSChart *chart3;

// Лэйблы
@property (nonatomic, weak) IBOutlet UILabel *label1;
@property (nonatomic, weak) IBOutlet UILabel *label2;

@end




@implementation SecondViewController

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
    
    self.label1 = nil;
    self.label2 = nil;
}

#pragma mark - Обработка нажатий

- (IBAction)reloadPressed:(id)sender
{
    [self firstPreparing];
    
    // Очищаем области координат
    [self.chart1 removeAllPlots];
    [self.chart2 removeAllPlots];
    [self.chart3 removeAllPlots];
    
    // Вычисляем и перерисовываем графики
    NSArray *dataArrays = [self processIntegrator];
    [self drawFirstPlot:@[dataArrays[0], dataArrays[1], dataArrays[2]]];
    [self drawSecondPlot:dataArrays[3]];
    [self drawThirdPlot:dataArrays[4]];
}

- (IBAction)prevPressed:(id)sender
{
    // переходим к предыдущему контроллеру
    [UIView transitionWithView:self.view.window
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [self.navigationController popViewControllerAnimated:NO];
                    }
                    completion:NULL];
}

- (IBAction)nextPressed:(id)sender
{
    // переходим к следующему контроллеру
    if (self.thirdVC == nil) {
        self.thirdVC = [ThirdViewController controllerWithDefaultNib];
    }
    
    [UIView transitionWithView:self.view.window
                      duration:1.0f
                       options:UIViewAnimationOptionTransitionFlipFromBottom
                    animations:^{
                        [self.navigationController pushViewController:self.thirdVC animated:NO];
                    }
                    completion:NULL];
}

- (IBAction)sliderChanged:(UISlider*)sender
{
    // Вычисление нового предела
    xm = sender.value/1000.f;
    [self.label1 setText:[NSString stringWithFormat:@"%f", xm]];
    
    // Вычисление нового шага
    hx=xm/(MAX_X-x0);
    [self.label2 setText:[NSString stringWithFormat:@"%f", hx]];

    // Очищаем области координат
    [self.chart1 removeAllPlots];
    [self.chart2 removeAllPlots];
    [self.chart3 removeAllPlots];
    
    // Вычисляем и перерисовываем графики
    NSArray *dataArrays = [self processIntegrator];
    [self drawFirstPlot:@[dataArrays[0], dataArrays[1], dataArrays[2]]];
    [self drawSecondPlot:dataArrays[3]];
    [self drawThirdPlot:dataArrays[4]];
}

#pragma mark - Работа с интегратором

- (void)firstPreparing
{
    x0 = 0;          // Позиция начала координат
    y0 = MAX_Y;
    w = 100*M_PI;       // Циклическая частота
    xn = 0;             // Нижний предел интегрирования
    //xm = 0.05;          // Верхний предел интегрирования
    //hx = xm/(MAX_X-x0);   // Шаг интегрирования
    
    hx = 0.0000032;
    xm = (MAX_X-x0) * hx;
    
    hy = [self func:xn]/(y0-2);  // Масштаб графика по Оу
    
    // Визуализация
    for (int i=100; i<1000; i+=100) {
        [[self.view viewWithTag:i] setHidden:NO];
    }
    [self.label1 setText:[NSString stringWithFormat:@"%f", xm]];
    [self.label2 setText:[NSString stringWithFormat:@"%f", hx]];
}

// Вычисление результатов интегрирования
- (NSArray *)processIntegrator
{
    // Переменные эталона
    float sx1=x0+xn/hx;
    float sy1=y0-[self func:xn]/hy;
    float sx2=sx1+1;
    
    // Переменные прямоугольников
    float ry1=1;
    float ry2=cos(w*xn);
    float ry3=sin(w*xn);
    float ry4=ry1*ry1;
    float rdy2=-w*ry3*hx;
    float rdy3=w*ry2*hx;
    float rdy1=rdy2/(3*ry1*ry1);
    float rdy4=2*ry1*rdy1;
    float rya=ry1;
    float erry1=y0-fabs(ry1-[self func:xn])/hy;
    
    // Переменные трапеций
    float ty1=[self func:xn];
    float ty2=cos(w*xn);
    float ty3=sin(w*xn);
    float ty4=ty1*ty1;
    float tdy2=-w*ty3*hx;
    float tdy3=w*ty2*hx;
    float tdy1=tdy2/(3*ty1*ty1);
    float tdy4=2*ty1*tdy1;
    float tya=ty1;
    float erty1=y0-fabs(ry1-[self func:xn])/hy;
    
    // массивы значений
    WSData *data1, *data2, *data3, *data4, *data5;
    
    NSMutableArray *arr1 = [NSMutableArray array];
    NSMutableArray *arr2 = [NSMutableArray array];
    NSMutableArray *arr3 = [NSMutableArray array];
    NSMutableArray *arr4 = [NSMutableArray array];
    NSMutableArray *arr5 = [NSMutableArray array];
    
    NSMutableArray *arr1Y = [NSMutableArray array];
    NSMutableArray *arr2Y = [NSMutableArray array];
    NSMutableArray *arr3Y = [NSMutableArray array];
    NSMutableArray *arr4Y = [NSMutableArray array];
    NSMutableArray *arr5Y = [NSMutableArray array];
    
    for(int i=1; i<=638; i++)
    {        
        // Построение эталона
        float sy2 = y0 - [self func:(xn+i*hx)]/hy;
        if (i == 1) {
            [arr1 addObject:@(sx1)];
            [arr1Y addObject:@(sy1)];
        }        
        [arr1 addObject:@(sx2)];
        [arr1Y addObject:@(sy2)];
        sy1=sy2;
        
        // Интегрирование методом прямоугольников
        ry3+=rdy3;
        rdy2=-w*ry3*hx;
        ry2+=rdy2;
        rdy3=w*ry2*hx;
        ry4+=rdy4;
        rdy1=rdy2/(3*ry4);
        ry1+=rdy1;
        rdy4=2*ry1*rdy1;
        
        // Построение прямоугольников
        int ryb=y0-ry1/hy;
        if (i == 1) {
            [arr2 addObject:@(sx1)];
            [arr2Y addObject:@(rya)];
        }
        [arr2 addObject:@(sx2)];
        [arr2Y addObject:@(ryb)];
        rya=ryb;
        
        // Построение ошибки прямоугольников
        float erry2=y0-fabs(ryb-sy2);
        if (i == 1) {
            [arr4 addObject:@(sx1)];
            [arr4Y addObject:@(erry1)];
        }
        [arr4 addObject:@(sx2)];
        [arr4Y addObject:@(erry2)];
        erry1=erry2;
        
        // Интегрирование методом трапеций
        ty3+=tdy3;
        tdy2=-w*(ty3-tdy3/2)*hx;
        ty2+=tdy2;
        tdy3=w*(ty2-tdy2/2)*hx;
        ty4+=tdy4;
        tdy1=tdy2/(3*(ty4-tdy4/2));
        ty1+=tdy1;
        tdy4=2*(ty1-tdy1/2)*tdy1;
        
        // Построение трапеций
        int tyb=y0-ty1/hy;
        if (i == 1) {
            [arr3 addObject:@(sx1)];
            [arr3Y addObject:@(tya)];
        }
        [arr3 addObject:@(sx2)];
        [arr3Y addObject:@(tyb)];
        tya=tyb;
        
        // Построение ошибки трапеций
        float erty2=y0-fabs(tyb-sy2);
        if (i == 1) {
            [arr5 addObject:@(sx1)];
            [arr5Y addObject:@(erty1)];
        }
        [arr5 addObject:@(sx2)];
        [arr5Y addObject:@(erty2)];
        erty1=erty2;
        
        // Сдвиг по Ох
        sx1+=1;
        sx2+=1;
    }
    
    // трансформация значения абсцисс
    arr1 = [self transformArrX:arr1];
    arr2 = [self transformArrX:arr2];
    arr3 = [self transformArrX:arr3];
    arr4 = [self transformArrX:arr4];
    arr5 = [self transformArrX:arr5];
    
    // трансформация значения ординат
    arr1Y = [self transformArrY:arr1Y];
    arr2Y = [self transformArrY:arr2Y];
    arr3Y = [self transformArrY:arr3Y];
    arr4Y = [self transformArrY:arr4Y];
    arr5Y = [self transformArrY:arr5Y];
    
    // формируем данные для графиков
    data1 = [WSData dataWithValues:[NSArray arrayWithArray:arr1Y] valuesX:[NSArray arrayWithArray:arr1]];
    data2 = [WSData dataWithValues:[NSArray arrayWithArray:arr2Y] valuesX:[NSArray arrayWithArray:arr2]];
    data3 = [WSData dataWithValues:[NSArray arrayWithArray:arr3Y] valuesX:[NSArray arrayWithArray:arr3]];
    data4 = [WSData dataWithValues:[NSArray arrayWithArray:arr4Y] valuesX:[NSArray arrayWithArray:arr4]];
    data5 = [WSData dataWithValues:[NSArray arrayWithArray:arr5Y] valuesX:[NSArray arrayWithArray:arr5]];
    
    NSLog(@"Ошибки прямоугольников:");
    for (int i=0; i<arr4.count; i++) {
        NSLog(@"%e %e", [arr4[i] floatValue], [arr4Y[i] floatValue]);
    }
    
    NSLog(@"\n\nОшибки трапеций:");
    for (int i=0; i<arr5.count; i++) {
        NSLog(@"%e %e", [arr5[i] floatValue], [arr5Y[i] floatValue]);
    }
    
    return @[data1, data2, data3, data4, data5];
}

// Вычисление целевой функции
- (float)func:(float)x
{
    float z=cos(100*M_PI*x);
    if (z>0)
        return pow(cos(100*M_PI*x),1.f/3.f);
    else
        return -pow(fabs(cos(100*M_PI*x)),1.f/3.f);
}

// Трансформация значения абсцисс
- (NSMutableArray*)transformArrX:(NSMutableArray*)arr
{
    float koef = MAX_X/xm;
    NSMutableArray *t_arr = [NSMutableArray array];
    for (NSNumber *elem in arr) {
        [t_arr addObject:@(elem.floatValue / koef)];
    }
    return t_arr;
}

// Трансформация значения ординат
- (NSMutableArray*)transformArrY:(NSMutableArray*)arr
{
    NSMutableArray *t_arr_y = [NSMutableArray array];
    for (NSNumber *elem in arr) {
        [t_arr_y addObject:@(-(elem.floatValue - MAX_Y)/MAX_Y)];
    }
    return t_arr_y;
}

#pragma mark - Построение графиков

- (void)drawFirstPlot:(NSArray *)dataArr
{
    // Формируем 1 график по данным
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart1 frame]
                                           data:dataArr[0]
                                          style:kChartLinePlain
                                      axisStyle:kCSGrid
                                    colorScheme:kColorLight
                                         labelX:@""
                                         labelY:@""];
    
    // Добавляем 2 график на плоскость координат
    [self.chart1 addPlotsFromChart:chart];
    [self.chart1 generateControllerWithData:dataArr[1]
                                  plotClass:[WSPlotData class]
                                      frame:self.chart1.frame];
    WSPlotData *line2 = (WSPlotData *)[self.chart1 lastPlot].view;
    
    // Добавляем 3 график на плоскость координат
    [self.chart1 addPlotsFromChart:chart];
    [self.chart1 generateControllerWithData:dataArr[2]
                                  plotClass:[WSPlotData class]
                                      frame:self.chart1.frame];
    WSPlotData *line3 = (WSPlotData *)[self.chart1 lastPlot].view;
    
    line2.lineColor = [UIColor blackColor];
    line3.lineColor = [UIColor blueColor];
    line2.propDefault.symbolStyle = kSymbolNone;
    line3.propDefault.symbolStyle = kSymbolNone;
    
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
                                          style:kChartLinePlain
                                      axisStyle:kCSGrid
                                    colorScheme:kColorLight
                                         labelX:@""
                                         labelY:@""];
    
    [chart autoscaleAllAxisX];
    [chart autoscaleAllAxisY];
    
    [chart setAllAxisLocationXD:0.0];
    [chart setAllAxisLocationYD:0.0];
    
    // Добавляем графики на плоскость координат
    [self.chart2 addPlotsFromChart:chart];
}

- (void)drawThirdPlot:(WSData *)data
{
    // Формируем график по данным
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart3 frame]
                                           data:data
                                          style:kChartLinePlain
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
