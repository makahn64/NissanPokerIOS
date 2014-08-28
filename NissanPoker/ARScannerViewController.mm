//
//  ARScannerViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Vuforia stiched in by [mak]
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "ARScannerViewController.h"
//#import "SubmitHandViewController.h"
#import "PlayingCard+WithInterface.h"
#import "PlayingCardView.h"
#import "PokerHand.h"
#import <AFNetworking/AFNetworking.h>

#define UI_ALERTVIEW_ADMIN 200
#define UI_ALERTVIEW_CONFIRM_ABONDON 201

@interface ARScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet PlayingCardView *bigPlayingCard;

@property (weak, nonatomic) IBOutlet UICollectionView *currentHandCollectionView;

@property (strong, nonatomic) NSMutableArray *validARTargetValues;
@property (strong, nonatomic) NSMutableDictionary *remainingHints;

@property (nonatomic) BOOL isPoppedUp;

@end


@implementation ARScannerViewController


#pragma mark - Target AR Values

+ (NSArray *)getValidARTargetValues
{
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"targetVehicle"]) {
        case NV200:
            return @[@"Target_1",
                     @"Target_2",
                     @"Target_3",
                     @"Target_4",
                     @"Target_5",
                     @"Target_15",
                     @"Target_16",
                     @"Target_17",
                     @"Target_18"];
            break;
            
        case NV_CARGO_STANDARD:
            return @[@"Target_6",
                     @"Target_7",
                     @"Target_8",
                     @"Target_9",
                     @"Target_10",
                     @"Target_11",
                     @"Target_12",
                     @"Target_13",
                     @"Target_15",
                     @"Target_16",
                     @"Target_17",
                     @"Target_18"];
            break;
            
        case NV_CARGO_HIGH_ROOF:
            return @[@"Target_6",
                     @"Target_7",
                     @"Target_8",
                     @"Target_9",
                     @"Target_10",
                     @"Target_11",
                     @"Target_12",
                     @"Target_13",
                     @"Target_14",
                     @"Target_15",
                     @"Target_16",
                     @"Target_17",
                     @"Target_18"];
            break;
            
        default:
            return @[@"Target_1",
                     @"Target_2",
                     @"Target_3",
                     @"Target_4",
                     @"Target_5",
                     @"Target_6",
                     @"Target_7",
                     @"Target_8",
                     @"Target_9",
                     @"Target_10",
                     @"Target_11",
                     @"Target_12",
                     @"Target_13",
                     @"Target_14",
                     @"Target_15",
                     @"Target_16",
                     @"Target_17",
                     @"Target_18"];
            break;
    }
}

