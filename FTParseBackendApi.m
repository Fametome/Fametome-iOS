//
//  FTParseBackendApi.m
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTParseBackendApi.h"

@implementation FTParseBackendApi

static FTParseBackendApi *sharedGlobalData = nil;

+ (FTParseBackendApi*)sharedGlobalData {
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

#pragma mark - Helper Methods

#pragma mark - SignUp Method
- (void) signUp:(NSString *)email withUsername:(NSString *)username andWithPassword:(NSString *)password fromController:(UIViewController *)currentController andWithEmailField:(UITextField *)emailField and:(UITextField *)usernameField and:(UITextField *)passwordField
{
    UIView *view = currentController.view; // Utile pour alléger les appels au loader.
    
    // Formulaire d'inscription incomplet
    if( [email length] == 0 || [password length] == 0 || [username length] == 0) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Formulaire incomplet !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if(![[FTToolBox sharedGlobalData] isNetworkAvailable]) {
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }else if ([username length] < 3 || [username length] > 20) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Votre pseudonyme doit faire entre 3 et 20 caractères inclus." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if ([password length] < 5 || [password length] > 20){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oups..." message:@"Votre mot de passe doit faire entre 5 et 20 caractères inclus." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        [passwordField resignFirstResponder];
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" andDescription:@"Inscription en cours" forView:view];
        
        // Processus d'inscription : Création d'un objet PFUser.
        PFUser *user = [PFUser  user];
        user.username = username;
        user.password = password;
        user.email = email;

        // Les champs spécifiques à notre application
        user[@"phone"] = [NSNull null];
        user[@"flashSmsSendCount"] = @0;
        user[@"flashPhotoSendCount"] = @0;
        user[@"flashFaceSendCount"] = @0;
        user[@"flashSendCount"] = @0;
        user[@"messageSendCount"] = @0;

        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [[FTToolBox sharedGlobalData] stopLoaderForView:view];
            if(error){
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Sorry!" message: [error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                NSLog(@"Inscription réussie : %@", username);
                [[FTToolBox sharedGlobalData] displayCheckmarkWithLabelText:@"Inscription Réussie !" forView:view];
                
                // Inscription au Push
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"user"] = [PFUser currentUser];
                [currentInstallation saveEventually];
                
                [self performSelector:@selector(redirectToProfil:) withObject:currentController afterDelay:1.5];
                
            }
            
            // Message de bienvenu
            PFObject *message = [PFObject objectWithClassName:@"Message"];
            message[@"recipientsObjectId"] = [NSArray arrayWithObjects:[PFUser currentUser].objectId, nil];
            message[@"authorObjectId"] = @"MiVA0ErOHL";
            message[@"seen"] = @NO;
            message[@"time"] = @0;
            message[@"animation"] = @0;

            PFObject *flash1 = [self instanciateFlashWithSms:@"Bienvenu sur Fametome !" face:nil picture:nil index:0 forMessage:message];
            PFObject *flash2 = [self instanciateFlashWithSms:@"Ceci est un flash. Il peut être composé de sms, de photos et de faces !" face:nil picture:nil index:1 forMessage:message];
            PFObject *flash3 = [self instanciateFlashWithSms:@"Vous allez voir un sms, une photo et une face." face:nil picture:nil index:2 forMessage:message];
            PFObject *flash4 = [self instanciateFlashWithSms:@"Un sms !" face:nil picture:nil index:4 forMessage:message];
            PFObject *flash5 = [self instanciateFlashWithSms:nil face:nil picture:[UIImage imageNamed:@"photo.png"] index:5 forMessage:message];
            PFObject *flash6 = [self instanciateFlashWithSms:nil face:@"gL9I3zyvAX" picture:nil index:6 forMessage:message];
            PFObject *flash7 = [self instanciateFlashWithSms:@"Ajoutez vos amis et envoyer leur des flashs !" face:nil picture:nil index:7 forMessage:message];
            
            [flash1 saveInBackground];
            [flash2 saveInBackground];
            [flash3 saveInBackground];
            [flash4 saveInBackground];
            [flash5 saveInBackground];
            [flash6 saveInBackground];
            [flash7 saveInBackground];
            
        }];
    }
}

