//
//  FTToolBox.m
//  Fametome
//
//  Created by Famille on 06/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTToolBox.h"

@implementation FTToolBox

static FTToolBox *sharedGlobalData = nil;

+ (FTToolBox*)sharedGlobalData {
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

/* Global functions */
#pragma mark - Helper Methods
- (void) clearTextField:(UITextField *)textField
{
    textField.text = @"";
}

- (void) showAlertWithTitle:(NSString *)title andDescription:(NSString *)description forController:(UIViewController *)controller
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:description delegate:controller cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - Network Status
- (BOOL) isNetworkAvailable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    
    return networkStatus != NotReachable;
}

- (void) networkUnavailableAlert
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Désolé..." message:@"Il semble que vous ne soyez pas connecter à Internet pour le momment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (NSString *) titleWhenNetworkUnavailable
{
    return @"Aucun réseau";
}

- (NSString *) subtitleWhenNetworkUnavailable
{
    return @"Réessayer de vous connecter avant de continuer";
}

#pragma mark - Redirection
- (void)redirectToProfil:(UIViewController *)currentController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ProfilViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:NO andCompletion:nil];
}

- (void)redirectToReception:(UIViewController *)currentController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"ReceptionViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:NO andCompletion:nil];
}

- (void)redirectToSendMessage:(UIViewController *)currentController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SendViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:NO andCompletion:nil];
}

- (void)redirectToFriends:(UIViewController *)currentController
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AmisViewController"];
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc withSlideOutAnimation:NO andCompletion:nil];
}

- (void)logout:(UIViewController *)currentController
{
    [PFQuery clearAllCachedResults];
    
    [PFUser logOut];
    
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [NSNull null];
    [installation saveEventually];
    
    [currentController.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Camera Helper Method
- (BOOL) isCameraAvailable
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
}

- (void) cameraUnavailableAlert{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Camera indisponible" message:@"Cet appareil ne vous permet pas de prendre de photos." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertView show];
}

- (UIImagePickerController *)activeCamera
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.showsCameraControls = YES;
    imagePicker.allowsEditing = NO;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    imagePicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    
    return imagePicker;
}

- (UIImagePickerController *)activeCameraNormal
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    imagePicker.showsCameraControls = YES;
    imagePicker.allowsEditing = NO;
    imagePicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    
    return imagePicker;
}

- (UIImage *)resizeImage:(UIImage *)image toWidth:(float)width andHeight:(float)height
{
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [image drawInRect: CGRectMake(0, 0, width, height)];
    UIImage *resizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizedImage;
}

- (UIImage *)resizeImageForFace:(UIImage *)image{
    return [self resizeImage:image toWidth:320 andHeight:480];
}

- (UIImage *)resizeImageForAvatar:(UIImage *)avatar{
    return [self resizeImage:avatar toWidth:140 andHeight:140];
}

- (UIImage *)rotateImage:(UIImage *)oldImage withDegrees:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
    CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
    
    //Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    //Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    //Rotate the image context
    CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
    
    //Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Design Methods
