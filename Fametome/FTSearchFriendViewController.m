//
//  FTSearchFriendViewController.m
//  Fametome
//
//  Created by Famille on 11/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTSearchFriendViewController.h"

@interface FTSearchFriendViewController ()

@end

@implementation FTSearchFriendViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialisation
    self.title = @"Recherche";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back:)];
    [self.searchFriendTextField becomeFirstResponder]; // Give focus on this UITextField

    // Design
    [[FTToolBox sharedGlobalData] designExternTextField:self.searchFriendTextField];
    [[FTToolBox sharedGlobalData] designExternButton:self.searchFriendButton];
}

- (IBAction) back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self disableSlidePanGestureForLeftMenu];
}

- (IBAction)searchFriendSubmit:(id)sender {
    
    NSString *username = [self.searchFriendTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Internet est requis pour rechercher des amis
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable])
    {
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }else if ([username isEqualToString:[PFUser currentUser].username]){
        [[FTToolBox sharedGlobalData] showAlertWithTitle:@"Désolé !" andDescription:@"Vous ne pouvez pas être votre propre amis." forController:self];
        
    }else{
        // Start loader
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Recherche en cours..." forView:self.view];
        
        // 1. Cette personne existe-t-elle ?
        PFQuery *query = [PFUser query];
        [query whereKey:@"username" equalTo:username];
        
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error) {
            if(error){
                // L'utilisateur n'existe pas
                NSLog(@"Error %@ %@", error, [error userInfo]);
                [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
                [[FTToolBox sharedGlobalData] clearTextField:self.searchFriendTextField];
                [[FTToolBox sharedGlobalData] showAlertWithTitle:@"Désolé !" andDescription:@"Cet utilisateur n'existe pas." forController:self];
            }else{
                PFUser *user = (PFUser *)object; // On récupère l'utilisateur recherché.
                PFUser *currentUser = [PFUser currentUser];
                
                PFQuery *oneSens = [PFQuery queryWithClassName:@"Relation"];
                [oneSens whereKey:@"demandeurObjectId" equalTo:user.objectId];
                [oneSens whereKey:@"receveurObjectId" equalTo:currentUser.objectId];
                
                PFQuery *otherSens = [PFQuery queryWithClassName:@"Relation"];
                [otherSens whereKey:@"demandeurObjectId" equalTo:currentUser.objectId];
                [otherSens whereKey:@"receveurObjectId" equalTo:user.objectId];
                
                PFQuery *query = [PFQuery orQueryWithSubqueries:@[oneSens,otherSens]];
                [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error) {
                    [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
                    if(!error){
                        
                        if(results.count == 0){
                            [[FTParseBackendApi sharedGlobalData] sendRequestFrom:[PFUser currentUser] toBeFriendWith:user];
                            [[FTToolBox sharedGlobalData] displayCheckmarkWithLabelText:@"Demande envoyé" forView:self.view];
                            [self performSelector:@selector(back:) withObject:nil afterDelay:1];
                        }else{
                            // Une demande est déjà en cours
                            [[FTToolBox sharedGlobalData] showAlertWithTitle:@"Désolé !" andDescription:@"Vous êtes déjà amis avec cette personne ou une demande est en cours." forController:self];
                        }
                        
                    }else{
                        NSLog(@"Error %@ %@", error, [error userInfo]);
                    }
                }];
            }
        }];
    
    }
    
    
    
}

@end