// Helper method for signUp
- (PFObject *) instanciateFlashWithSms:(NSString *)sms face:(NSString *)faceObjectId picture:(UIImage *)image index:(int)index forMessage:(PFObject *)message
{
    PFObject *flash = [PFObject objectWithClassName:@"Flash"];
    if(sms)
        flash[@"sms"] = sms;
    else
        flash[@"sms"] = [NSNull null];
    
    if(faceObjectId)
        flash[@"faceObjectId"] = faceObjectId;
    else
        flash[@"faceObjectId"] = [NSNull null];
    
    if(image)
        flash[@"image"] = [PFFile fileWithName:@"picture.png" data:UIImagePNGRepresentation(image)];
    else
        flash[@"image"] = [NSNull null];
    
    flash[@"index"] = [NSNumber numberWithInt:index];
    flash[@"message"] = message;

    return flash;
}

- (void) redirectToProfil:(UIViewController *)currentController
{
    [[FTToolBox sharedGlobalData] redirectToProfil:currentController];
}

#pragma mark - Login Method
- (void) login:(NSString *)username withPassword:(NSString *)password fromController:(UIViewController *)currentController andWithUsernameField:(UITextField *)usernameField and:(UITextField *)passwordField
{
    UIView *view = currentController.view; // Utile pour alléger les appels au loader.
    
    // On lance le traitement
    if( [username length] == 0 || [password length] == 0)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Formulaire incomplet !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if(![[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }else
    {
        [usernameField resignFirstResponder];
        [passwordField resignFirstResponder];
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Chargement" andDescription:@"Connexion en cours" forView:view];
        // User
        PFUser *user = [PFUser  user];
        user.username = username;
        user.password = password;
        
        [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
            [[FTToolBox sharedGlobalData] stopLoaderForView:view];
            if(error) {
                passwordField.text = @"";
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oups !" message: [error.userInfo objectForKey:@"error"] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            }else{
                NSLog(@"Connexion réussie : %@", username);
                
                // Inscription au Push
                PFInstallation *currentInstallation = [PFInstallation currentInstallation];
                currentInstallation[@"user"] = [PFUser currentUser];
                [currentInstallation saveEventually];

                [[FTToolBox sharedGlobalData] redirectToReception:currentController];
                
                // On nettoie la vue
                usernameField.text = @"";
                passwordField.text = @"";
            }
        }];
    }
}

#pragma mark - Profil Methods
- (void) addAvatarInBackground:(UIImage *)avatar andUpdate:(UIImageView *)avatarImageView forUser:(PFUser *)user inController:(UIViewController *)controller{
    
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }else{
        
        UIImage *resizeAvatar = [[FTToolBox sharedGlobalData] resizeImageForAvatar:avatar];
        NSData *imageData = UIImagePNGRepresentation(resizeAvatar);
        NSString *fileName = [user.username stringByAppendingString:@"_avatar.png"];
        PFFile *imageFile = [PFFile fileWithName:fileName data:imageData];
        
        // Appel au serveur
        [[FTToolBox sharedGlobalData] startLoaderForView:controller.view];
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                [[FTToolBox sharedGlobalData] stopLoaderForView:controller.view];
                [[FTToolBox sharedGlobalData] displayCheckmakForView:controller.view];
                // On associe le fichier qui vient d'être upload
                user[@"avatar"] = imageFile;
                [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        avatarImageView.image = resizeAvatar;
                        
                        // On prévient que l'upload a réussie
                        [[FTToolBox sharedGlobalData] stopLoaderForView:controller.view];
                    }else
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                }];
            }else
                NSLog(@"Error %@ %@", error, [error userInfo]);
        }];
    }
}

