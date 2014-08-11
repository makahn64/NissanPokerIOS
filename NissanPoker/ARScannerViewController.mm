//
//  ARScannerViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Vuforia stiched in by [mak]
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "ARScannerViewController.h"
#import "SubmitHandViewController.h"
#import "PlayingCard+WithInterface.h"
#import "PlayingCardView.h"
#import "PokerHand.h"

#define UI_ALERTVIEW_ADMIN 200
#define UI_ALERTVIEW_CONFIRM_ABONDON 201

@interface ARScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *infoPopupView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet PlayingCardView *bigPlayingCard;

@property (weak, nonatomic) IBOutlet UICollectionView *currentHandCollectionView;

@property (strong, nonatomic) NSMutableArray *validARTargetValues;

@end


@implementation ARScannerViewController


#pragma mark - Target AR Values

+ (NSArray *)getValidARTargetValues
{
    return @[@"target1B",
             @"target2B",
             @"target3B",
             @"target4B",
             @"target5B",
             @"target6B",
             @"target7B"];
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
    
    [AppDelegate sharedAppDelegate].currentPlayer = [[PokerPlayer alloc] init];
    
    self.validARTargetValues = [NSMutableArray arrayWithArray:[ARScannerViewController getValidARTargetValues]];

    
    [self setupCardViews];
    [self setupPopupViews];
    
}


#pragma mark - Setup Utilities

- (void)setupCardViews
{
    self.handCardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++)
    {
        CGRect newCardFrame = CGRectMake(0, 0, 40, 56);
        PlayingCardView *newCard = [[PlayingCardView alloc] initWithFrame:newCardFrame];
        
        [self.handCardViews addObject:newCard];
    }
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*) self.currentHandCollectionView.collectionViewLayout;
    flow.minimumInteritemSpacing = 2;
    
    [self.currentHandCollectionView reloadData];
}

- (void)setupPopupViews
{
    self.infoPopupView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    self.continueButton.alpha = 0.0;
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
    //[cardView setFrame:cell.bounds];
    [cell addSubview:cardView];
    
    return cell;
}

#pragma mark - AR Recognition

-(void)targetAcquired:(NSNotification *)notification{
    
    NSDictionary *userinfo = [notification userInfo];
    
    NSString *arTargetName = [userinfo objectForKey:@"targetName"];
    NSLog(@"Target %@ acquired", arTargetName);
    
    float xlocInGlSpace = [(NSNumber *)[userinfo objectForKey:@"x-ingl"] floatValue];
    
    if (xlocInGlSpace > 50.0) {
        NSLog(@"Target %@ acquired outside of visible camera slice! [X in GL = %f]", arTargetName, xlocInGlSpace);
        return;

    }
    
    // TODO: Jasper, this is lifted from the QR code, clean it up.
    if ( [self.validARTargetValues containsObject:arTargetName] )
    {
        
        [self performSelectorOnMainThread:@selector(alertARScanned:)
                               withObject:arTargetName
                            waitUntilDone:NO];
        
        [self.validARTargetValues removeObject: arTargetName ];
    }

    
}


#pragma mark - Actions

- (void)alertARScanned:(NSString *)qrMessage
{
    
    PokerCard *newCard = [[AppDelegate sharedAppDelegate] dealCard];
    
    [self displayCard: newCard];
    
}

- (void)displayCard:(PokerCard *)baseCard
{
    [UIView animateWithDuration:1.0
                     animations:^{
                         self.infoPopupView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                     }
     ];
    
    if (self.bigPlayingCard.isFaceup)
    {
        [self.bigPlayingCard flipCardAnimatedwithCompletion:^{
            
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
                
                //[self displayCodeScannedAlertView:baseCard];
                
            }];
        }];
        
    }
    else
    {
        
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
    
    if ([self.validARTargetValues count] > 0)
    {
        [self.bigPlayingCard flipCardAnimated];
        [UIView animateWithDuration:.75
                         animations:^{
                             self.continueButton.alpha = 0.0;
                             self.infoPopupView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.infoPopupView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                             self.infoPopupView.alpha = 1.0;
                             
                         }
         ];
    }
    
    else
    {
        [self performSegueWithIdentifier:@"toSubmitFromAR" sender:self];
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
    
    if (alertView.tag == UI_ALERTVIEW_ADMIN && buttonIndex != alertView.cancelButtonIndex) {
        
        if ([[alertView buttonTitleAtIndex:buttonIndex]  isEqual: @"Finish & Submit"]){
            
            NSMutableArray *currentHand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand;
            
            while ([currentHand count] < 7) {
                
                [[AppDelegate sharedAppDelegate] dealCard];
                
            }
            
            [self performSegueWithIdentifier:@"toSubmitFromAR" sender:self];
            
        }
        
        else if ([[alertView buttonTitleAtIndex:buttonIndex]  isEqual: @"Abondon Game"]){
            
            UIAlertView *confirmAbondonAV = [[UIAlertView alloc] initWithTitle:@"Are you sure?"
                                                                       message:@"This will cancel and clear the current game. You cannot undo this action"
                                                                      delegate:self
                                                             cancelButtonTitle:@"Cancel"
                                                             otherButtonTitles:@"Abondon Game", nil];
            confirmAbondonAV.tag = UI_ALERTVIEW_CONFIRM_ABONDON;
            
            [confirmAbondonAV show];
            
        }
        
    }
    
    else if (alertView.tag == UI_ALERTVIEW_CONFIRM_ABONDON && buttonIndex != alertView.cancelButtonIndex){
        
        [self performSelector:@selector(adbandonAllHope)
                   withObject:nil
                    afterDelay:1.5];
    }
    
}




/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

}
*/

@end
