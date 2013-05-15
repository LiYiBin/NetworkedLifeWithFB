//
//  Checkin.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/15.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Friend, User;

@interface Checkin : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *friends;
@property (nonatomic, retain) User *myself;
@end

@interface Checkin (CoreDataGeneratedAccessors)

- (void)addFriendsObject:(Friend *)value;
- (void)removeFriendsObject:(Friend *)value;
- (void)addFriends:(NSSet *)values;
- (void)removeFriends:(NSSet *)values;

@end
