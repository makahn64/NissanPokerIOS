//
//  AdminViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/3/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "AdminViewController.h"
#import <AFNetworking/AFNetworking.h>

#define UI_EXIT_ALERT 200
#define UI_FINALROUND_ALERT 201
#define UI_NEWCOMP_ALERT 202
#define UI_COMPNUM_ALERT 203
#define UI_CLEARBOARD_ALERT 204

@interface AdminViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *scannerTypeControl;

@property (weak, nonatomic) IBOutlet UILabel *leaderboardSubtitleLabel;

@property (nonatomic) int compNum;
@property (weak, nonatomic) IBOutlet UIStepper *compNumStepper;
@property (weak, nonatomic) IBOutlet UIButton *compNumUpdateButton;
@property (weak, nonatomic) IBOutlet UILabel *compNumLabel;

@property (weak, nonatomic) IBOutlet UIButton *uploadHandsButton;

@property (nonatomic) BOOL qrEnabled;
@property (strong, nonatomic) UIColor *nissanRed;

@property (strong, nonatomic) NSArray *savedHands;

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
    
    self.nissanRed = [AppDelegate sharedAppDelegate].window.tintColor;

    self.qrEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"QRScanningEnabled"];
    
    if (self.qrEnabled) {
        self.scannerTypeControl.selectedSegmentIndex = 1;
    }
    else {
        self.scannerTypeControl.selectedSegmentIndex = 0;
    }
    
    self.compNumStepper.tintColor = [UIColor grayColor];
    self.compNumStepper.userInteractionEnabled = NO;
    self.compNumUpdateButton.tintColor = [UIColor grayColor];
    self.compNumUpdateButton.userInteractionEnabled = NO;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [manager GET:@"http://192.168.1.21:3030/getGameNumber" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseJSON = responseObject;
        
        NSNumber *gameNumber = [responseJSON objectForKey:@"data"];
        
        self.leaderboardSubtitleLabel.text = [NSString stringWithFormat:@"Current Competition: %d", gameNumber.intValue];
        self.compNumLabel.text = [NSString stringWithFormat:@"%d", gameNumber.intValue];
        
        self.compNumStepper.value = gameNumber.intValue;
        self.compNum = gameNumber.intValue;
        
        self.compNumStepper.tintColor = self.nissanRed;
        self.compNumStepper.userInteractionEnabled = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.leaderboardSubtitleLabel.text = @"No Connection";
        self.compNumLabel.text = @"---";
        
    }];
    
    [self setUpCoreDataElements];
    
    //TODO: Add superuser control
    /*
    self.scannerTypeControl.userInteractionEnabled = NO;
    self.scannerTypeControl.tintColor = [UIColor grayColor];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (void)setUpCoreDataElements {
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:@"Customer"
                                              inManagedObjectContext:[AppDelegate sharedAppDelegate].managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error;
    
    self.savedHands = [[AppDelegate sharedAppDelegate].managedObjectContext executeFetchRequest:request error:&error];
    if (self.savedHands == nil) {
        NSLog(@"Failed CD access with error: %@", error);
    }
    
    if ([self.savedHands count] > 0) {
        
        [self.uploadHandsButton setTitle:[NSString stringWithFormat:(@"Upload %d Locally Saved Games"), [self.savedHands count]] forState:UIControlStateNormal];
        
    }
    else {
        
        [self.uploadHandsButton setTitle:@"No Locally Saved Games" forState:UIControlStateNormal];
        self.uploadHandsButton.tintColor = [UIColor grayColor];
        self.uploadHandsButton.enabled = NO;
        
    }
    
}

- (IBAction)exitButtonTapped:(id)sender {
    
    if (self.qrEnabled != [[NSUserDefaults standardUserDefaults] boolForKey:@"QRScanningEnabled"] ) {
        
        UIAlertView *exitAlert = [[UIAlertView alloc] initWithTitle:@"Target Mode Changed"
                                                            message:@"The target recognition mode has changed and needs to be saved. You will be returned to the welcome screen.\n\nDo you wish continue?"
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Save & Continue", nil];
        exitAlert.tag = UI_EXIT_ALERT;
        [exitAlert show];
        
    }
    
    else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

#pragma mark Scanner Type
- (IBAction)scannerTypeChanged:(id)sender {
    
    self.qrEnabled = !self.qrEnabled;
    
}

#pragma mark Leaderboard

- (IBAction)changedCompNum:(id)sender {
    
    self.compNumLabel.text = [NSString stringWithFormat:@"%d", (int) self.compNumStepper.value];
    
    if (self.compNumStepper.value == self.compNum) {
    
        self.compNumUpdateButton.tintColor = [UIColor grayColor];
        self.compNumUpdateButton.userInteractionEnabled = NO;
    
    }
    
    else {
    
        self.compNumUpdateButton.tintColor = self.nissanRed;
        self.compNumUpdateButton.userInteractionEnabled = YES;
    
    }
    
}

- (IBAction)updateCompNumTapped:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"This will change the leaderboard to the new round number selected. If this is an old competition, it will be resumed. Otherwise a new competion is started.\n\nThe current competition is archived as round %d", self.compNum];
    
    UIAlertView *updateCompNumAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                 message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Update Leaderboard", nil];
    updateCompNumAlert.tag = UI_COMPNUM_ALERT;
    
    [updateCompNumAlert show];
    
}

- (IBAction)finalRoundTapped:(id)sender {
    
    UIAlertView *finalRoundAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                              message:@"Starting the final round will transition the leaderboard to the final showdown and stop it from accepting new hands.\n\nThis action cannot be undone."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Start Showdown", nil];
    finalRoundAlert.tag = UI_FINALROUND_ALERT;
    
    [finalRoundAlert show];
    
}

- (IBAction)checkConnectionTapped:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [manager GET:@"http://192.168.1.21:3030/getGameNumber" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseJSON = responseObject;
        
        NSNumber *gameNumber = [responseJSON objectForKey:@"data"];
        
        self.leaderboardSubtitleLabel.text = [NSString stringWithFormat:@"Current Competition: %d", gameNumber.intValue];
        self.compNumLabel.text = [NSString stringWithFormat:@"%d", gameNumber.intValue];
        self.compNumStepper.value = gameNumber.intValue;
        self.compNum = gameNumber.intValue;
        
        self.compNumStepper.tintColor = self.nissanRed;
        self.compNumStepper.userInteractionEnabled = YES;
        self.compNumUpdateButton.tintColor = [UIColor grayColor];
        self.compNumUpdateButton.userInteractionEnabled = NO;
        
        [SVProgressHUD showSuccessWithStatus:@"Connected!"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.compNumStepper.tintColor = [UIColor grayColor];
        self.compNumStepper.userInteractionEnabled = NO;
        self.compNumUpdateButton.tintColor = [UIColor grayColor];
        self.compNumUpdateButton.userInteractionEnabled = NO;
        
        [SVProgressHUD showErrorWithStatus:@"No Connection"];
    }];
    
}

- (IBAction)clearLeaderboardTapped:(id)sender {
    
    UIAlertView *clearLeaderboardAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                    message:@"Clearing the leaderboard will delete ALL hands in the competition.\n\nThis action cannot be undone."
                                                                   delegate:self
                                                          cancelButtonTitle:@"Cancel"
                                                          otherButtonTitles:@"Clear Board", nil];
    clearLeaderboardAlert.tag = UI_CLEARBOARD_ALERT;
    
    [clearLeaderboardAlert show];
    
}

- (IBAction)startNewRoundTapped:(id)sender {
    
    NSString *message = [NSString stringWithFormat:@"Clearing the leaderboard will delete ALL hands and start a new competition.\n\nThis action can be undone by setting the round number to %d.", self.compNum];
    
    UIAlertView *clearLeaderboardAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Start New Round", nil];
    clearLeaderboardAlert.tag = UI_NEWCOMP_ALERT;
    
    [clearLeaderboardAlert show];
    
}

#pragma mark Core Data

- (IBAction)uploadHands:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    __block int successes = 0;
    
    for (Customer *c in self.savedHands) {
    
        NSString *submitURL = [NSString stringWithFormat:(@"http://192.168.1.21:3030/player/%@/%@/"), c.firstName, c.lastName];
        
        for (PlayingCard *card in c.pokerHand){
            
            submitURL = [submitURL stringByAppendingString:[ [card.rank lowercaseString] stringByAppendingString:card.suit] ];
            submitURL = [submitURL stringByAppendingString:@"/"];
        }
        
        submitURL = [submitURL stringByAppendingString: [NSString stringWithFormat:(@"%@"), c.handValue]];
        
        [manager GET:submitURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            c.uploaded = [NSNumber numberWithBool:YES];
            successes++;
            [SVProgressHUD showProgress: ((float)successes/[self.savedHands count]) status:[NSString stringWithFormat:@"%d updoaded", successes] ];
            
            [[AppDelegate sharedAppDelegate].managedObjectContext deleteObject:c];
            [[AppDelegate sharedAppDelegate] saveContext];
            
            if (successes == [self.savedHands count]) {
                
                [SVProgressHUD showSuccessWithStatus:@"Succeeded!"];
                
                [self setUpCoreDataElements];
                
            }
            
            else if ([self.savedHands objectAtIndex: ([self.savedHands count]-1) ] == c){
                
                NSString *failStatus = [NSString stringWithFormat:@"Failed to Upload %d games", [self.savedHands count] - successes];
                
                [SVProgressHUD showErrorWithStatus:failStatus];
                
            }
            
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            
            if ([self.savedHands objectAtIndex: ([self.savedHands count]-1) ] == c){
                NSString *failStatus = [NSString stringWithFormat:@"Failed to Upload %d games", [self.savedHands count] - successes];
                
                [self setUpCoreDataElements];
                
                [SVProgressHUD showErrorWithStatus:failStatus];
            }
            
        }];
    }
    
    
}

#pragma mark - Reactions

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        if (alertView.tag == UI_EXIT_ALERT) {
            
            [[NSUserDefaults standardUserDefaults] setBool:self.qrEnabled forKey:@"QRScanningEnabled"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
        else {
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            
            if (alertView.tag == UI_NEWCOMP_ALERT) {
                
                [manager GET:@"http://192.168.1.21:3030/newGame" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_FINALROUND_ALERT) {
                
                [manager GET:@"http://192.168.1.21:3030/startShowdown" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_COMPNUM_ALERT) {
                
                NSString *compNumURL = [NSString stringWithFormat:@"http://192.168.1.21:3030/changeGame/%d", (int) self.compNumStepper.value];
                
                [manager GET:compNumURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_CLEARBOARD_ALERT) {
                
                [manager GET:@"http://192.168.1.21:3030/clearPlayers" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
        }
    }
}


/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
}
*/

@end