+ (NSDictionary *)getHints
{
    switch ([[NSUserDefaults standardUserDefaults] integerForKey:@"targetVehicle"]) {
        case NV200:
            return @{@"Target_1" : @"Load the rear cabin without any hassle, we're flexible.",
                     @"Target_2" : @"You can quickly and safely load the van from either side.",
                     @"Target_3" : @"A great curb-to-curb turning radius is my specialty.",
                     @"Target_4" : @"We can open wide for unobstructed loading.\n ",
                     @"Target_5" : @"Compact van? Loading cargo feels more like a full-size cargo van.",
                     @"Target_15" : @"We're here to help strap down those heavy packages.",
                     @"Target_16" : @"Installing shelves, cabinets and racks are no problem with these.",
                     @"Target_17" : @"Is it a seat or a desk?...What is your preference?",
                     @"Target_18" : @"A fully organized mobile office at your fingertips.\n "};
            break;
            
        case NV_CARGO_STANDARD:
            return @{@"Target_6" : @"This is when your cargo says, \"Doors? What doors?\"",
                     @"Target_7" : @"Flat load plywood or a couple pallets of cargo...I got this.",
                     @"Target_8" : @"An early start or a long day, we brighten your whole day.",
                     @"Target_9" : @"Powered mobile office...got it!\n ",
                     @"Target_10" : @"I can charge your power tools anytime.\n ",
                     @"Target_11" : @"Sometimes you need to think inside the box.\n ",
                     @"Target_12" : @"There is no doubt you will stop when you need to.\n ",
                     @"Target_13" : @"Safety...check!\n \n ",
                     @"Target_15" : @"We're here to help strap down those heavy packages.",
                     @"Target_16" : @"Installing shelves, cabinets and racks are no problem with these.",
                     @"Target_17" : @"Is it a seat or a desk?...What is your preference?",
                     @"Target_18" : @"A fully organized mobile office at your fingertips.\n "};
            break;
            
        case NV_CARGO_HIGH_ROOF:
            return @{@"Target_6" : @"This is when your cargo says, \"Doors? What doors?\"",
                     @"Target_7" : @"Flat load plywood or a couple pallets of cargo...I got this.",
                     @"Target_8" : @"An early start or a long day, we brighten your whole day.",
                     @"Target_9" : @"Powered mobile office...got it!\n ",
                     @"Target_10" : @"I can charge your power tools anytime.\n ",
                     @"Target_11" : @"Sometimes you need to think inside the box.\n ",
                     @"Target_12" : @"There is no doubt you will stop when you need to.\n ",
                     @"Target_13" : @"Safety...check!\n \n ",
                     @"Target_14" : @"Stop crouching and stand up!\n ",
                     @"Target_15" : @"We're here to help strap down those heavy packages.",
                     @"Target_16" : @"Installing shelves, cabinets and racks are no problem with these.",
                     @"Target_17" : @"Is it a seat or a desk?...What is your preference?",
                     @"Target_18" : @"A fully organized mobile office at your fingertips.\n "};
            break;
            
        default:
            return @{@"Target_1" : @"Load the rear cabin without any hassle, we're flexible.",
                     @"Target_2" : @"You can quickly and safely load the van from either side.",
                     @"Target_3" : @"A great curb-to-curb turning radius is my specialty.",
                     @"Target_4" : @"We can open wide for unobstructed loading.\n ",
                     @"Target_5" : @"Compact van? Loading cargo feels more like a full-size cargo van.",
                     @"Target_6" : @"This is when your cargo says, \"Doors? What doors?\"",
                     @"Target_7" : @"Flat load plywood or a couple pallets of cargo...I got this.",
                     @"Target_8" : @"An early start or a long day, we brighten your whole day.",
                     @"Target_9" : @"Powered mobile office...got it!\n ",
                     @"Target_10" : @"I can charge your power tools anytime.\n ",
                     @"Target_11" : @"Sometimes you need to think inside the box.\n ",
                     @"Target_12" : @"There is no doubt you will stop when you need to.\n ",
                     @"Target_13" : @"Safety...check!\n \n ",
                     @"Target_14" : @"Stop crouching and stand up!\n ",
                     @"Target_15" : @"We're here to help strap down those heavy packages.",
                     @"Target_16" : @"Installing shelves, cabinets and racks are no problem with these.",
                     @"Target_17" : @"Is it a seat or a desk?...What is your preference?",
                     @"Target_18" : @"A fully organized mobile office at your fingertips.\n "};
            break;
    }
    
}


#pragma mark - Life Cycle of View


-(void)adbandonAllHope {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    NSLog(@"Killing myself!");
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ADQCARImageTargetsEAGLView *ev = (ADQCARImageTargetsEAGLView *)self.view;
    [ev setAugmentationType:AUGMENT_NONE];
    
    self.validARTargetValues = [NSMutableArray arrayWithArray:[ARScannerViewController getValidARTargetValues]];
    self.remainingHints = [NSMutableDictionary dictionaryWithDictionary:[ARScannerViewController getHints]];
    
    [self.bigPlayingCard makeLarge];
    
    self.hintLabel.adjustsFontSizeToFitWidth = YES;

    [self setupCardViews];
    [self setupPopupViews];
    
    self.isPoppedUp = NO;
    
}


#pragma mark - Setup Utilities

- (void)setupCardViews
{
    self.handCardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++)
    {
        CGRect newCardFrame = CGRectMake(0, 0, 75, 105);
        PlayingCardView *newCard = [[PlayingCardView alloc] initWithFrame:newCardFrame andIsSmall:YES];
        
        [self.handCardViews addObject:newCard];
    }
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*) self.currentHandCollectionView.collectionViewLayout;
    flow.minimumInteritemSpacing = 2;
    
    [self.currentHandCollectionView reloadData];
}

