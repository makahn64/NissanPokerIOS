//
//  AppDelegate.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/2/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "AppDelegate.h"
#import "PlayingCard+WithInterface.h"

@implementation AppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

+ (AppDelegate *)sharedAppDelegate
{
	return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

#pragma mark - Life Cycle Methods

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"hasLaunchedBefore"]){
    
        [[NSUserDefaults standardUserDefaults] setObject:@"http://node.appdelegates.net:8003" forKey:@"leaderboardAddress"];
        [[NSUserDefaults standardUserDefaults] setInteger:10 forKey:@"timeout"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"QRScanningEnabled"];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasLaunchedBefore"];
        [[NSUserDefaults standardUserDefaults] setInteger:NV200 forKey:@"targetVehicle"];
        
        #ifdef NV200
            [[NSUserDefaults standardUserDefaults] setInteger: forKey:@"targetVehicle"];
        #elif CARGOSR
            [[NSUserDefaults standardUserDefaults] setInteger:NV_CARGO_STANDARD forKey:@"targetVehicle"];
        #elif CARGOHR
            [[NSUserDefaults standardUserDefaults] setInteger:NV_CARGO_HIGH_ROOF forKey:@"targetVehicle"];
        #endif
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Da Game

- (PokerCard *)dealCard{
    
    PokerCard *newCard = [self.currentPlayer getNewCard];
    return newCard;
    
}

#pragma mark - Player Gets and Saves

- (void)addCurentCustomerToCoreData{
    
    Customer *newCustomer = [NSEntityDescription
                                    insertNewObjectForEntityForName:@"Customer"
                                    inManagedObjectContext:[self managedObjectContext]];
    
    newCustomer.firstName = self.currentPlayer.firstName;
    newCustomer.lastName = self.currentPlayer.lastName;
    newCustomer.createdTime = [NSNumber numberWithDouble: self.currentPlayer.timeStartedGame];
    newCustomer.finishedGame = [NSNumber numberWithBool: self.currentPlayer.finished];
    newCustomer.abandonedGame = [NSNumber numberWithBool:self.currentPlayer.abandoned];
    newCustomer.uploaded = [NSNumber numberWithBool:NO];
    newCustomer.handValue = [NSNumber numberWithInt:self.currentPlayer.pokerHand.handValue];
    newCustomer.handDescription = self.currentPlayer.pokerHand.handDescription;
    
    newCustomer.gameDuration = [NSNumber numberWithDouble: self.currentPlayer.gameDuration];
    newCustomer.deviceID = self.currentPlayer.deviceId;
    newCustomer.vehicle = self.currentPlayer.vehicle;
    
    for (PokerCard *card in self.currentPlayer.pokerHand.bestFiveCardHand){
        PlayingCard *newCDCard = [PlayingCard playingCardFromPokerCard:card];
        [newCustomer addPokerHandObject:newCDCard];
    }
    
    [self saveContext];
    
}

-(void)saveContext{
    
    [[self managedObjectContext] save:nil];

}

#pragma mark - Core Data stack

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NissanPokerModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NissanPoker.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Custom Colors and Fonts

+ (UIColor *)nissanRed
{
    return [UIColor colorWithRed:0.77647f green:0.08627f blue:0.2f alpha:1.0f];
}

+ (UIColor *)nissanGrey
{
    return [UIColor colorWithRed:0.30196f green:0.30196f blue:0.30196f alpha:1.0f];
}

@end
