/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

/*========================================================
 
 Modified by AppDelegates, LLC
 2014
 Author [mak]
 
 =========================================================*/

#import "ADQCARImageTargetsViewController.h"
#import <QCAR/QCAR.h>
#import <QCAR/TrackerManager.h>
#import <QCAR/ImageTracker.h>
#import <QCAR/Trackable.h>
#import <QCAR/DataSet.h>
#import <QCAR/CameraDevice.h>

// Skips loading from the NIB and shoves EAGL as the root
// Shoving EAGL into an already loaded view isn't working yet, so leave this as is
// TODO: Why does inserting EAGL in an existing view hierarchy end up with wonky size?
#define USE_EAGL_AS_ROOT_VIEW 1
#define VERBOSE_DEBUG NO

@interface ADQCARImageTargetsViewController () {
    bool chipFound;
}

@end

@implementation ADQCARImageTargetsViewController

-(void)doInit{
    
    vapp = [[ADQCARApplicationSession alloc] initWithDelegate:self];
    
    
    // Create the EAGLView with the screen dimensions
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    viewFrame = screenBounds;
    
    // If this device has a retina display, scale the view bounds that will
    // be passed to QCAR; this allows it to calculate the size and position of
    // the viewport correctly when rendering the video background
    if (YES == vapp.isRetinaDisplay) {
        viewFrame.size.width *= 2.0;
        viewFrame.size.height *= 2.0;
    }
    
    dataSetCurrent = nil;
    extendedTrackingIsOn = NO;
    chipFound = NO;
    
    // a single tap will trigger a single autofocus operation
    tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(autofocus:)];
    
    // we use the iOS notification to pause/resume the AR when the application goes (or come back from) background
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseAR)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(resumeAR)
     name:UIApplicationDidBecomeActiveNotification
     object:nil];

    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(targetAcquired:)
     name:kADQCARRecognitionEvent
     object:nil];

}

// initWithCoder must be here for storyboard apps
-(id)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self doInit];
    }
    
    return self;

    
}

// initWithNidName here for XIB style init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self doInit];
    }
    return self;
}

- (void) pauseAR {
    NSError * error = nil;
    if (![vapp pauseAR:&error]) {
        NSLog(@"Error pausing AR:%@", [error description]);
    }
}

- (void) resumeAR {
    NSError * error = nil;
    if(! [vapp resumeAR:&error]) {
        NSLog(@"Error resuming AR:%@", [error description]);
    }
    // on resume, we reset the flash and the associated menu item
    QCAR::CameraDevice::getInstance().setFlashTorchMode(false);
    
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [tapGestureRecognizer release];
    
    [vapp release];
    [eaglView release];
    
    [super dealloc];
}

// This method overrides the normal loadView which would load from the XIB/Storyboard
// Kind of a hack, if you ask me!
/*
- (void)loadView
{
    
    [super loadView];

    // Create the EAGLView
    eaglView = [[ADQCARImageTargetsEAGLView alloc] initWithFrame:viewFrame appSession:vapp delegate:self];
    [self setView:eaglView];
    
    // show loading animation while AR is being initialized
    [self showLoadingAnimation];
    
    // initialize the AR session
    
    // TODO: Add support for orientation properties
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationPortrait];
    
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    //[self prepareMenu];

    eaglView = (ADQCARImageTargetsEAGLView *)self.view;
    [eaglView setArSession:vapp];
    [eaglView setDelegate:self];
    [vapp initAR:QCAR::GL_20 ARViewBoundsSize:viewFrame.size orientation:UIInterfaceOrientationLandscapeRight];
	// Do any additional setup after loading the view.
    // TODO: Add hide/show of Nav bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    NSLog(@"self.navigationController.navigationBarHidden:%d",self.navigationController.navigationBarHidden);
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [vapp stopAR:nil];
    // Be a good OpenGL ES citizen: now that QCAR is paused and the render
    // thread is not executing, inform the root view controller that the
    // EAGLView should finish any OpenGL ES commands
    [eaglView finishOpenGLESCommands];
    [eaglView freeOpenGLESResources];
}

- (void)finishOpenGLESCommands
{
    // Called in response to applicationWillResignActive.  Inform the EAGLView
    [eaglView finishOpenGLESCommands];
}


- (void)freeOpenGLESResources
{
    // Called in response to applicationDidEnterBackground.  Inform the EAGLView
    [eaglView freeOpenGLESResources];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - loading animation

- (void) showLoadingAnimation {
    CGRect mainBounds = [[UIScreen mainScreen] bounds];
    CGRect indicatorBounds = CGRectMake(mainBounds.size.width / 2 - 12,
                                        mainBounds.size.height / 2 - 12, 24, 24);
    UIActivityIndicatorView *loadingIndicator = [[[UIActivityIndicatorView alloc]
                                                  initWithFrame:indicatorBounds]autorelease];
    
    loadingIndicator.tag  = 1;
    loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    [eaglView addSubview:loadingIndicator];
    [loadingIndicator startAnimating];
}

- (void) hideLoadingAnimation {
    UIActivityIndicatorView *loadingIndicator = (UIActivityIndicatorView *)[eaglView viewWithTag:1];
    [loadingIndicator removeFromSuperview];
}

#pragma mark - ADQCARImageTargetEAGLView Notifications

-(void)targetAcquired:(NSNotification *)notification{
    
    NSDictionary *userinfo = [notification userInfo];
    NSLog(@"Target %@ acquired", [userinfo objectForKey:@"targetName"]);
    
    /*
    if (chipFound==NO){
        chipFound = YES;
        [self performSelectorOnMainThread:@selector(changeMode) withObject:nil waitUntilDone:YES];

    }
     */

    
}

