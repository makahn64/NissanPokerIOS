//
//  ARScannerViewController.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Vuforia stiched in my [mak]
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ADQCARImageTargetsViewController.h"

@interface ARScannerViewController : ADQCARImageTargetsViewController <UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray *handCardViews;
@property (strong, nonatomic) NSMutableArray *hand;
@property (nonatomic, strong) Customer *customer;

+ (NSArray *)getValidQRTargetValues;

@end
