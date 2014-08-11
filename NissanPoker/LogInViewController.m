//
//  LogInViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "LogInViewController.h"
#import "QRScannerViewController.h"

#define FIRST_NAME_TEXT_FIELD 100
#define LAST_NAME_TEXT_FIELD 101
#define EMAIL_TEXT_FIELD 102

@interface LogInViewController ()

@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *adminPanelTapRecognizer;

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;

@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UILabel *firstNameCheckMark;
@property (weak, nonatomic) IBOutlet UILabel *lastNameCheckMark;
@property (weak, nonatomic) IBOutlet UILabel *emailCheckMark;

@property (nonatomic) BOOL hasFirstName;
@property (nonatomic) BOOL hasLastName;
@property (nonatomic) BOOL hasName;
@property (nonatomic) BOOL hasEmailAddress;

@end

@implementation LogInViewController

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
    
    [self.firstNameField setDelegate:self];
    [self.lastNameField setDelegate:self];
    [self.emailField setDelegate:self];
    
    [self.adminPanelTapRecognizer setNumberOfTouchesRequired:1];
    [self.adminPanelTapRecognizer setNumberOfTapsRequired:3];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - View Lifecycle

- (void)viewWillAppear:(BOOL)animated
{    
    self.startButton.alpha = 0.0;
    self.firstNameCheckMark.alpha = 0.0;
    self.lastNameCheckMark.alpha = 0.0;
    self.emailCheckMark.alpha = 0.0;
}

#pragma mark -
#pragma mark Utility Methods

- (BOOL)emailValidate:(NSString *)email
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

- (void)validateNames
{
    //Validate first name
    if ([self.firstNameField.text length]) {
        self.hasFirstName = YES;
    }
    else {
        self.hasFirstName = NO;
    }
    
    //Validate lastname
    if ([self.lastNameField.text length]) {
        self.hasLastName = YES;
    }
    else {
        self.hasLastName = NO;
    }
    
    //Validate full name
    if (self.hasFirstName && self.hasLastName)
    {
        self.hasName = YES;
    }
    else
    {
        self.hasName = NO;
    }
}

#pragma mark -
#pragma mark Actions

- (IBAction)nameEdited:(id)sender
{
    [self validateNames];
}

- (IBAction)nameEditingDone:(id)sender
{
    [self animateCheckMarks];
    
    [self animateStartButton];
}


- (IBAction)emailEdited:(id)sender
{
    if ([self emailValidate:self.emailField.text]) {
        self.hasEmailAddress = YES;
    }
    else {
        self.hasEmailAddress = NO;
    }
}

- (IBAction)emailEditingDone:(id)sender
{
    [self animateCheckMarks];
    
    [self animateStartButton];
}

- (void)animateStartButton
{
    if (self.hasEmailAddress && self.hasFirstName)
    {
        if (self.startButton.alpha == 0.0 && !self.startButton.isHidden)
        {
            [UIView animateWithDuration:1.0
                             animations:^{
                             self.startButton.alpha = 1.0;
                             }
                             completion:nil];
        }
    }
    else
    {
        [self.startButton isHidden];
    }
}

- (void)animateCheckMarks;
{
    if (self.hasFirstName) {
        self.firstNameCheckMark.alpha = 1.0;
    }
    else {
        self.firstNameCheckMark.alpha = 0.0;
    }
    
    if (self.hasLastName) {
        self.lastNameCheckMark.alpha = 1.0;
    }
    else {
        self.lastNameCheckMark.alpha = 0.0;
    }
    
    if (self.hasEmailAddress) {
        self.emailCheckMark.alpha = 1.0;
    }
    else {
        self.emailCheckMark.alpha = 0.0;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == EMAIL_TEXT_FIELD)
    {
        if (self.hasEmailAddress)
        {
            [textField resignFirstResponder];
        }
        else
        {
            UIAlertView *badEmailAlert = [[UIAlertView alloc]
                                          initWithTitle:@"Invalid E-mail"
                                          message:@"Please enter a valid e-mail address."
                                          delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
            [badEmailAlert show];
            return NO;
        }
    }
    else if (textField.tag == FIRST_NAME_TEXT_FIELD)
    {
        [textField resignFirstResponder];
        [self.lastNameField becomeFirstResponder];
    }
    else if (textField.tag == LAST_NAME_TEXT_FIELD)
    {
        [textField resignFirstResponder];
        [self.emailField becomeFirstResponder];
    }
    return YES;
}


- (IBAction)cancelLogin:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue destinationViewController] isKindOfClass:[QRScannerViewController class]] )
    {
        //AppDelegate *appD = [AppDelegate sharedAppDelegate];
        /*
        Customer *c = [appD addCurentCustomerToCoreData];
        c.firstName = self.firstNameField.text;
        c.lastName = self.lastNameField.text;
        c.emailAddress = self.emailField.text;
        [appD saveContext];
        
        ScannerViewController *qvc = (ScannerViewController *)[segue destinationViewController];
        qvc.customer = c;
        */
    }
    
}


@end