- (void) designSingleUIImageView:(UIImageView *)imageView
{
    CALayer * l = [imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [l setBorderWidth:4.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void) designExternTextField:(UITextField *)textField
{
    CALayer * l = [textField layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [l setBorderWidth:4.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void) designSendTextField:(UITextField *)textField
{
    CALayer * l = [textField layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
    [l setBorderWidth:4.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    textField.leftView = paddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void) designExternButton:(UIButton *)button
{
    CALayer * l = [button layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:10.0];
}

- (UIImage *)resizeImageForEmptyControllerImage:(UIImage *)image
{
    return [self resizeImage:image toWidth:240 andHeight:240];
}

- (void) designNavbar:(UINavigationBar *)navigationBar
{
    navigationBar.hidden = NO; // On peut se connecter par la (connexion)
    navigationBar.tintColor = [UIColor whiteColor]; // Couleur des boutons
    navigationBar.barTintColor = [UIColor orangeColor]; // Couleur en fond
    navigationBar.translucent = NO;
    [navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}]; // Couleur du texte
    
}

- (void) makeCornerRadius:(UIView *)view
{
    CALayer * l = [view layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
}

- (void) makeCornerRadiusAndBorder:(UIView *)view
{
    CALayer * l = [view layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:7.0];
    [l setBorderWidth:4.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
}

- (void) activeRecipient:(UIView *)cell
{
    CALayer * l = [cell layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:5.0];
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor orangeColor] CGColor]];
}

- (void) inactiveRecipient:(UIView *)cell
{
    CALayer * l = [cell layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:5.0];
    [l setBorderWidth:2.0];
    [l setBorderColor:[[UIColor whiteColor] CGColor]];
}

#pragma mark - Loader Methods
- (void) stopLoaderForView:(UIView *)view
{
    [MBProgressHUD hideHUDForView:view animated:YES];
}

- (void) startLoaderForView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.minSize = CGSizeMake(135.f, 135.f);
}

- (void) startLoaderWithTitle:(NSString *)title andDescription:(NSString *)description forView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.minSize = CGSizeMake(135.f, 135.f);
    hud.labelText = title;
    hud.detailsLabelText = description;
}

- (void) startLoaderWithTitle:(NSString *)title forView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.minSize = CGSizeMake(135.f, 135.f);
    hud.labelText = title;
}

- (void) displayCheckmarkWithLabelText:(NSString *)text forView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
	hud.labelText = text;
}

- (void) displayCheckmakForView:(UIView *)view
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
	hud.mode = MBProgressHUDModeCustomView;
    UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    hud.customView = imageView;
}

#pragma mark - Send Flash Methods
- (NSMutableArray *) getFlashs
{
    return [NSMutableArray arrayWithArray:[[self getDefaults] objectForKey:@"flashs"]];
}

- (void) saveFlashs:(NSMutableArray *)flashs
{
    [[self getDefaults] setObject:flashs forKey:@"flashs"];
    [self synchronize];
}

- (int) getCurrentFlashIndex
{
    return [[[self getDefaults] objectForKey:@"currentFlashIndex"] integerValue];
}

- (NSUserDefaults *)getDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

- (void) synchronize
{
    [[self getDefaults] synchronize];
}

- (void) resetDisk
{
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
}

#pragma mark - Send Flash Verification Method
- (BOOL) isFlashsEmpty
{
    BOOL isFlashEmpty = YES;
    NSMutableArray *flashs = [self getFlashs];
   
    for(NSMutableDictionary *flash in (NSArray *)flashs){
        if(![[flash objectForKey:@"sms"] isEqualToString:@""] && [flash objectForKey:@"sms"] != nil)
            isFlashEmpty = NO;
        if([flash objectForKey:@"imageData"] != nil)
            isFlashEmpty = NO;
        if([flash objectForKey:@"faceObjectId"] != nil)
            isFlashEmpty = NO;
    }
    
    return isFlashEmpty;
}

- (BOOL) isFlashEmpty:(NSMutableDictionary *)flash
{
    BOOL isFlashEmpty = YES;
    
    NSString *sms = [flash objectForKey:@"sms"];
    NSData *imageData = [flash objectForKey:@"imageData"];
    NSString *faceObjectId = [flash objectForKey:@"faceObjectId"];
    
    if(![sms isEqualToString:@""])
        isFlashEmpty = NO;
    if(imageData != nil)
        isFlashEmpty = NO;
    if(faceObjectId != nil)
        isFlashEmpty = NO;
    
    return isFlashEmpty;
}

- (void) displayFlashs
{
    NSMutableArray *flashs = [self getFlashs];
    
    for(NSMutableDictionary *flash in (NSArray *)flashs){
        NSLog(@"Flash sms: %@", [flash objectForKey:@"sms"]);
        NSLog(@"Flash face: %@", [flash objectForKey:@"faceObjectId"]);
        
        if([flash objectForKey:@"imageData"]){
            NSLog(@"Flash image : OUI");
        }else{
            NSLog(@"Flash image : NON");
        }
        
    }
}

#pragma mark - Push Notification Methods

