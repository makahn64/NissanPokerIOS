//
//  WelcomeViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "WelcomeViewController.h"


@interface WelcomeViewController ()

@property (weak, nonatomic) IBOutlet UILabel *continueLabel;

@end


@implementation WelcomeViewController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated
{
    self.continueLabel.alpha = 0.0;
    //self.tapGestureRecognizer.enabled = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    
    
    [UIView animateWithDuration:.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.continueLabel.alpha = 1.0;
                         
                     }
                     completion:^(BOOL finished) {
                         //self.tapGestureRecognizer.enabled = YES;
                     }];
}

#pragma mark - Actions

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
