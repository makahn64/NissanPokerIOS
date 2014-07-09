//
//  QRScannerViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "QRScannerViewController.h"
#import "PlayingCard+WithInterface.h"

#define UI_ALERTVIEW_QR_SCANNED 250
#define UI_ALERTVIEW_LAST_QR_SCANNED 200

@interface QRScannerViewController ()

@property (weak, nonatomic) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoPreviewLayer;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureDevice *captureDevice;
@property (strong, nonatomic) AVCaptureDeviceInput *captureInput;
@property (strong, nonatomic) AVCaptureMetadataOutput *captureMetadataOutput;

@property (strong, nonatomic) NSMutableArray *validQRTargetValues;

@end


@implementation QRScannerViewController


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
        
        //NSArray *availMtypes = [self.captureMetadataOutput availableMetadataObjectTypes];
        
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
        //[self.videoPreviewLayer setOrientation:AVCaptureVideoOrientationLandscapeRight];
        AVCaptureConnection *connection;
        connection = [self.videoPreviewLayer connection];
        [connection setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
        
        [_captureSession startRunning];
    }
    
    //Setup the valid target array
    
    self.validQRTargetValues = [NSMutableArray arrayWithArray:[QRScannerViewController getValidQRTargetValues]];
    
    
}

-(void)viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (metadataObjects != nil && [metadataObjects count] > 0)
    {
        //[self.captureSession stopRunning];
        
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
    
    if ([self.validQRTargetValues count] > 0)
    {
        UIAlertView *alertQRValue = [[UIAlertView alloc]
                                  initWithTitle: qrMessage
                                  message:newCard.rankSuit
                                  delegate:self
                                  cancelButtonTitle:@"Keep Playing"
                                  otherButtonTitles:nil, nil];
        [alertQRValue setTag: UI_ALERTVIEW_QR_SCANNED];
        
        [alertQRValue show];
    }
    else
    {
        UIAlertView *alertLastQRValue = [[UIAlertView alloc]
                                     initWithTitle: qrMessage
                                     message:newCard.rankSuit
                                     delegate:self
                                     cancelButtonTitle:@"Finish Game"
                                     otherButtonTitles:nil, nil];
        [alertLastQRValue setTag: UI_ALERTVIEW_LAST_QR_SCANNED];
        
        [alertLastQRValue show];
    }
    
}

- (IBAction)quitTapped:(id)sender
{
    UIAlertView *quitAlert = [[UIAlertView alloc]
                              initWithTitle:@"Are you sure?"
                              message:@"You may not play again if you quit."
                              delegate:self
                              cancelButtonTitle:@"Cancel"
                              otherButtonTitles:@"Quit", nil];
    
    [quitAlert show];

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    /*
    if (alertView.tag == UI_ALERTVIEW_QR_SCANNED)
    {
        [self.captureSession startRunning];
    }
    
    else if (alertView.tag == UI_ALERTVIEW_LAST_QR_SCANNED)
    {
        NSMutableArray *finalHand = [AppDelegate sharedAppDelegate].currentPlayer.pokerHand;
        [self saveFinalHand:finalHand];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    else
    {
        if (buttonIndex != alertView.cancelButtonIndex) {
        
            [self.navigationController popToRootViewControllerAnimated:YES];
        
        }
    }
     */
}

- (IBAction)helpTapped:(id)sender
{
}

#pragma mark - Archive for NSUserDefaults Utility

- (void)saveFinalHand: (NSMutableArray *)hand
{
    NSMutableArray *archiveArray = [NSMutableArray arrayWithCapacity:hand.count];
    
    for (PokerCard *card in hand)
    {
        //NSData *pokerCardEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:card];
        //[archiveArray addObject:pokerCardEncodedObject];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:archiveArray forKey:@"Final Hand"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