/* Méthodes métier */
- (void) sendPushForAddingFace{
    
    NSString *title = [NSString stringWithFormat:@"Face de %@", [self getAuthorUsername]];
    NSString *message = [NSString stringWithFormat:@"%@ à ajouter une face sur son profil.", [self getAuthorUsername]];
    
    // On récupère le tableau des amis
    PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
    [oneSens whereKey:@"demandeurObjectId" equalTo:[PFUser currentUser].objectId];
    [oneSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
    [otherSens whereKey:@"receveurObjectId" equalTo:[PFUser currentUser].objectId];
    [otherSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    NSMutableArray *friendsObjectId = [[NSMutableArray alloc] init];
    [friendsObjectId removeAllObjects];
    PFQuery *queryFriendsRelation = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
    [queryFriendsRelation findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if(!error){
            for (PFObject *relation in objects) {
                NSString *demandeurObjectId = relation[@"demandeurObjectId"];
                NSString *receveurObjectId = relation[@"receveurObjectId"];
                
                if([relation[@"demandeurObjectId"] isEqualToString:[PFUser currentUser].objectId]){
                    [friendsObjectId addObject: receveurObjectId];
                }else{
                    [friendsObjectId addObject: demandeurObjectId];
                }
            }

            // On envoie une notification push à chaque amis
            for(NSString *friendObjectId in friendsObjectId){
                [self sendPushNotificationToFriend:friendObjectId withTitle:title andMessage:message];
            }
        }
    }];
}

- (void) sendPushForRelationshipRequest:(NSString *)friendId
{
    NSString *title = [NSString stringWithFormat:@"Demande d'amitié de %@", [self getAuthorUsername]];
    NSString *message = [NSString stringWithFormat:@"%@ vous a envoyé une demande d'amitié.", [self getAuthorUsername]];
    [self sendPushNotificationToFriend:friendId withTitle:title andMessage:message];
}

- (void) sendPushForAcceptRelationship:(NSString *)friendId
{
    NSString *title = [NSString stringWithFormat:@"Acceptation de %@", [self getAuthorUsername]];
    NSString *message = [NSString stringWithFormat:@"%@ a accepté votre demande d'amitié.", [self getAuthorUsername]];
    [self sendPushNotificationToFriend:friendId withTitle:title andMessage:message];
}

- (void) sendPushForMessageToRecipients:(NSMutableArray *)recipientObjectIds
{
    NSString *title = [NSString stringWithFormat:@"Flash de %@", [self getAuthorUsername]];
    NSString *message = [NSString stringWithFormat:@"%@ vous a envoyé un flash.", [self getAuthorUsername]];
    
    for(NSString *friendObjectId in recipientObjectIds){
        [self sendPushNotificationToFriend:friendObjectId withTitle:title andMessage:message];
    }
}

/* Méthodes d'aide */
- (NSString *) getAuthorUsername{
    return [PFUser currentUser].username;
}

- (NSDictionary *) getDataForPushNotificationWithMessage:(NSString *)message andTitle:(NSString *)title
{
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys: message, @"alert", title, @"title", @"Increment", @"badge", @"cheering.caf", @"sound", nil];
    
    return data;
}

- (void) sendPushNotificationToFriend:(NSString *)objectId withTitle:(NSString *)title andMessage:(NSString *)message
{
    NSTimeInterval interval = 60*60*24; // 1 day
    
    //PFQuery *friendQuery = [PFUser query];
    //[friendQuery whereKey:@"objectId" equalTo:objectId];
    PFUser *user = (PFUser *)[[PFUser query] getObjectWithId:objectId];
    
    PFQuery *query = [PFInstallation query];
    //[query whereKey:@"user" matchesQuery:friendQuery];
    [query whereKey:@"user" equalTo:user];

    PFPush *push = [[PFPush alloc] init];
    [push setQuery:query];
    [push expireAfterTimeInterval:interval];
    [push setData:[self getDataForPushNotificationWithMessage:message andTitle:title]];
    [push sendPushInBackground];
    
    NSLog(@"Envoie d'une notification push à l'ami d'identifiant: %@.", objectId);
}

@end