- (void)setupPopupViews
{
    self.popupView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    self.continueButton.alpha = 0.0;
}

#pragma mark - Random hint method

- (NSString *)getRandomHint
{
    NSArray *keys = self.remainingHints.allKeys;
    return self.remainingHints[keys[arc4random_uniform((int)keys.count)]];
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

#pragma mark - AR Recognition

-(void)targetAcquired:(NSNotification *)notification{
    
    NSDictionary *userinfo = [notification userInfo];
    
    NSString *arTargetName = [userinfo objectForKey:@"targetName"];
    
    /*
    float xlocInGlSpace = [(NSNumber *)[userinfo objectForKey:@"x-ingl"] floatValue];
    
    if (xlocInGlSpace > 50.0) {
        NSLog(@"Target %@ acquired outside of visible camera slice! [X in GL = %f]", arTargetName, xlocInGlSpace);
        return;

    }
    */
    if ( [self.validARTargetValues containsObject:arTargetName] && !self.isPoppedUp)
    {
        NSLog(@"Target %@ acquired", arTargetName);
        
        [self.validARTargetValues removeObject: arTargetName];
        [self.remainingHints removeObjectForKey:arTargetName];
        
        [self performSelectorOnMainThread:@selector(alertARScanned:)
                               withObject:arTargetName
                            waitUntilDone:NO];
        
    }

    
}


#pragma mark - Actions

- (void)alertARScanned:(NSString *)qrMessage
{
    
    PokerCard *newCard = [[AppDelegate sharedAppDelegate] dealCard];
    
    [self displayCard: newCard withTarget:qrMessage];
    
}

- (void)displayCard:(PokerCard *)baseCard withTarget:(NSString *)targetName
{
    self.isPoppedUp = YES;
    
    self.infoImageView.image = [UIImage imageNamed:[targetName stringByAppendingString:@"_Info"]];

    if ([[AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand count] < 7)
    {
        NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:[@"NEXT CARD:\n" stringByAppendingString:[self getRandomHint]] ];
        [hintText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, hintText.length)];
        [hintText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Bold" size:22.0f] range:NSMakeRange(0, 10)];
        [hintText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Md" size:22.0f] range:NSMakeRange(10, hintText.length - 10)];
        
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:0];
        [hintText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [hintText length])];
        
        self.hintLabel.attributedText = hintText;
    }
    
    else {
        NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:@"WELL DONE!\nNow see your final hand and submit it to the leaderboard."];
        [hintText addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, hintText.length)];
        [hintText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Bold" size:22.0f] range:NSMakeRange(0, 10)];
        [hintText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"NissanPro-Md" size:22.0f] range:NSMakeRange(10, hintText.length - 10)];
        
        NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
        [paragrahStyle setLineSpacing:0];
        [hintText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, [hintText length])];
        
        self.hintLabel.attributedText = hintText;
    }
    
    [UIView transitionWithView:self.bannerView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.bannerView.image = [UIImage imageNamed:@"TopRibbon"];
                    } completion:nil];
    
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.popupView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
                     completion:^(BOOL finished) {
                         [self.bigPlayingCard setRankAndSuitFromCard:baseCard];
                         PlayingCardView *miniCard = [self getNextUnflippedCard];
                         [miniCard setRankAndSuitFromCard:baseCard];
                         
                         [miniCard flipCardAnimated];
                         [self.bigPlayingCard flipCardAnimatedwithCompletion:^{
                             
                             [UIView animateWithDuration:1.0
                                              animations:^{
                                                  self.continueButton.alpha = 1.0;
                                              }
                              ];
                             
                         }];
                         
                     }
     
     ];


}

- (PlayingCardView *)getNextUnflippedCard
{
    for (PlayingCardView *card in self.handCardViews)
    {
        if (!card.isFaceup)
        {
            return card;
        }
    }
    
    return nil;
    
}

