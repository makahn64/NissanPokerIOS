//
//  QRScannerViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "QRScannerViewController.h"
#import "InfoEntryViewController.h"
#import "PlayingCard+WithInterface.h"
#import "PlayingCardView.h"
#import "PokerHand.h"

#define UI_ALERTVIEW_ADMIN 200
#define UI_ALERTVIEW_CONFIRM_ABONDON 201

@interface QRScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *bannerView;

@property (weak, nonatomic) IBOutlet UIView *popupView;
@property (weak, nonatomic) IBOutlet UIImageView *infoImageView;
@property (weak, nonatomic) IBOutlet UILabel *hintLabel;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@property (weak, nonatomic) IBOutlet PlayingCardView *bigPlayingCard;

@property (weak, nonatomic) IBOutlet UICollectionView *currentHandCollectionView;

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;

@property (strong, nonatomic) NSMutableArray *validQRTargetValues;
@property (strong, nonatomic) NSMutableDictionary *remainingHints;

@end


@implementation QRScannerViewController


#pragma mark - Target QR Values

+ (NSArray *)getValidQRTargetValues
{
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
}


+ (NSDictionary *)getHints
{
    return @{@"Target_1" : @"Load the rear cabin without any hassle, we're flexible.",
             @"Target_2" : @"You can quickly and safely load the van from either side.",
             @"Target_3" : @"A great curb-to-curb turning radius is my specialty.",
             @"Target_4" : @"We can open wide for unobstructed loading.",
             @"Target_5" : @"Compact van? Loading cargo feels more like a full-size cargo van.",
             @"Target_6" : @"This is when your cargo says, \"Doors? What doors?\"",
             @"Target_7" : @"Flat load plywood or a couple pallets of cargo...I got this.",
             @"Target_8" : @"An early start or a long day, we brighten your whole day.",
             @"Target_9" : @"Powered mobile office...got it!",
             @"Target_10" : @"I can charge your power tools anytime.",
             @"Target_11" : @"Sometimes you need to think inside the box.",
             @"Target_12" : @"There is no doubt you will stop when you need to.",
             @"Target_13" : @"Safety...check!",
             @"Target_14" : @"Stop crouching and stand up!",
             @"Target_15" : @"We're here to help strap down those heavy packages.",
             @"Target_16" : @"Installing shelves, cabinets and racks are no problem with these.",
             @"Target_17" : @"Is it a seat or a desk?...What is your preference?",
             @"Target_18" : @"A fully organized mobile office at your fingertips."};
}

 
#pragma mark - Life Cycle of View

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
    
    [self setupCardViews];
    [self setupVideoCaptureSession];
    
    //Setup the valid target array
    self.validQRTargetValues = [NSMutableArray arrayWithArray:[QRScannerViewController getValidQRTargetValues]];
    self.remainingHints = [NSMutableDictionary dictionaryWithDictionary:[QRScannerViewController getHints]];
    
    [self.bigPlayingCard makeLarge];
    
    [self setupPopupViews];
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setup Utilities

- (void)setupCardViews
{
    self.handCardViews = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 7; i++)
    {
        CGRect newCardFrame = CGRectMake(0, 0, 82, 115);
        PlayingCardView *newCard = [[PlayingCardView alloc] initWithFrame:newCardFrame andIsSmall:YES];
        
        [self.handCardViews addObject:newCard];
    }
    
    UICollectionViewFlowLayout *flow = (UICollectionViewFlowLayout*) self.currentHandCollectionView.collectionViewLayout;
    flow.minimumInteritemSpacing = 2;
    
    [self.currentHandCollectionView reloadData];
}

- (void)setupVideoCaptureSession
{
    //Error for assigning input to device
    NSError *error;
    
    //Get the device we're scanning from
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //Assign the device to the input object
    self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    
    if (!self.captureInput) {
        NSLog(@"%@", [error localizedDescription]);
        //TODO: Look at NSAssert
    }
    
    else {
        //Put the input through a seesion
        self.captureSession = [[AVCaptureSession alloc] init];
        [self.captureSession addInput:self.captureInput];
        
        //Feed the session to a metadata output object
        self.captureMetadataOutput = [[AVCaptureMetadataOutput alloc] init];
        [self.captureSession addOutput:self.captureMetadataOutput];
        
        //Queue for outputted metadata recognition events
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("myQueue", NULL);
        
        //Setup the queue with the output
        [self.captureMetadataOutput setMetadataObjectsDelegate:self queue:dispatchQueue];
        [self.captureMetadataOutput setMetadataObjectTypes:[NSArray arrayWithObject:AVMetadataObjectTypeQRCode]];
        
        //Setup the preview layer on the UI
        self.videoPreviewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [self.videoPreviewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
        [self.videoPreviewLayer setFrame:self.videoPreviewView.layer.bounds];
        [self.videoPreviewView.layer addSublayer:_videoPreviewLayer];
        
        //Setup the video and capture input to match the screen
        AVCaptureConnection *connection;
        connection = [self.videoPreviewLayer connection];
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        
        CGRect visiblePreviewRegion = CGRectMake(0, 0, 1024, 768);
        CGRect metaDataInterestRect = [self.videoPreviewLayer metadataOutputRectOfInterestForRect:visiblePreviewRegion];
        self.captureMetadataOutput.rectOfInterest = metaDataInterestRect;
        
        [self.captureSession startRunning];
    }
    
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


#pragma mark - Actions

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
                
                [self.remainingHints removeObjectForKey:[metadataObj stringValue]];
                
                [self.validQRTargetValues removeObject: [metadataObj stringValue] ];
                [self.captureSession stopRunning];
                
                [self performSelectorOnMainThread:@selector(alertQRScanned:)
                                       withObject:[metadataObj stringValue]
                                    waitUntilDone:NO];
                
            }
            
        }

    }
    
}

- (void)alertQRScanned:(NSString *)qrMessage
{
    
    PokerCard *newCard = [[AppDelegate sharedAppDelegate] dealCard];
    
    [self displayCard: newCard withTarget:qrMessage];
    
}

- (void)displayCard:(PokerCard *)baseCard withTarget:(NSString *)targetName
{
    self.infoImageView.image = [UIImage imageNamed:[targetName stringByAppendingString:@"_Info"]];
    
    NSMutableAttributedString *hintText = [[NSMutableAttributedString alloc] initWithString:[@"Next Stop: " stringByAppendingString:[self getRandomHint]] ];
    [hintText addAttribute:NSForegroundColorAttributeName value:[AppDelegate nissanRed] range:NSMakeRange(0, 10)];
    [hintText addAttribute:NSForegroundColorAttributeName value:[AppDelegate nissanGrey] range:NSMakeRange(11, hintText.length - 1)];
    
    self.hintLabel.attributedText = hintText;
    
    [UIView transitionWithView:self.bannerView
                      duration:1.0
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        self.bannerView.image = [UIImage imageNamed:@"Top"];
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

                     }];
    
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
                            self.bannerView.image = [UIImage imageNamed:@"TopChip"];
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
                             [self.captureSession startRunning];
                             
                         }];
        
    }
    
    else
    {
        [self performSegueWithIdentifier:@"toFinalFromQR" sender:self];
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
            
            [self performSegueWithIdentifier:@"toFinalFromQR" sender:self];
            
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
        
        [self.navigationController popToRootViewControllerAnimated:YES];
        
    }
    
}



/*
#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}
*/

@end
