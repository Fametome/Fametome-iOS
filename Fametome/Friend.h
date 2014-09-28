//
//  Friend.h
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friend : NSManagedObject

@property (nonatomic, retain) NSData * avatar;
@property (nonatomic, retain) NSData * cover;
@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic) int16_t device;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSString * parseId;

@end
