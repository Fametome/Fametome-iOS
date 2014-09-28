//
//  Face.h
//  Fametome
//
//  Created by Famille on 11/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Face : NSManagedObject

@property (nonatomic) NSTimeInterval createdAt;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSString * sms;

@end
