//
//  AppDelegate.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokerPlayer.h"
#import "Customer.h"
#import "PokerCard.h"
#import "PokerHand.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (strong, nonatomic) PokerPlayer *currentPlayer;


+ (AppDelegate *)sharedAppDelegate;

+ (UIColor *)nissanRed;
+ (UIColor *)nissanGrey;

- (NSURL *)applicationDocumentsDirectory;
- (void)addCurentCustomerToCoreData;
- (void)saveContext;

- (PokerCard *)dealCard;

typedef enum {
    NV200 = 0,
    NV_CARGO_STANDARD = 1,
    NV_CARGO_HIGH_ROOF = 2,
} TargetVehicle;

@end
