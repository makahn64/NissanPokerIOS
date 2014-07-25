//
//  QRScannerViewController.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScannerViewController : UIViewController <UIAlertViewDelegate, AVCaptureMetadataOutputObjectsDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) NSMutableArray *handCardViews;
@property (strong, nonatomic) NSMutableArray *hand;
@property (nonatomic, strong) Customer *customer;

+ (NSArray *)getValidQRTargetValues;

@end
