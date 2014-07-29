//
//  SubmitHandViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/16/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "SubmitHandViewController.h"
#import "PlayingCardView.h"
#import "PokerHand.h"
#import "PlayingCard+WithInterface.h"
#import <AFNetworking/AFNetworking.h>

#define FIRST_NAME_FIELD 200
#define LAST_NAME_FIELD 201

@interface SubmitHandViewController ()

@property (strong, nonatomic) NSMutableArray *handCardViews;
@property (strong, nonatomic) NSArray *bestHandArray;
@property (strong, nonatomic) PokerHand *finalPokerHand;

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UICollectionView *finalHandCollectionView;

@property (weak, nonatomic) IBOutlet UILabel *handDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (nonatomic) BOOL hasName;

@end

@implementation SubmitHandViewController

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
    
    [self.firstNameTextField setDelegate:self];
    [self.lastNameTextField setDelegate:self];
    
    self.submitButton.hidden = YES;
    
    self.hasName = NO;
    
    self.finalPokerHand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand;
    self.bestHandArray = self.finalPokerHand.bestFiveCardHand;
    
    self.handDescriptionLabel.text = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand.handDescription;
    
    self.handCardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.bestHandArray count]; i++)
    {
        CGRect newCardFrame = CGRectMake(0, 0, 70, 98);
        PlayingCardView *newCard = [[PlayingCardView alloc] initWithFrame:newCardFrame];
        [newCard setRankAndSuitFromCard:self.bestHandArray[i]];
        [newCard flipCard];
        
        [self.handCardViews addObject:newCard];
    }
    
    [self.finalHandCollectionView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CollectionView Data Source Methods


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.handCardViews count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playingCardCell" forIndexPath:indexPath];
    
    PlayingCardView *cardView = self.handCardViews[indexPath.row];
    [cell addSubview:cardView];
    
    return cell;
}

#pragma mark - Actions


- (IBAction)nameEdited:(id)sender
{
    if ([self.firstNameTextField.text length] && [self.lastNameTextField.text length])
    {
        self.hasName = YES;
    }
    else
    {
        self.hasName = NO;
    }
    
}

- (void)animateSubmitButton
{
    if (self.hasName)
    {
        [UIView animateWithDuration:1.0
                        animations:^{
                                self.submitButton.hidden = NO;
                        }
                        completion:nil];
    }
    else
    {
        self.submitButton.hidden = YES;
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
    
    [self animateSubmitButton];
    
    return YES;
}

- (IBAction)userSubmitted:(id)sender
{
    AppDelegate *ad = [AppDelegate sharedAppDelegate];
    ad.currentPlayer.firstName = self.firstNameTextField.text;
    ad.currentPlayer.lastName = self.lastNameTextField.text;
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *params = @{@"First Name": self.firstNameTextField.text,
                             @"Last Name": self.lastNameTextField.text,
                             @"Hand": [self.finalPokerHand bestHandAsStringInitials],
                             @"Hand Value": [NSNumber numberWithInt: self.finalPokerHand.handValue]};
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [manager POST:@"http://localhost/phptest/postbarf.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [SVProgressHUD showSuccessWithStatus:@"Succeeded"];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Failed"];
        [[AppDelegate sharedAppDelegate] addCurentCustomerToCoreDataFinished:YES];
    }];
    
}

/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    
}
*/

@end
