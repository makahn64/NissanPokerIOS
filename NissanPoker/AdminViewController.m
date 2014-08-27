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
/*
#define UI_FINALROUND_ALERT 201
#define UI_NEWCOMP_ALERT 202
#define UI_COMPNUM_ALERT 203
#define UI_CLEARBOARD_ALERT 204
*/
#define UI_IPCHANGE_ALERT 205
#define UI_IPCHANGECONFIRM_ALERT 206

@interface AdminViewController ()

@property (weak, nonatomic) IBOutlet UISegmentedControl *scannerTypeControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetVehicleControl;

@property (weak, nonatomic) IBOutlet UILabel *leaderboardSubtitleLabel;
/*
@property (nonatomic) int compNum;
@property (weak, nonatomic) IBOutlet UIStepper *compNumStepper;
@property (weak, nonatomic) IBOutlet UIButton *compNumUpdateButton;
@property (weak, nonatomic) IBOutlet UILabel *compNumLabel;
*/
@property (weak, nonatomic) IBOutlet UIButton *uploadHandsButton;

@property (weak, nonatomic) IBOutlet UISlider *timeoutSlider;
@property (weak, nonatomic) IBOutlet UILabel *timeoutLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeoutWarning;

@property (nonatomic) BOOL qrEnabled;
@property (strong, nonatomic) NSString *updatedLeaderboardAddress;

@property (strong, nonatomic) NSArray *savedHands;

