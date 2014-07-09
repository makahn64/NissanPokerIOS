//
//  Customer.h
//  NissanPoker
//
//  Created by Jasper Kahn on 7/7/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class PlayingCard;

@interface Customer : NSManagedObject

@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSSet *pokerHand;
@end

@interface Customer (CoreDataGeneratedAccessors)

- (void)addPokerHandObject:(PlayingCard *)value;
- (void)removePokerHandObject:(PlayingCard *)value;
- (void)addPokerHand:(NSSet *)values;
- (void)removePokerHand:(NSSet *)values;

@end
