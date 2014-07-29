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

#define UI_ALERTVIEW_QUIT 200

@interface ARScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *infoPopupView;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet PlayingCardView *bigPlayingCard;

@property (weak, nonatomic) IBOutlet UICollectionView *currentHandCollectionView;

/*
@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;
*/

@property (strong, nonatomic) NSMutableArray *validARTargetValues;

@end


@implementation ARScannerViewController


#pragma mark - Target AR Values

+ (NSArray *)getValidARTargetValues
{
    return @[@"Chip_01",
             @"Chip_02",
             @"UglyTarget",
             @"NissanPokerTarget4",
             @"NissanPokerTarget5",
             @"NissanPokerTarget6",
             @"NissanPokerTarget7"];
}

#pragma mark - Life Cycle of View


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ADQCARImageTargetsEAGLView *ev = (ADQCARImageTargetsEAGLView *)self.view;
    [ev setAugmentationType:AUGMENT_NONE];
    
    [AppDelegate sharedAppDelegate].currentPlayer = [[PokerPlayer alloc] init];
    
    self.hand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand;
    
    // [mak] moved this here from the video setup which is no longer needed.
    // it should have been here anyway sinceit was unrelated to the video setup.
    self.validARTargetValues = [NSMutableArray arrayWithArray:[ARScannerViewController getValidARTargetValues]];

    
    [self setupCardViews];
    [self setupNewCustomer];
    //[self setupVideoCaptureSession];
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

- (void)setupNewCustomer
{
    AppDelegate *appD = [AppDelegate sharedAppDelegate];
    
    Customer *c = [appD getNewCustomer];
    c.firstName = @"NewCustomer";
    c.lastName = @"Unassigned";
    c.emailAddress = @"test@appdelegates.com";
    [appD saveContext];
    
    self.customer = c;
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

/*

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        
        AVMetadataMachineReadableCodeObject *metadataObj = [metadataObjects objectAtIndex:0];
        
        if ([[metadataObj type] isEqualToString:AVMetadataObjectTypeQRCode])
        {
            if ( [self.validQRTargetValues containsObject:[metadataObj stringValue]] )
            {
                NSLog(@"Read %@", [metadataObj stringValue]);
                
                [self performSelectorOnMainThread:@selector(alertQRScanned:)
                                       withObject:[metadataObj stringValue]
                                    waitUntilDone:NO];
                
                [self.validQRTargetValues removeObject: [metadataObj stringValue] ];
                [self.captureSession stopRunning];
            }
            
        }

    }
}
 
 */

- (void)alertARScanned:(NSString *)qrMessage
{
    
    PokerCard *newCard = [[AppDelegate sharedAppDelegate] dealCard];
    [self.customer addPokerHandObject:[PlayingCard playingCardFromPokerCard:newCard]];
    
    [[AppDelegate sharedAppDelegate] saveContext];
    
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
        AppDelegate *appD = [AppDelegate sharedAppDelegate];
        
        Customer *c = [appD getNewCustomer];
        //c.pokerHand = [NSSet setWithArray:self.currentHand];
        [appD saveContext];
        [self performSegueWithIdentifier:@"submitScreenSegue" sender:self];
    }
    
}


/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ( [[segue destinationViewController] isKindOfClass:[SubmitHandViewController class]] )
    {
        SubmitHandViewController *shvc = (SubmitHandViewController *)[segue destinationViewController];
        shvc.currentHandViews = self.currentHandViews;
        shvc.currentHandCards = self.currentHandCards;
    }
    

}
*/

@end