#pragma mark - Face Methods
- (void) addFaceInBackgroundAndCoreData:(NSString *)sms withImage:(UIImage *)image forUser:(PFUser *)user andController:(UIViewController *)viewController{
    
    // On redimensionne l'image avec la notre boîte à outils.
    UIImage *resizeImage = [[FTToolBox sharedGlobalData] resizeImageForFace:image];
    NSData *imageData = UIImagePNGRepresentation(resizeImage);
    NSString *imageName = [user.username stringByAppendingString:@"_face.png"];
    PFFile *imageFile = [PFFile fileWithName:imageName data:imageData];
    
    // Vérifications
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }else if ([sms length] == 0){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Formulaire incomplet !" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if([sms length] > 25) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Votre Sms doit faire moins de 50 caractères." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else if (image == [UIImage imageNamed:@"photo.png"]) {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Oops..." message:@"Vous n'avez pas ajouté d'image." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else{

        PFObject *face = [PFObject objectWithClassName:@"Face"];
        face[@"sms"] = sms;
        face[@"user"] = user;
        face[@"public"] = @YES;
        
        // On lance le loader
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:viewController.view animated:YES];
        hud.minSize = CGSizeMake(135.f, 135.f);
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        hud.labelText = @"Chargement en cours";
        hud.progress = 0.0f;
        
        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if(!error){
                // On associe le fichier qui vient d'être upload
                face[@"image"] = imageFile;
                [face saveInBackground];
                
                // On prévient que l'upload a réussie
                hud.mode = MBProgressHUDModeCustomView;
                UIImage *image = [UIImage imageNamed:@"37x-Checkmark.png"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                hud.customView = imageView;
                hud.labelText = @"Face ajouté";
                
                // Push Notification
                [[FTToolBox sharedGlobalData] sendPushForAddingFace];

                // Redirection
                [self performSelector:@selector(redirectToProfil:) withObject:viewController afterDelay:1];
                
            }else{
                [MBProgressHUD hideHUDForView:viewController.view animated:YES];
                NSLog(@"Error %@ %@", error, [error userInfo]);
            }
        } progressBlock:^(int percentDone) {
            hud.progress = percentDone/100.0f;
        }];
        
    }
}

#pragma mark - Friends Methods
- (PFObject *) instantiateDemandFrom:(PFUser *)demandeur to:(PFUser *)receveur
{
    PFObject *demande = [PFObject objectWithClassName:@"Demande"];
    demande[@"demandeurObjectId"] = demandeur.objectId;
    demande[@"demandeurUsername"] = demandeur.username;
    demande[@"receveur"] = receveur;
    
    return demande;
}
/*
- (NSMutableArray *) getAllDemandesFor:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Demande"];
    [query whereKey:@"receveur" equalTo:user];
    NSArray *userDemandes = [query findObjects];
    
    return [NSMutableArray arrayWithArray:userDemandes];
}
*/

- (NSMutableArray *) getAllDemandesFor:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Relation"];
    [query whereKey:@"receveurObjectId" equalTo:user.objectId];
    [query whereKey:@"statut" equalTo:@0];
    NSArray *results = [[NSArray alloc] init];
    
    if([[FTToolBox sharedGlobalData] isNetworkAvailable])
        results = [query findObjects];
    
    NSMutableArray *demandes = (NSMutableArray *)results;
    return demandes;
}

- (NSMutableArray *) getAllObjectIdFriendsFor:(PFUser *)user
{
    NSMutableArray *friends = [[NSMutableArray alloc] init];
    NSArray *relations = [[NSArray alloc] init];
    
    PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
    [oneSens whereKey:@"demandeurObjectId" equalTo:user.objectId];
    [oneSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
    [otherSens whereKey:@"receveurObjectId" equalTo:user.objectId];
    [otherSens whereKey:@"statut" greaterThanOrEqualTo:@1];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
    
    if([[FTToolBox sharedGlobalData] isNetworkAvailable])
        relations = [query findObjects];
    
    for (PFObject *relation in relations) {
        NSLog(@"something");
        if(relation[@"demandeurObjectId"] != user.objectId){
            [friends addObject:relation[@"receveurObjectId"]];
        }else{
            [friends addObject:relation[@"demandeurObjectId"]];
        }
    }
    
    // Contient tous les identifiants des amis de *user
    return friends;
}

- (void) sendRequestFrom:(PFUser *)demandeur toBeFriendWith:(PFUser *)receveur
{
    PFObject *relation = [PFObject objectWithClassName:@"Relation"];
    relation[@"demandeurObjectId"] = demandeur.objectId;
    relation[@"receveurObjectId"] = receveur.objectId;
    relation[@"statut"] = @0;

    [relation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
       
        if(!error){
            NSLog(@"Relation crée entre %@ et %@", demandeur.username, receveur.username);
            
            // Push notification
            [[FTToolBox sharedGlobalData] sendPushForRelationshipRequest:receveur.objectId];
            
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
        }
    }];
}

