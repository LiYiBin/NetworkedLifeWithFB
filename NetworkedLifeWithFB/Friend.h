//
//  Friend.h
//  NetworkedLifeWithFB
//
//  Created by YiBin on 13/5/16.
//  Copyright (c) 2013年 YiBin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Checkin, Like, User;

@interface Friend : NSManagedObject

@property (nonatomic, retain) NSString * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * scoreOfCheckins;
@property (nonatomic, retain) NSNumber * scoreOfLikes;
@property (nonatomic, retain) NSNumber * sumOfScore;
@property (nonatomic, retain) NSSet *checkins;
@property (nonatomic, retain) NSSet *likes;
@property (nonatomic, retain) User *user;
@end

@interface Friend (CoreDataGeneratedAccessors)

- (void)addCheckinsObject:(Checkin *)value;
- (void)removeCheckinsObject:(Checkin *)value;
- (void)addCheckins:(NSSet *)values;
- (void)removeCheckins:(NSSet *)values;

- (void)addLikesObject:(Like *)value;
- (void)removeLikesObject:(Like *)value;
- (void)addLikes:(NSSet *)values;
- (void)removeLikes:(NSSet *)values;

@end