-(void)changeMode {
    [self performSelector:@selector(changeMode2) withObject:nil afterDelay:3.0];

}

 -(void)changeMode2 {
 
     ADQCARImageTargetsEAGLView *iv = (ADQCARImageTargetsEAGLView *)self.view;
     [iv setAugmentationType:AUGMENT_PLANE];
     //[iv release];

 }

#pragma mark - QCARApplicationControl Delegates from the QCARSession

- (bool) doInitTrackers {
    // Initialize the image or marker tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    
    // Image Tracker...
    QCAR::Tracker* trackerBase = trackerManager.initTracker(QCAR::ImageTracker::getClassType());
    if (trackerBase == NULL)
    {
        NSLog(@"Failed to initialize ImageTracker.");
        return false;
    }
    NSLog(@"Successfully initialized ImageTracker.");
    return true;
}


// Probably useless for generic
- (bool) doLoadTrackersData {
    
    dataSetNew = [self loadImageTrackerDataSet:@"NSPoker2.xml"];

    if ( dataSetNew == NULL ) {
        NSLog(@"Failed to load dataset");
        return NO;
    }
    if (! [self activateDataSet:dataSetNew]) {
        NSLog(@"Failed to activate dataset");
        return NO;
    }
    
    
    return YES;
}

- (bool) doStartTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    if(tracker == 0) {
        return NO;
    }

    tracker->start();
    return YES;
}

// callback: the AR initialization is done
- (void) onInitARDone:(NSError *)initError {
    [self hideLoadingAnimation];
    
    if (initError == nil) {
        // If you want multiple targets being detected at once,
        // you can comment out this line
        // QCAR::setHint(QCAR::HINT_MAX_SIMULTANEOUS_IMAGE_TARGETS, 2);
        
        NSError * error = nil;
        [vapp startAR:QCAR::CameraDevice::CAMERA_BACK error:&error];
        
        // by default, we try to set the continuous auto focus mode
        bool isContinuousAutofocus = QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_CONTINUOUSAUTO);
        NSLog(@"Continuous autofocus: %@", isContinuousAutofocus ?  @"yes" : @"no");
        
    } else {
        NSLog(@"Error initializing AR:%@", [initError description]);
    }
}



- (void) onQCARUpdate: (QCAR::State *) state {
    
    if (VERBOSE_DEBUG)
        NSLog(@"ADQCARITVC QCAR update called");
    
    /*
    if (switchToTarmac) {
        [self activateDataSet:dataSetTarmac];
        switchToTarmac = NO;
    }
    if (switchToStonesAndChips) {
        [self activateDataSet:dataSetStonesAndChips];
        switchToStonesAndChips = NO;
    }
     */
}

// Load the image tracker data set from app resource bundle ONLY
- (QCAR::DataSet *)loadImageTrackerDataSet:(NSString*)dataFile
{
    NSLog(@"loadImageTrackerDataSet (%@)", dataFile);
    QCAR::DataSet * dataSet = NULL;
    
    // Get the QCAR tracker manager image tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (NULL == imageTracker) {
        NSLog(@"ERROR: failed to get the ImageTracker from the tracker manager");
        return NULL;
    } else {
        dataSet = imageTracker->createDataSet();
        
        if (NULL != dataSet) {
            NSLog(@"INFO: successfully loaded data set");
            
            // Load the data set from the app's resources location
            // TODO: Add support for other storage locations

            if (!dataSet->load([dataFile cStringUsingEncoding:NSASCIIStringEncoding], QCAR::STORAGE_APPRESOURCE)) {
                NSLog(@"ERROR: failed to load data set");
                imageTracker->destroyDataSet(dataSet);
                dataSet = NULL;
            }
        }
        else {
            NSLog(@"ERROR: failed to create data set");
        }
    }
    
    return dataSet;
}


