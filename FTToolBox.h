//
//  FTToolBox.h
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
// Network detection
#import "Reachability.h"
#import <SystemConfiguration/SystemConfiguration.h>
// Redirection & Redirection
#import "FTLeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

#import "FTProfilViewController.h"

@interface FTToolBox : NSObject

+ (FTToolBox*)sharedGlobalData;

/* Global functions */
#pragma mark - Helper Methods
- (void) clearTextField:(UITextField *)textField;
- (void) showAlertWithTitle:(NSString *)title andDescription:(NSString *)description forController:(UIViewController *)controller;

#pragma mark - Network Status
- (BOOL) isNetworkAvailable;
- (void) networkUnavailableAlert;
- (NSString *) titleWhenNetworkUnavailable;
- (NSString *) subtitleWhenNetworkUnavailable;

#pragma mark - Redirection
- (void) redirectToProfil:(UIViewController *)currentController;
- (void) redirectToReception:(UIViewController *)currentController;
- (void) redirectToSendMessage:(UIViewController *)currentController;
- (void) redirectToFriends:(UIViewController *)currentController;
- (void) logout:(UIViewController *)currentController;

#pragma mark - Camera Helper methods
- (BOOL) isCameraAvailable;
- (UIImagePickerController *) activeCamera;
- (UIImagePickerController *) activeCameraNormal;
- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height;
- (UIImage *)resizeImageForFace:(UIImage *)image;
- (UIImage *)resizeImageForAvatar:(UIImage *)avatar;
- (UIImage *)rotateImage:(UIImage *)oldImage withDegrees:(CGFloat)degrees;

#pragma mark - Design Methods
- (void) designSingleUIImageView:(UIImageView *)imageView;
- (void) designExternTextField:(UITextField *)textField;
- (void) designSendTextField:(UITextField *)textField;
- (void) designExternButton:(UIButton *)button;
- (UIImage *) resizeImageForEmptyControllerImage:(UIImage *)image;
- (void) designNavbar:(UINavigationBar *)navigationBar;
- (void) makeCornerRadius:(UIView *)view;
- (void) makeCornerRadiusAndBorder:(UIView *)view;
- (void) activeRecipient:(UIView *)cell;
- (void) inactiveRecipient:(UIView *)cell;

#pragma mark - Loader Methods
- (void) stopLoaderForView:(UIView *)view;
- (void) startLoaderForView:(UIView *)view;
- (void) startLoaderWithTitle:(NSString *)title andDescription:(NSString *)description forView:(UIView *)view;
- (void) startLoaderWithTitle:(NSString *)title forView:(UIView *)view;
- (void) displayCheckmarkWithLabelText:(NSString *)text forView:(UIView *)view;
- (void) displayCheckmakForView:(UIView *)view;

#pragma mark - Send Flash Methods
- (NSMutableArray *) getFlashs;
- (void) saveFlashs:(NSMutableArray *)flashs;
- (int) getCurrentFlashIndex;
- (NSUserDefaults *)getDefaults;
- (void) synchronize;
- (void) resetDisk;

#pragma mark - Send Flash Verification Method
- (BOOL) isFlashsEmpty;
- (BOOL) isFlashEmpty:(NSMutableDictionary *)flash;
- (void) displayFlashs;

#pragma mark - Push Notification Methods
// Méthodes métier
- (void) sendPushForAddingFace;
- (void) sendPushForRelationshipRequest:(NSString *)friendId;
- (void) sendPushForAcceptRelationship:(NSString *)friendId;
- (void) sendPushForMessageToRecipients:(NSMutableArray *)recipientObjectIds;

// Méthodes d'aide
- (NSString *) getAuthorUsername;
- (NSDictionary *) getDataForPushNotificationWithMessage:(NSString *)message andTitle:(NSString *)title;
- (void) sendPushNotificationToFriend:(NSString *)objectId withTitle:(NSString *)title andMessage:(NSString *)message;

@end
