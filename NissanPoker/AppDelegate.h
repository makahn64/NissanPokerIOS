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

- (NSURL *)applicationDocumentsDirectory;
- (void)addCurentCustomerToCoreDataFinished:(BOOL)finishedGame;
- (void)saveContext;

- (PokerCard *)dealCard;


@end
