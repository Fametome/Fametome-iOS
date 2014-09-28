//
//  FTCoreDataApi.h
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FTCoreDataStack.h"
#import "Face.h"
#import "Friend.h"

@interface FTCoreDataApi : NSObject

+ (FTCoreDataApi*)sharedGlobalData;

/* Global functions */
- (NSManagedObjectContext *)getContext;
#pragma mark - Face Methods
- (BOOL) addFaceInCoreData:(NSString *)sms andWithImage:(NSData *)image;
- (NSMutableArray *) getAllFacesInCoreData;
- (void) listAllFacesInConsole;

#pragma mark - Friend Methods
- (BOOL) addFriendInCoreData:(NSData *)avatar withCover:(NSData *)cover withEmail:(NSString *)email withUsername:(NSString *)username andWithObjectId:(NSString *)objectId;
- (BOOL) removeFriendInCoreDataWithObjectId:(NSString *)objectId;
- (NSMutableArray *) getAllFriendsInCoreData;
- (BOOL) isFriendWith:(PFUser *)user;
- (BOOL) haveFriend;
- (Friend *) getFriendInCoreDataWithObjectId:(NSString *)objectId;
- (void) listAllFriendsInConsole;

@end
