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
    WSChart *graphics[3];
    
    // Переменные
    NSInteger y, x0, xn, k;
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
    NSLog(@"k=%d, y=%d, x0=%d, xn=%d", k, y, x0, xn);
    
    
    // Рисуем графики
    WSData *testD = [DemoData scientificData];
    [self drawFirstPlot:testD];
}

#pragma mark - Построение графиков

- (void)drawFirstPlot:(WSData*)data
{
    // Формируем график по данным
    graphics[0] = [WSChart linePlotWithFrame:[self.chart1 frame]
                                       data:data
                                      style:kChartLineGradient
                                  axisStyle:kCSGrid
                                colorScheme:kColorLight
                                     labelX:NSLocalizedString(@"Crystal orientation", @"")
                                     labelY:NSLocalizedString(@"Energy output", @"")];
    [graphics[0] setAllAxisLocationXD:1.328];
    [graphics[0] setAllAxisLocationYD:-0.1];
    
    // Добавляем графики на плоскость координат
    [self.chart1 removeAllPlots];
    [self.chart1 addPlotsFromChart:graphics[0]];
}

- (void)drawSecondPlot
{
    
}

- (void)drawThirdPlot
{
    
}

@end