- (bool) doStopTrackers {
    // Stop the tracker
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::Tracker* tracker = trackerManager.getTracker(QCAR::ImageTracker::getClassType());
    
    if (NULL != tracker) {
        tracker->stop();
        NSLog(@"INFO: successfully stopped tracker");
        return YES;
    }
    else {
        NSLog(@"ERROR: failed to get the tracker from the tracker manager");
        return NO;
    }
}

- (bool) doUnloadTrackersData {
    [self deactivateDataSet: dataSetCurrent];
    dataSetCurrent = nil;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    // Destroy the data sets:
    if (!imageTracker->destroyDataSet(dataSetTarmac))
    {
        NSLog(@"Failed to destroy data set Tarmac.");
    }
    if (!imageTracker->destroyDataSet(dataSetStonesAndChips))
    {
        NSLog(@"Failed to destroy data set Stones and Chips.");
    }
    
    NSLog(@"datasets destroyed");
    return YES;
}

- (BOOL)activateDataSet:(QCAR::DataSet *)theDataSet
{
    // if we've previously recorded an activation, deactivate it
    if (dataSetCurrent != nil)
    {
        [self deactivateDataSet:dataSetCurrent];
    }
    BOOL success = NO;
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (imageTracker == NULL) {
        NSLog(@"Failed to load tracking data set because the ImageTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!imageTracker->activateDataSet(theDataSet))
        {
            NSLog(@"Failed to activate data set.");
        }
        else
        {
            NSLog(@"Successfully activated data set.");
            dataSetCurrent = theDataSet;
            success = YES;
        }
    }
    
    // we set the off target tracking mode to the current state
    if (success) {
        [self setExtendedTrackingForDataSet:dataSetCurrent start:extendedTrackingIsOn];
    }
    
    return success;
}

- (BOOL)deactivateDataSet:(QCAR::DataSet *)theDataSet
{
    if ((dataSetCurrent == nil) || (theDataSet != dataSetCurrent))
    {
        NSLog(@"Invalid request to deactivate data set.");
        return NO;
    }
    
    BOOL success = NO;
    
    // we deactivate the enhanced tracking
    [self setExtendedTrackingForDataSet:theDataSet start:NO];
    
    // Get the image tracker:
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    QCAR::ImageTracker* imageTracker = static_cast<QCAR::ImageTracker*>(trackerManager.getTracker(QCAR::ImageTracker::getClassType()));
    
    if (imageTracker == NULL)
    {
        NSLog(@"Failed to unload tracking data set because the ImageTracker has not been initialized.");
    }
    else
    {
        // Activate the data set:
        if (!imageTracker->deactivateDataSet(theDataSet))
        {
            NSLog(@"Failed to deactivate data set.");
        }
        else
        {
            success = YES;
        }
    }
    
    dataSetCurrent = nil;
    
    return success;
}

- (BOOL) setExtendedTrackingForDataSet:(QCAR::DataSet *)theDataSet start:(BOOL) start {
    BOOL result = YES;
    for (int tIdx = 0; tIdx < theDataSet->getNumTrackables(); tIdx++) {
        QCAR::Trackable* trackable = theDataSet->getTrackable(tIdx);
        if (start) {
            if (!trackable->startExtendedTracking())
            {
                NSLog(@"Failed to start extended tracking on: %s", trackable->getName());
                result = false;
            }
        } else {
            if (!trackable->stopExtendedTracking())
            {
                NSLog(@"Failed to stop extended tracking on: %s", trackable->getName());
                result = false;
            }
        }
    }
    return result;
}

- (bool) doDeinitTrackers {
    QCAR::TrackerManager& trackerManager = QCAR::TrackerManager::getInstance();
    trackerManager.deinitTracker(QCAR::ImageTracker::getClassType());
    return YES;
}

- (void)autofocus:(UITapGestureRecognizer *)sender
{
    [self performSelector:@selector(cameraPerformAutoFocus) withObject:nil afterDelay:.4];
}

- (void)cameraPerformAutoFocus
{
    QCAR::CameraDevice::getInstance().setFocusMode(QCAR::CameraDevice::FOCUS_MODE_TRIGGERAUTO);
}

#pragma mark - View Delegates

-(NSMutableArray *)loadTextures {
    
    NSMutableArray *rval = [NSMutableArray new];
    Texture *t = [[Texture alloc] initWithImageFile:@"Nissan.png"];
    [rval addObject:t];
    return [rval autorelease];
    
}

#pragma mark - left menu

typedef enum {
    C_EXTENDED_TRACKING,
    C_AUTOFOCUS,
    C_FLASH,
    C_CAMERA_FRONT,
    C_CAMERA_REAR,
    SWITCH_TO_TARMAC,
    SWITCH_TO_STONES_AND_CHIPS,
} MENU_COMMAND;


@end
