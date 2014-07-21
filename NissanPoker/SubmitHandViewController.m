//
//  SubmitHandViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/16/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "SubmitHandViewController.h"
#import "PlayingCardView.h"

#define FIRST_NAME_FIELD 200
#define LAST_NAME_FIELD 201

@interface SubmitHandViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;

@property (weak, nonatomic) IBOutlet UICollectionView *finalHandCollectionView;

@property (weak, nonatomic) IBOutlet UIButton *submitButton;

@property (strong, nonatomic) NSMutableArray *finalHand;

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
    
    self.finalHand = [self getFinalHand];
    
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
    return [self.finalHand count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"playingCardCell" forIndexPath:indexPath];
    
    PlayingCardView *cardView = self.finalHand[indexPath.row];
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

#pragma mark - Utilities

- (NSMutableArray *)getFinalHand
{
    //Do hand evaluation here
    
    NSMutableArray *fiveCardHand = [[NSMutableArray alloc] initWithCapacity:5];
    
    for (int i = 0; i < 5; i++)
    {
        [fiveCardHand addObject:self.currentHand[i]];
    }
    return fiveCardHand;
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AppDelegate *appD = [AppDelegate sharedAppDelegate];
    
    Customer *c = [appD getNewCustomer];
    c.firstName = self.firstNameTextField.text;
    c.lastName = self.lastNameTextField.text;
    //c.pokerHand = [NSSet setWithArray:self.finalHand];
    [appD saveContext];
    
}


@end