@property (weak, nonatomic) IBOutlet UILabel *deviceIDLabel;

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

    self.qrEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"QRScanningEnabled"];
    self.updatedLeaderboardAddress = [[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    
    if (self.qrEnabled) {
        self.scannerTypeControl.selectedSegmentIndex = 1;
    }
    else {
        self.scannerTypeControl.selectedSegmentIndex = 0;
    }
    
    self.targetVehicleControl.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"targetVehicle"];
    
    self.timeoutSlider.value = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeout"];
    [self updateTimeoutLabels];
    
    self.deviceIDLabel.text = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    [self checkConnectionInitial];
    
    /*
    self.compNumStepper.tintColor = [UIColor grayColor];
    self.compNumStepper.userInteractionEnabled = NO;
    self.compNumUpdateButton.tintColor = [UIColor grayColor];
    self.compNumUpdateButton.userInteractionEnabled = NO;
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    NSLog([baseURL stringByAppendingString:@"/getGameNumber"], nil);
    
    [manager GET:[baseURL stringByAppendingString:@"/getGameNumber"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        NSDictionary *responseJSON = responseObject;
        
        NSNumber *gameNumber = [responseJSON objectForKey:@"data"];
        
        self.leaderboardSubtitleLabel.text = [NSString stringWithFormat:@"Current Competition: %d", gameNumber.intValue];
        self.compNumLabel.text = [NSString stringWithFormat:@"%d", gameNumber.intValue];
        
        self.compNumStepper.value = gameNumber.intValue;
        self.compNum = gameNumber.intValue;
        
        self.compNumStepper.tintColor = [AppDelegate nissanRed];
        self.compNumStepper.userInteractionEnabled = YES;
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        self.leaderboardSubtitleLabel.text = @"No Connection";
        self.compNumLabel.text = @"---";
        
    }];
    */
    
    [self setUpCoreDataElements];
    
    //TODO: Add superuser control
    
    self.scannerTypeControl.userInteractionEnabled = NO;
    self.scannerTypeControl.tintColor = [UIColor grayColor];
    
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
/*
#pragma mark Leaderboard

- (IBAction)changedCompNum:(id)sender {
    
    self.compNumLabel.text = [NSString stringWithFormat:@"%d", (int) self.compNumStepper.value];
    
    if (self.compNumStepper.value == self.compNum) {
    
        self.compNumUpdateButton.tintColor = [UIColor grayColor];
        self.compNumUpdateButton.userInteractionEnabled = NO;
    
    }
    
    else {
    
        self.compNumUpdateButton.tintColor = [AppDelegate nissanRed];
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
*/

- (IBAction)targetVehicleChanged:(id)sender {
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.targetVehicleControl.selectedSegmentIndex forKey:@"targetVehicle"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (IBAction)checkConnectionTapped:(id)sender {
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [self checkConnection];
}

- (void)checkConnection
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    
    [manager GET:[baseURL stringByAppendingString:@"/players/test"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //NSDictionary *responseJSON = responseObject;
        
        /*
         
         NSNumber *gameNumber = [responseJSON objectForKey:@"data"];
         
         self.leaderboardSubtitleLabel.text = [NSString stringWithFormat:@"Current Competition: %d", gameNumber.intValue];
         self.compNumLabel.text = [NSString stringWithFormat:@"%d", gameNumber.intValue];
         self.compNumStepper.value = gameNumber.intValue;
         self.compNum = gameNumber.intValue;
         
         self.compNumStepper.tintColor = [AppDelegate nissanRed];
         self.compNumStepper.userInteractionEnabled = YES;
         self.compNumUpdateButton.tintColor = [UIColor grayColor];
         self.compNumUpdateButton.userInteractionEnabled = NO;
         
         */
        self.leaderboardSubtitleLabel.text = @"Connected";
        
        [SVProgressHUD showSuccessWithStatus:@"Connected!"];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        /*
         self.compNumStepper.tintColor = [UIColor grayColor];
         self.compNumStepper.userInteractionEnabled = NO;
         self.compNumUpdateButton.tintColor = [UIColor grayColor];
         self.compNumUpdateButton.userInteractionEnabled = NO;
         */
        
        self.leaderboardSubtitleLabel.text = @"No Connection";
        
        [SVProgressHUD showErrorWithStatus:@"No Connection"];
    }];

    
}

- (void)checkConnectionInitial
{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    
    [manager GET:[baseURL stringByAppendingString:@"/players/test"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        //NSDictionary *responseJSON = responseObject;
        
        /*
         
         NSNumber *gameNumber = [responseJSON objectForKey:@"data"];
         
         self.leaderboardSubtitleLabel.text = [NSString stringWithFormat:@"Current Competition: %d", gameNumber.intValue];
         self.compNumLabel.text = [NSString stringWithFormat:@"%d", gameNumber.intValue];
         self.compNumStepper.value = gameNumber.intValue;
         self.compNum = gameNumber.intValue;
         
         self.compNumStepper.tintColor = [AppDelegate nissanRed];
         self.compNumStepper.userInteractionEnabled = YES;
         self.compNumUpdateButton.tintColor = [UIColor grayColor];
         self.compNumUpdateButton.userInteractionEnabled = NO;
         
         */
        self.leaderboardSubtitleLabel.text = @"Connected";
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        
        /*
         self.compNumStepper.tintColor = [UIColor grayColor];
         self.compNumStepper.userInteractionEnabled = NO;
         self.compNumUpdateButton.tintColor = [UIColor grayColor];
         self.compNumUpdateButton.userInteractionEnabled = NO;
         */
        
        self.leaderboardSubtitleLabel.text = @"No Connection";
    }];
    
    
}


/*
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
*/
- (IBAction)changeIP:(id)sender {
    
    NSString *message = @"Please enter the new address.\nONLY CHANGE THIS IF YOU KNOW WHAT YOU ARE DOING.\n\n Include \"http://\".";
    
    UIAlertView *changeIPAlert = [[UIAlertView alloc] initWithTitle:@"Leaderboard Address"
                                                            message:message
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:@"Change Address", nil];
    
    changeIPAlert.alertViewStyle = UIAlertViewStylePlainTextInput;
    
    NSMutableAttributedString *address = [[NSMutableAttributedString alloc] initWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"]];
    [address addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(0, 7)];
    [changeIPAlert textFieldAtIndex:0].attributedText = address;
    
    [[changeIPAlert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeURL];
    [[changeIPAlert textFieldAtIndex:0] setDelegate:self];
    changeIPAlert.tag = UI_IPCHANGE_ALERT;
    
    [changeIPAlert show];
    

}

#pragma mark Core Data

- (IBAction)uploadHands:(id)sender {
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    __block int successes = 0;
    
    for (Customer *c in self.savedHands) {
        
        NSDictionary *name = @{@"firstName": c.firstName,
                               @"lastName": c.lastName};
        
        NSMutableArray *cardsArray = [[NSMutableArray alloc] initWithCapacity:5];
        for (PlayingCard *card in c.pokerHand) {
            [cardsArray addObject:[card.rank stringByAppendingString:card.suit]];
        }
        
        NSDictionary *metrics = @{@"deviceID": c.deviceID,
                                  @"timeStartedGame": c.createdTime,
                                  @"gameDuration": c.gameDuration,
                                  @"abandoned": c.abandonedGame,
                                  @"complete": c.finishedGame,
                                  @"vehicle": c.vehicle};
        
        NSDictionary *params = @{@"name": name,
                                 @"deviceID": c.deviceID,
                                 @"hand": cardsArray,
                                 @"score": c.handValue,
                                 @"description": c.handDescription,
                                 @"metrics": metrics};
        
        NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    
        NSString *submitURL = [baseURL stringByAppendingString:@"/players/register"];
        
        [manager POST:submitURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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

#pragma mark Timeout


- (IBAction)timeoutValueChanged:(id)sender {
    
    NSInteger value = (int)roundf(self.timeoutSlider.value);
    
    [[NSUserDefaults standardUserDefaults] setInteger:value forKey:@"timeout"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self updateTimeoutLabels];
    
}


- (void)updateTimeoutLabels
{
    
    self.timeoutSlider.value = (int)roundf(self.timeoutSlider.value);
    
    if (self.timeoutSlider.value > 60) {
        self.timeoutLabel.text = @"OFF";
        self.timeoutWarning.hidden = NO;
    }
    
    else {
        self.timeoutWarning.hidden = YES;
        self.timeoutLabel.text = [NSString stringWithFormat:@"%d Seconds", (int)roundf(self.timeoutSlider.value)];
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
        
        else if (alertView.tag == UI_IPCHANGECONFIRM_ALERT) {
            
            [[NSUserDefaults standardUserDefaults] setObject:self.updatedLeaderboardAddress forKey:@"leaderboardAddress"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            self.leaderboardSubtitleLabel.text = @"New IP Address, please hit check connection to refresh.";
            
        }
        /*
        else if (alertView.tag == UI_NEWCOMP_ALERT || alertView.tag == UI_FINALROUND_ALERT || alertView.tag == UI_COMPNUM_ALERT || alertView.tag == UI_CLEARBOARD_ALERT) {
            
            AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            
            [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
            
            NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
            
            if (alertView.tag == UI_NEWCOMP_ALERT) {
                
                [manager GET:[baseURL stringByAppendingString:@"/newGame"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_FINALROUND_ALERT) {
                
                [manager GET:[baseURL stringByAppendingString:@"/startShowdown"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_COMPNUM_ALERT) {
                
                NSString *compNumURL = [baseURL stringByAppendingString:[NSString stringWithFormat:@"/changeGame/%d", (int) self.compNumStepper.value]];
                
                [manager GET:compNumURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
            else if (alertView.tag == UI_CLEARBOARD_ALERT) {
                
                [manager GET:[baseURL stringByAppendingString:@"/clearPlayers"] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    NSLog(@"JSON: %@", responseObject);
                    [SVProgressHUD showSuccessWithStatus:@"Done"];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    NSLog(@"Error: %@", error);
                    [SVProgressHUD showErrorWithStatus:@"No Connection"];
                }];
                
            }
            
        }
         
         */
         
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{

    if (alertView.tag == UI_IPCHANGE_ALERT && buttonIndex != alertView.cancelButtonIndex) {
        
        self.updatedLeaderboardAddress = [alertView textFieldAtIndex:0].text;
        
        UIAlertView *confirmAlert = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                               message:@"Do you wish to save this address change?"
                                                              delegate:self
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:@"Confirm", nil];
        confirmAlert.tag = UI_IPCHANGECONFIRM_ALERT;
        [confirmAlert show];
        
    }

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange overlap = NSIntersectionRange(NSMakeRange(0, 7), range);
    
    if (overlap.length > 0) {
        return NO;
    }
    else {
        textField.typingAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
        
        return YES;
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