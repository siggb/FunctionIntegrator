//
//  SecondViewController.m
//  IntagratingMachine
//
//  Created by Ildar Sibagatov on 30.05.13.
//  Copyright (c) 2013 sig. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

// Контроллеры
@property (nonatomic, strong) ThirdViewController *thirdVC;

@end




@implementation SecondViewController

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

@end
