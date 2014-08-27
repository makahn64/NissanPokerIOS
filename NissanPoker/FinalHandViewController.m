//
//  FinalHandViewController.m
//  Nissan Poker
//
//  Created by Jasper Kahn on 8/15/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "FinalHandViewController.h"
#import "PlayingCardView.h"
#import "PokerHand.h"
#import "PlayingCard+WithInterface.h"
#import <AFNetworking/AFNetworking.h>

#define FIRST_NAME_FIELD 200
#define LAST_NAME_FIELD 201

@interface FinalHandViewController ()

//TODO: update properties to new flow
@property (strong, nonatomic) NSMutableArray *handCardViews;
@property (strong, nonatomic) NSArray *bestHandArray;
@property (strong, nonatomic) PokerHand *finalPokerHand;

@property (weak, nonatomic) IBOutlet UILabel *handDescriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLabel;

@property (nonatomic) __block BOOL networkingComplete;
@property (nonatomic) __block BOOL networkingSucessful;
@property (nonatomic) BOOL timeoutComplete;

@end

@implementation FinalHandViewController

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
    
    AppDelegate *ad = [AppDelegate sharedAppDelegate];
    
    ad.currentPlayer.finished = YES;
    ad.currentPlayer.gameDuration = (int) (round( [[NSDate date] timeIntervalSince1970] ) - ad.currentPlayer.timeStartedGame);
    
    //Get the final hand.
    self.finalPokerHand = ad.currentPlayer.pokerHand;
    self.bestHandArray = self.finalPokerHand.bestFiveCardHand;
    
    //Set the labels on screen with attributes and hand name.
    NSString *handDescription = [@"YOUR FINAL HAND: " stringByAppendingString:[ad.currentPlayer.pokerHand.handDescription uppercaseString]];
    NSMutableAttributedString *handDescriptionAttr = [[NSMutableAttributedString alloc] initWithString:handDescription];
    
    [handDescriptionAttr addAttribute:NSForegroundColorAttributeName value:[AppDelegate nissanGrey] range:NSMakeRange(0, 16)];
    [handDescriptionAttr addAttribute:NSForegroundColorAttributeName value:[AppDelegate nissanRed] range:NSMakeRange(16, handDescriptionAttr.length - 16)];
    [handDescriptionAttr addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Bold" size:35.0f] range:NSMakeRange(0, handDescriptionAttr.length)];
    
    self.handDescriptionLabel.attributedText = handDescriptionAttr;
    
    
    NSMutableAttributedString *subtitle = [[NSMutableAttributedString alloc] initWithString:@"Check the Leaderboard to see if your hand is in the top ten!"];
    
    [subtitle addAttribute:NSForegroundColorAttributeName value:[AppDelegate nissanGrey] range:NSMakeRange(0, subtitle.length)];
    [subtitle addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Md" size:22.0f] range:NSMakeRange(0, subtitle.length)];
    
    self.subtitleLabel.attributedText = subtitle;
    
    //Setup the onscreen cards.
    self.handCardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.bestHandArray count]; i++)
    {
        int xPos = 70 + (150*i);
        
        CGRect newCardFrame = CGRectMake(xPos, 163, 275, 395);
        PlayingCardView *newCard = [[PlayingCardView alloc] initWithFrame:newCardFrame andIsSmall:NO];
        [newCard setRankAndSuitFromCard:self.bestHandArray[i]];
        [newCard flipCard];
        
        [self.handCardViews addObject:newCard];
        [self.view addSubview:newCard];
    }
    
    //Setup the timeout and networking
    self.timeoutComplete = NO;
    self.networkingComplete = NO;
    self.networkingSucessful = NO;
    
    int delay = [[NSUserDefaults standardUserDefaults] integerForKey:@"timeout"];
    
    if (delay < 61) {
        [self performSelector:@selector(timeoutCompleted) withObject:nil afterDelay:delay];
    }

    [self submitUser];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (void)submitUser
{
    AppDelegate *ad = [AppDelegate sharedAppDelegate];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSDictionary *name = @{@"firstName": ad.currentPlayer.firstName,
                           @"lastName": ad.currentPlayer.lastName};
    
    NSDictionary *metrics = @{@"deviceID": ad.currentPlayer.deviceId,
                              @"timeStartedGame": [NSNumber numberWithInt: ad.currentPlayer.timeStartedGame],
                              @"gameDuration": [NSNumber numberWithInt: ad.currentPlayer.gameDuration],
                              @"abandoned": [NSNumber numberWithBool:ad.currentPlayer.abandoned],
                              @"complete": [NSNumber numberWithBool:ad.currentPlayer.finished],
                              @"vehicle": ad.currentPlayer.vehicle};
    
    NSDictionary *params = @{@"name": name,
                             @"hand": [ad.currentPlayer.pokerHand bestHandNetworkArray],
                             @"score": [NSNumber numberWithInt: ad.currentPlayer.pokerHand.handValue],
                             @"description": ad.currentPlayer.pokerHand.handDescription,
                             @"metrics": metrics};
    
    /*
    NSString *submitURL = [NSString stringWithFormat:(@"http://192.168.1.21:3030/player/%@/%@/"), ad.currentPlayer.firstName, ad.currentPlayer.lastName];
    
    for (PokerCard *card in ad.currentPlayer.pokerHand.hand){
        submitURL = [submitURL stringByAppendingString:[card rankSuitAsInitials]];
        submitURL = [submitURL stringByAppendingString:@"/"];
    }
    
    submitURL = [submitURL stringByAppendingString: [NSString stringWithFormat:(@"%d"), ad.currentPlayer.pokerHand.handValue] ];
    */
    NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
    NSString *submitURL = [baseURL stringByAppendingString:@"/players/register"];
    
    [manager POST:submitURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"HTTP: %@", responseObject);
        self.networkingComplete = YES;
        self.networkingSucessful = YES;
        
        [self transitionIfDone];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [[AppDelegate sharedAppDelegate] addCurentCustomerToCoreData];
        self.networkingComplete = YES;
        self.networkingSucessful = NO;
        
        [self transitionIfDone];
    }];

}

- (IBAction)overrideTimeout:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(timeoutCompleted) object:nil];
    [self timeoutCompleted];
}

- (void)timeoutCompleted
{
    self.timeoutComplete = YES;
    [self transitionIfDone];
}

- (void)transitionIfDone
{
    if (self.networkingComplete && self.timeoutComplete) {
        
        if (self.networkingSucessful) {
            [SVProgressHUD showSuccessWithStatus:@"Uploaded Hand!"];
        }
        else
        {
            [SVProgressHUD showErrorWithStatus:@"Failed, please try again later."];
        }
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
    else if (self.timeoutComplete && !self.networkingComplete)
    {
        
        [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
        [SVProgressHUD setStatus:@"Connecting..."];
        
    }
    
}

/*
 #pragma mark - Navigation
 
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 
 
 }
 */

@end
