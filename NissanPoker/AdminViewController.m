//
//  AdminViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/3/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "AdminViewController.h"
#import "PlayingCardView.h"
#import "PokerCard.h"
#import "PokerHand.h"

@interface AdminViewController ()

@property (strong, nonatomic) PokerHand *previousHand;

@end


@implementation AdminViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)exitButtonTapped:(id)sender {
    
    UIAlertView *exitAlert = [[UIAlertView alloc] initWithTitle:@"Exit"
                                                        message:@"Do you want to save changes?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Exit & Save", @"Exit without Saving", nil];
    [exitAlert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Exit & Save"])
        {
            //Save Changes
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
}

- (IBAction)testTapped:(id)sender {
    
    PokerDeck *testDeck = [[PokerDeck alloc] init];
    
    PokerHand *testHand = [[PokerHand alloc] init];

    
    for (int i = 0; i < 7; i++) {
        //NSLog(@"Card #%d", i);
        [testHand addCard:[testDeck drawCard]];
    }
    
    if (self.previousHand) {
        NSComparisonResult result = [testHand compareTo:self.previousHand];
        NSLog(@"%ld",result);
    }
    
    self.previousHand = testHand;
    
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
