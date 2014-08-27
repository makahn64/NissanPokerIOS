//
//  IntroViewController.m
//  Nissan Poker
//
//  Created by Jasper Kahn on 8/4/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "IntroViewController.h"

@interface IntroViewController ()

@end

@implementation IntroViewController

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
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)startButtonTapped:(id)sender {
    
    BOOL qrEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"QRScanningEnabled"];
    
    //TODO: fix segues or remove this controller
    if (qrEnabled) {
        [self performSegueWithIdentifier:@"toQRfromIntro" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"toARfromIntro" sender:self];
    }
    
}



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
