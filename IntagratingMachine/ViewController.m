//
//  ViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 29.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "ViewController.h"

@interface ViewController()
{
    WSChart *_choice[3];
}
@end




@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    // Our test data.
    WSData *testD = [DemoData scientificData];
    
    // Autoconfigure the plot.
    _choice[0] = [WSChart linePlotWithFrame:[self.chart frame]
                                       data:testD
                                      style:kChartLineGradient
                                  axisStyle:kCSGrid
                                colorScheme:kColorLight
                                     labelX:NSLocalizedString(@"Crystal orientation", @"")
                                     labelY:NSLocalizedString(@"Energy output", @"")];
    [_choice[0] setAllAxisLocationXD:1.328];
    [_choice[0] setAllAxisLocationYD:-0.1];
    
    [self.chart addPlotsFromChart:_choice[0]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [self.chart removeAllPlots];
    self.chart = nil;
}

@end