- (IBAction)continueTapped:(id)sender {
    
    if ([[AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand count] < 7)
    {
        [UIView transitionWithView:self.bannerView
                          duration:.75
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            self.bannerView.image = [UIImage imageNamed:@"TopChipRibbon"];
                        } completion:nil];
        
        [UIView animateWithDuration:.75
                         animations:^{
                             self.continueButton.alpha = 0.0;
                             self.popupView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.popupView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                             self.popupView.alpha = 1.0;
                             [self.bigPlayingCard flipCard];
                             
                             self.isPoppedUp = NO;
                         }
         ];
    }
    
    else
    {
        [self performSegueWithIdentifier:@"toFinalFromAR" sender:self];
    }
    
}

- (IBAction)adminRegionTriggered:(id)sender {
    
    UIAlertView *adminAV = [[UIAlertView alloc] initWithTitle:@"Administrator Access"
                                                      message:@"Choose a command"
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                            otherButtonTitles:@"Finish & Submit", @"Abondon Game", nil];
    adminAV.tag = UI_ALERTVIEW_ADMIN;
    
    [adminAV show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == UI_ALERTVIEW_ADMIN && ([[alertView buttonTitleAtIndex:buttonIndex] isEqual: @"Finish & Submit"]) ) {
        
        [AppDelegate sharedAppDelegate].currentPlayer.abandoned = YES;
        
        NSMutableArray *currentHand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand;
        
        while ([currentHand count] < 7) {
            
            [[AppDelegate sharedAppDelegate] dealCard];
            
        }
            
        [self performSegueWithIdentifier:@"toFinalFromAR" sender:self];
        
    }
    
    else if (alertView.tag == UI_ALERTVIEW_CONFIRM_ABONDON && buttonIndex != alertView.cancelButtonIndex){
        
        AppDelegate *ad = [AppDelegate sharedAppDelegate];
        
        ad.currentPlayer.gameDuration = (int) (round( [[NSDate date] timeIntervalSince1970] ) - ad.currentPlayer.timeStartedGame);
        
        ad.currentPlayer.abandoned = YES;
        ad.currentPlayer.finished = NO;
        
        AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        NSDictionary *name = @{@"firstName": ad.currentPlayer.firstName,
                               @"lastName": ad.currentPlayer.lastName};
        
        NSDictionary *metrics = @{@"deviceID": ad.currentPlayer.deviceId,
                                  @"timeStartedGame": [NSNumber numberWithInt: ad.currentPlayer.timeStartedGame],
                                  @"gameDuration": [NSNumber numberWithInt: ad.currentPlayer.gameDuration],
                                  @"abandoned": [NSNumber numberWithBool:ad.currentPlayer.abandoned],
                                  @"complete": [NSNumber numberWithBool:ad.currentPlayer.finished]};
        
        NSDictionary *params = @{@"name": name,
                                 @"hand": [ad.currentPlayer.pokerHand bestHandNetworkArray],
                                 @"score": [NSNumber numberWithInt: ad.currentPlayer.pokerHand.handValue],
                                 @"description": ad.currentPlayer.pokerHand.handDescription,
                                 @"metrics": metrics};
        
        
        NSString *baseURL = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:@"leaderboardAddress"];
        NSString *submitURL = [baseURL stringByAppendingString:@"/players/register"];
        
        [manager POST:submitURL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"HTTP: %@", responseObject);
            
            [self performSelector:@selector(adbandonAllHope)
                       withObject:nil
                       afterDelay:1.5];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            [[AppDelegate sharedAppDelegate] addCurentCustomerToCoreData];
            
            [self performSelector:@selector(adbandonAllHope)
                       withObject:nil
                       afterDelay:1.5];
        }];
    }
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag == UI_ALERTVIEW_ADMIN && [[alertView buttonTitleAtIndex:buttonIndex]  isEqual: @"Abondon Game"]){
        
        UIAlertView *confirmAbondonAV = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                   message:@"This will cancel and clear the current game. You cannot undo this action"
                                                                  delegate:self
                                                         cancelButtonTitle:@"Cancel"
                                                         otherButtonTitles:@"Abondon Game", nil];
        confirmAbondonAV.tag = UI_ALERTVIEW_CONFIRM_ABONDON;
        
        [confirmAbondonAV show];
        
    }
    
}


/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
*/

@end