/* Accepter une demande
 * 1. Mettre à 1 le statut de la relation dans le backend
 * 2. Ajouter le demandeur dans le cache du receveur
 * 3. Push notification
 */
- (void) acceptRelation:(PFObject *)relation
{
    // On augmente la relation de +1 pour qu'elle ne soit plus considéré comme une demande
    [relation incrementKey:@"statut"];
    
    // On sauvegarde tout ça en backend
    [relation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(!error){
            // Push notification
            [[FTToolBox sharedGlobalData] sendPushForAcceptRelationship:relation[@"demandeurObjectId"]];
        }
    }];
}

- (void) refusedRelation:(PFObject *)relation
{
    [relation deleteInBackground];
}

#pragma mark - Message Methods
- (PFObject *) instantiateEmptyMessageFrom:(NSString *)auteurObjectId to:(NSString *)receveurObjectId
{
    PFObject *message = [PFObject objectWithClassName:@"Message"];
    message[@"auteurObjectId"] = auteurObjectId;
    message[@"receveurObjectId"] = receveurObjectId;
    message[@"seen"] = @NO;
    message[@"story"] = @NO;
    message[@"temps"] = @500;
    message[@"animation"] = @1;

    return message;
}

- (PFObject *) instantiateEmptyFlashForMessage:(PFObject *)message
{
    PFObject *flash = [PFObject objectWithClassName:@"Flash"];
    flash[@"sms"] = [NSNull null];
    flash[@"image"] = [NSNull null];
    //flash[@"faceObjectId"] = [NSNull null];

    flash[@"message"] = message;
    return flash;
}

- (NSMutableArray *) getAllMessagesWithoutFlashForUser:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Message"];
    [query whereKey:@"receveurObjectId" equalTo:user.objectId];
    NSArray *results = [query findObjects];
    NSMutableArray *messages = [NSMutableArray arrayWithArray:results];
    return messages;
}

#pragma mark - Initialisation Methods
- (void) displayProfilAlertForController:(UIViewController *)controller
{
    NSString *title = @"Bienvenu sur Fametome";
    NSString *message = @"Cette partie vous permet d'ajouter et de consulter vos faces. Les faces vous permettent de créer des smileys personnalisés avec votre visage. Vous pouvez également changer votre avatar en cliquant dessus.";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displayAddFaceAlertForController:(UIViewController *)controller
{
    NSString *title = @"Ajouter une Face";
    NSString *message = @"Cette partie vous permet d'ajouter une face, c'est à dire un smiley personnalisé avec votre visage. Par exemple prenez une photo de vous souriant et associez lui le texte :).";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displayReceptionAlertForController:(UIViewController *)controller
{
    NSString *title = @"Boîte de réception";
    NSString *message = @"C'est ici que vous pouvez consulter vos flashs. Les Flashs sont les messages dans l'application Fametome. Pour voir un flash, cliquer sur le bouton 'voir le flash', il sera ensuite définitevement supprimé.";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displaySendAlertForController:(UIViewController *)controller
{
    NSString *title = @"Envoie de flash";
    NSString *message = @"Vous pouvez composez vos flashs ici. Pour chaque éléement, écrivez un simple SMS ou ajouter une de vos faces en cliquant sur l'image à droite de cet élement. Vous pouvez envoyer jusqu'à 7 élements, à la fois. Cliquer ensuite sur le + en haut à droite pour ajouter des destinataires.";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displayFriendAlertForController:(UIViewController *)controller
{
    NSString *title = @"Mes amis";
    NSString *message = @"Consulter le profil de vos amis en cliquant sur leur avatar. Pour chercher de nouveaux amis, cliquer sur l'icône de loupe en haut à droite. Pour consulter vos demandes d' amitié, cliquer sur l'icône à gauche de la loupe.";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displaySearchFriendAlertForController:(UIViewController *)controller
{
    NSString *title = @"Chercher des amis";
    NSString *message = @"Chercher vos amis en saisissant leur pseudonyme puis en cliquant sur 'Lancer la recherche'.";
    [self displayAlertHelperWithTitle:title andMessage:message andController:controller];
}

- (void) displayAlertHelperWithTitle:(NSString *)title andMessage:(NSString *)message andController:(UIViewController *)controller{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:controller cancelButtonTitle:@"OK, j'ai compris !" otherButtonTitles:nil, nil];
    [alertView show];
}








@end
