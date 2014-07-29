/*===============================================================================
Copyright (c) 2012-2014 Qualcomm Connected Experiences, Inc. All Rights Reserved.

Vuforia is a trademark of QUALCOMM Incorporated, registered in the United States 
and other countries. Trademarks of QUALCOMM Incorporated are used with permission.
===============================================================================*/

#import <UIKit/UIKit.h>
#import "ADQCARImageTargetsEAGLView.h"
#import "ADQCARApplicationSession.h"
#import <QCAR/DataSet.h>

// QCARApplicationControl is defined in the QCARApplicationSession class

@interface ADQCARImageTargetsViewController : UIViewController <ADQCARApplicationControl, ADQCARImageTargetsEAGLViewDelegate>{
    CGRect viewFrame;
    ADQCARImageTargetsEAGLView* eaglView;
    QCAR::DataSet*  dataSetCurrent;
    QCAR::DataSet*  dataSetNew;

    QCAR::DataSet*  dataSetTarmac;
    QCAR::DataSet*  dataSetStonesAndChips;
    UITapGestureRecognizer * tapGestureRecognizer;
    ADQCARApplicationSession * vapp;
    
    BOOL switchToTarmac;
    BOOL switchToStonesAndChips;
    BOOL extendedTrackingIsOn;
    
}

@property (nonatomic) UIInterfaceOrientation orientation;
@property (nonatomic) BOOL autorotate;
@property (nonatomic) BOOL hideNavigationBar;

// Override this in subclass to get notification
-(void)targetAcquired:(NSNotification *)notification;

@end
