//
//  SecondViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "SecondViewController.h"
#import <math.h>

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

@end




@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self firstPreparing];
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
}

#pragma mark - Обработка нажатий

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

#pragma mark - Работа с интегратором

- (void)firstPreparing
{
    x0 = 30;          // Позиция начала координат
    y0 = 240;
    w = 100*M_PI;       // Циклическая частота
    xn = 0;             // Нижний предел интегрирования
    xm = 0.05;          // Верхний предел интегрирования
    hx = xm/(637-x0);   // Шаг интегрирования
    hy = [self f:xn]/(y0-2);  // Масштаб графика по Оу
}

// Вычисление результатов интегрирования
- (void)processIntegrator
{
    // Переменные эталона
    float sx1=x0+xn/hx;
    float sy1=y0-[self f:xn]/hy;
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
    float erry1=y0-fabs(ry1-[self f:xn])/hy;
    
    // Переменные трапеций
    float ty1=[self f:xn];
    float ty2=cos(w*xn);
    float ty3=sin(w*xn);
    float ty4=ty1*ty1;
    float tdy2=-w*ty3*hx;
    float tdy3=w*ty2*hx;
    float tdy1=tdy2/(3*ty1*ty1);
    float tdy4=2*ty1*tdy1;
    float tya=ty1;
    float erty1=y0-fabs(ry1-[self f:xn])/hy;
    
    // массивы значений
    WSData *data1, *data2, *data3, *data4;
    
    NSMutableArray *arr1, *arr2, *arr3, *arr4 = [NSMutableArray array];
    NSMutableArray *arr1Y, *arr2Y, *arr3Y, *arr4Y = [NSMutableArray array];
    
    for(int i=1;i<=638;i++)
    {
        // Построение эталона
        float sy2=y0-[self f:(xn+i*hx)]/hy;
        //Image1->Canvas->Pen->Width=2;
        //Image1->Canvas->Pen->Color=clBlack;
        //Image1->Canvas->MoveTo(sx1,sy1);
        //Image1->Canvas->LineTo(sx2,sy2);
        [arr1 addObject:@(sx1)];
        [arr1Y addObject:@(sy1)];
        [arr2 addObject:@(sx2)];
        [arr2Y addObject:@(sy2)];
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
        //Image1->Canvas->Pen->Width=1;
        //Image1->Canvas->Pen->Color=clRed;
        //Image1->Canvas->MoveTo(sx1,rya);
        //Image1->Canvas->LineTo(sx2,ryb);
        rya=ryb;
        
        // Построение ошибки прямоугольников
        float erry2=y0-fabs(ryb-sy2);
        //Image1->Canvas->Pen->Color=clFuchsia;
        //Image1->Canvas->MoveTo(sx1,erry1);
        //Image1->Canvas->LineTo(sx2,erry2);
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
        //Image1->Canvas->Pen->Color=clBlue;
        //Image1->Canvas->MoveTo(sx1,tya);
        //Image1->Canvas->LineTo(sx2,tyb);
        tya=tyb;
        
        // Построение ошибки трапеций
        float erty2=y0-fabs(tyb-sy2);
        //Image1->Canvas->Pen->Color=clAqua;
        //Image1->Canvas->MoveTo(sx1,erty1);
        //Image1->Canvas->LineTo(sx2,erty2);
        erty1=erty2;
        
        // Сдвиг по Ох
        sx1+=1;
        sx2+=1;
    }
    
}

// Целевая функция
- (float)f:(float)x
{
    float z=cos(100*M_PI*x);
    if(z>0) return pow(cos(100*M_PI*x),1.0/3);
    else return -pow(fabs(cos(100*M_PI*x)),1.0/3);
}

#pragma mark - Построение графиков

- (void)drawFirstPlot:(NSArray *)dataArr
{
    // Наборы данных кривых
    WSChart *graphics[2];
    
    int i = 0;
    
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
    WSChart *chart = [WSChart linePlotWithFrame:[self.chart2 frame]
                                           data:data
                                          style:kChartLineGradient
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
                                          style:kChartLineGradient
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
