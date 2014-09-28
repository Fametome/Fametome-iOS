//
//  FTCoreDataStack.h
//  Fametome
//
//  Created by Famille on 11/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FTCoreDataStack : NSObject

+ (instancetype) defaultStack;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
@end
