//
//  FirstViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()
{
    WSChart *_choice[3];
}
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
