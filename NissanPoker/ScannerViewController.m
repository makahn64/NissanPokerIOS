//
//  QRScannerViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "ScannerViewController.h"
#import "SubmitHandViewController.h"
#import "PlayingCard+WithInterface.h"
#import "PlayingCardView.h"
#import "PokerHand.h"

#define UI_ALERTVIEW_QUIT 200

@interface ScannerViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *infoPopupView;
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

@end


@implementation ScannerViewController


#pragma mark - Target QR Values

+ (NSArray *)getValidQRTargetValues
{
    return @[@"NissanPokerTarget1",
             @"NissanPokerTarget2",
             @"NissanPokerTarget3",
             @"NissanPokerTarget4",
             @"NissanPokerTarget5",
             @"NissanPokerTarget6",
             @"NissanPokerTarget7"];
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
    
    [AppDelegate sharedAppDelegate].currentPlayer = [[PokerPlayer alloc] init];
    
    self.hand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand.hand;
    
    [self setupCardViews];
    [self setupNewCustomer];
    [self setupVideoCaptureSession];
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

- (void)setupVideoCaptureSession
{
    //Error for assigning input to device
    NSError *error;
    
    //Get the device we're scanning from
    self.captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //NSArray *availDevices = [AVCaptureDevice devices];
    
    //Assign the device to the input object
    self.captureInput = [AVCaptureDeviceInput deviceInputWithDevice:self.captureDevice error:&error];
    
    if (!self.captureInput) {
        NSLog(@"%@", [error localizedDescription]);
        //TODO Look at NSAssert
    }
    else
    {
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
        
        CGRect visiblePreviewRegion = CGRectMake(0, 0, 627, 768);
        CGRect metaDataInterestRect = [self.videoPreviewLayer metadataOutputRectOfInterestForRect:visiblePreviewRegion];
        self.captureMetadataOutput.rectOfInterest = metaDataInterestRect;
        
        [_captureSession startRunning];
    }
    
    //Setup the valid target array
    
    self.validQRTargetValues = [NSMutableArray arrayWithArray:[ScannerViewController getValidQRTargetValues]];
    
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
                
                [self performSelectorOnMainThread:@selector(alertQRScanned:)
                                       withObject:[metadataObj stringValue]
                                    waitUntilDone:NO];
                
                [self.validQRTargetValues removeObject: [metadataObj stringValue] ];
                [self.captureSession stopRunning];
            }
            
        }

    }
}

- (void)alertQRScanned:(NSString *)qrMessage
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
    
    if ([self.validQRTargetValues count] > 0)
    {
        [UIView animateWithDuration:.75
                         animations:^{
                             self.continueButton.alpha = 0.0;
                             self.infoPopupView.alpha = 0.0;
                         }
                         completion:^(BOOL finished) {
                             self.infoPopupView.transform = CGAffineTransformMakeScale(0.0, 0.0);
                             self.infoPopupView.alpha = 1.0;
                             [self.captureSession startRunning];
                             
                         }
         ];
        //[self.captureSession startRunning];
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
