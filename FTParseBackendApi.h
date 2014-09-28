//
//  FTParseBackendApi.h
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "FTToolBox.h"
#import "FTCoreDataApi.h"
#import "MBProgressHUD.h"
// Redirection & Redirection
#import "FTLeftMenuViewController.h"

@interface FTParseBackendApi : NSObject

+ (FTParseBackendApi*)sharedGlobalData;

/* Global functions */
#pragma mark - Helper Methods

#pragma mark - SignUp Method
- (void) signUp:(NSString *)email withUsername:(NSString *)username andWithPassword:(NSString *)password fromController:(UIViewController *)currentController andWithEmailField:(UITextField *)emailField and:(UITextField *)usernameField and:(UITextField *)passwordField;
// Helper method for @selector
- (void) redirectToProfil:(UIViewController *)currentController;

#pragma mark - Login Method
- (void) login:(NSString *)username withPassword:(NSString *)password fromController:(UIViewController *)currentController andWithUsernameField:(UITextField *)usernameField and:(UITextField *)passwordField;

#pragma mark - Profil Methods
- (void) addAvatarInBackground:(UIImage *)avatar andUpdate:(UIImageView *)avatarImageView forUser:(PFUser *)user inController:(UIViewController *)controller;

#pragma mark - Face Methods
- (void) addFaceInBackgroundAndCoreData:(NSString *)sms withImage:(UIImage *)image forUser:(PFUser *)user andController:(UIViewController *)viewController;

#pragma mark - Friends Methods
- (PFObject *) instantiateDemandFrom:(PFUser *)demandeur to:(PFUser*)receveur;
- (NSMutableArray *) getAllDemandesFor:(PFUser *)user;
- (NSMutableArray *) getAllObjectIdFriendsFor:(PFUser *)user;
- (void) sendRequestFrom:(PFUser *)demandeur toBeFriendWith:(PFUser *)receveur;
- (void) acceptRelation:(PFObject *)relation;
- (void) refusedRelation:(PFObject *)relation;


#pragma mark - Message Methods
- (PFObject *) instantiateEmptyMessageFrom:(NSString *)auteurObjectId to:(NSString *)receveurObjectId;
- (PFObject *) instantiateEmptyFlashForMessage:(PFObject *)message;
- (NSMutableArray *) getAllMessagesWithoutFlashForUser:(PFUser *)user;

@end