//
//  FTCoreDataApi.m
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTCoreDataApi.h"

@implementation FTCoreDataApi

static FTCoreDataApi *sharedGlobalData = nil;

+ (FTCoreDataApi*)sharedGlobalData {
    if (sharedGlobalData == nil) {
        sharedGlobalData = [[super allocWithZone:NULL] init];
        
        // initialize your variables here
        //sharedGlobalData.message = @"Default Global Message";
        
    }
    return sharedGlobalData;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self)
    {
        if (sharedGlobalData == nil)
        {
            sharedGlobalData = [super allocWithZone:zone];
            return sharedGlobalData;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

// Get the current context for all other methods of this class
- (NSManagedObjectContext *)getContext{
    FTCoreDataStack *defaultStack = [FTCoreDataStack defaultStack];
    NSManagedObjectContext *context = defaultStack.managedObjectContext;
    return context;
}

#pragma mark - Face Methods
- (BOOL)addFaceInCoreData:(NSString *)sms andWithImage:(NSData *)image
{
    NSManagedObjectContext *context = [self getContext];
    
    Face *face = [NSEntityDescription insertNewObjectForEntityForName:@"Face" inManagedObjectContext:context];
    
    if(face == nil){
        NSLog(@"Failed to create the new Face.");
        return NO;
    }
        
    face.sms = sms;
    face.image = image;
    face.createdAt = [[NSDate date] timeIntervalSince1970];
    
    NSError *savingError = nil;
        
    if([context save:&savingError]) {
        NSLog(@"Face ajouté dans le cache.");
        return YES;
    }else{
        NSLog(@"Failed to save the context. Error = %@", savingError);
        return NO;
    }
}

- (NSMutableArray *)getAllFacesInCoreData
{
    NSManagedObjectContext *context = [self getContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Face"];
    
    NSError *requestError = nil;
    
    NSArray *faces = [context executeFetchRequest:fetchRequest error:&requestError];
    
    return [NSMutableArray arrayWithArray:faces];
}

- (void)listAllFacesInConsole
{
    NSManagedObjectContext *context = [self getContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Face"];
    
    NSError *requestError = nil;
    
    NSArray *faces = [context executeFetchRequest:fetchRequest error:&requestError];
    
    if([faces count] > 0){
        NSUInteger counter = 1;
        for(Face *thisFace in faces){
            NSLog(@"Face %lu Sms = %@", (unsigned long)counter, thisFace.sms);
            //NSLog(@"Face %lu Face = %@", (unsigned long)counter, thisFace.image);
            counter++;
        }
    }else{
        NSLog(@"Aucune faces dans CoreData.");
    }
    
}


#pragma mark - Friend Methods
- (BOOL) addFriendInCoreData:(NSData *)avatar withCover:(NSData *)cover withEmail:(NSString *)email withUsername:(NSString *)username andWithObjectId:(NSString *)objectId
{
    
    NSManagedObjectContext *context = [self getContext];
    Friend *newFriend = [NSEntityDescription insertNewObjectForEntityForName:@"Friend" inManagedObjectContext:context];
    
    if(newFriend == nil){
        NSLog(@"Failed to create the new Face.");
        return NO;
    }
    
    newFriend.parseId = objectId;
    newFriend.avatar = avatar;
    newFriend.cover = cover;
    newFriend.email = email;
    newFriend.username = username;
    newFriend.device = 1;
    newFriend.createdAt = [[NSDate date] timeIntervalSince1970];
    
    NSError *savingError = nil;
    
    if([context save:&savingError]) {
        NSLog(@"Friend ajouté dans le cache.");
        return YES;
    }else{
        NSLog(@"Failed to save the context. Error = %@", savingError);
        return NO;
    }
}

- (BOOL) removeFriendInCoreDataWithObjectId:(NSString *)objectId
{
    Friend *friend = [self getFriendInCoreDataWithObjectId:objectId];
    
    if(friend != nil){
        NSManagedObjectContext *context = [self getContext];
        [context deleteObject:friend];
        
        if([friend isDeleted]){
            NSLog(@"L'objet Friend %@ a bien été supprimé du cache.", friend.username);
            NSError *savingError = nil;
            if([context save:&savingError]){
                NSLog(@"Succefully save the context.");
            }else{
                NSLog(@"Failed to save the context.");
            }
            return YES;
        }else{
            NSLog(@"Failed to delete %@ du cache.", friend.username);
        }
    }
    
    return NO;
}

- (NSMutableArray *) getAllFriendsInCoreData
{
    NSManagedObjectContext *context = [self getContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    
    NSError *requestError = nil;
    
    NSArray *friends = [context executeFetchRequest:fetchRequest error:&requestError];
    
    return [NSMutableArray arrayWithArray:friends];
}

- (BOOL)isFriendWith:(PFUser *)user
{
    Friend *friend = [self getFriendInCoreDataWithObjectId:user.objectId];
    
    if(friend != nil){
        return YES;
    }else{
        return NO;
    }
}

- (BOOL) haveFriend
{
    NSMutableArray *friends = [self getAllFriendsInCoreData];
    
    if(friends.count > 0){
        return YES;
    }else{
        return NO;
    }
    
}


- (Friend *) getFriendInCoreDataWithObjectId:(NSString *)objectId
{
    NSManagedObjectContext *context = [self getContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"Friend" inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(parseId = %@)", objectId];
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *user = [context executeFetchRequest:request error:&error];
    
    if(user.count == 1){
        return [user firstObject];
    }else{
        return nil;
    }
}

- (void) listAllFriendsInConsole
{
    NSManagedObjectContext *context = [self getContext];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Friend"];
    
    NSError *requestError = nil;
    
    NSArray *friends = [context executeFetchRequest:fetchRequest error:&requestError];
    
    if([friends count] > 0){
        NSUInteger counter = 1;
        for(Friend *thisFriend in friends){
            NSLog(@"Face %lu Username = %@ &&, Email = %@ and Device = %i", (unsigned long)counter, thisFriend.username, thisFriend.email, thisFriend.device);
            counter++;
        }
    }else{
        NSLog(@"Aucun amis dans CoreData.");
    }
}
























@end
