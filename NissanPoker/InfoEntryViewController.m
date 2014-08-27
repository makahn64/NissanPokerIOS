//
//  SubmitHandViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/16/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "InfoEntryViewController.h"
#import "PlayingCardView.h"
#import "PokerHand.h"
#import "PlayingCard+WithInterface.h"
#import <AFNetworking/AFNetworking.h>

#define FIRST_NAME_FIELD 200
#define LAST_NAME_FIELD 201

@interface InfoEntryViewController ()

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *cancelKeyboardTapRecognizer;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic) BOOL hasName;

@end

@implementation InfoEntryViewController

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
    
    //TODO: Move all final hand logic to final screen
    
    [super viewDidLoad];
    
    [self.firstNameTextField setDelegate:self];
    [self.lastNameTextField setDelegate:self];
    
    self.cancelKeyboardTapRecognizer.enabled = NO;
    
    self.playButton.enabled = NO;
    
    self.hasName = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)editingDidBegin:(id)sender {
    
    self.cancelKeyboardTapRecognizer.enabled = YES;
    
}

- (IBAction)nameEdited:(id)sender
{
    if ([self.firstNameTextField.text length] && [self.lastNameTextField.text length])
    {
        self.hasName = YES;
        self.playButton.enabled = YES;
    }
    else
    {
        self.hasName = NO;
        self.playButton.enabled = NO;
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == LAST_NAME_FIELD)
    {
        if (self.hasName)
        {
            [textField resignFirstResponder];
        }
        else
        {
            UIAlertView *badEmailAlert = [[UIAlertView alloc]
                                          initWithTitle:@"Missing Name"
                                          message:@"Please enter both a first and last name."
                                          delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
            [badEmailAlert show];
            return NO;
        }
    }
    else if (textField.tag == FIRST_NAME_FIELD)
    {
        [textField resignFirstResponder];
        [self.lastNameTextField becomeFirstResponder];
    }
    
    return YES;
}

- (IBAction)cancelKeyboard:(id)sender {
    
    [self.firstNameTextField endEditing:YES];
    [self.lastNameTextField endEditing:YES];
    
    self.cancelKeyboardTapRecognizer.enabled = NO;
    
}


- (IBAction)userSubmitted:(id)sender
{
    AppDelegate *ad = [AppDelegate sharedAppDelegate];
    
    ad.currentPlayer = [[PokerPlayer alloc] init];
    
    ad.currentPlayer.firstName = self.firstNameTextField.text;
    ad.currentPlayer.lastName = self.lastNameTextField.text;
    
    BOOL qrEnabled = [[NSUserDefaults standardUserDefaults] boolForKey:@"QRScanningEnabled"];
    
    if (qrEnabled) {
        [self performSegueWithIdentifier:@"toQRfromInfo" sender:self];
    }
    else {
        [self performSegueWithIdentifier:@"toARfromInfo" sender:self];
    }

    
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
}
*/

@end
