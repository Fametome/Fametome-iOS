//
//  FTSendCollectionViewController.m
//  Fametome
//
//  Created by Famille on 31/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTSendCollectionViewController.h"

@interface FTSendCollectionViewController ()

@end

@implementation FTSendCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Configuration de la navbar
    if(_destinataire){
        self.title = [NSString stringWithFormat:@"à %@", [_destinataire.username capitalizedString]];
        //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
        
        
        UIBarButtonItem *firstButton = [[UIBarButtonItem alloc] initWithTitle:@"Envoyer" style:UIBarButtonItemStylePlain target:self action:@selector(sendMessage)];
        UIBarButtonItem *secondButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:firstButton];
        [array addObject:secondButton];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithArray:array];
        
        
    }else{
        self.title = @"Envoie";
        
        
        UIBarButtonItem *firstButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(chooseRecipients)];
        UIBarButtonItem *secondButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [array addObject:firstButton];
        [array addObject:secondButton];
        self.navigationItem.rightBarButtonItems = [NSArray arrayWithArray:array];
    }

    // Message vide initialisation
    _isRefresh = YES;
    [self initializeActivity];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Les modifications apporté depuis FTChooseFaceController ou retour depuis FTChooseRecipientsController
    //[[FTToolBox sharedGlobalData] displayFlashs];
    _flashs = [[FTToolBox sharedGlobalData] getFlashs];
    [self.collectionView reloadData];
}

- (void) initializeActivity
{
    
    _flashs = [[NSMutableArray alloc] init];
    
    NSMutableDictionary *firstFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
    NSMutableDictionary *secondFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
    NSMutableDictionary *thirdFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
    
    [_flashs addObject:firstFlash];
    [_flashs addObject:secondFlash];
    [_flashs addObject:thirdFlash];
    
    [[FTToolBox sharedGlobalData] saveFlashs:_flashs];
    [self reloadData];
}

#pragma mark - UITextFieldDelegate
- (void) textFieldDidBeginEditing:(UITextField *)textField {}

- (void) textFieldDidEndEditing:(UITextField *)textField {}

#pragma mark - Destinataires Redirection
- (void) chooseRecipients
{
    if([[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [self synchronizeFlash];
        [self performSegueWithIdentifier:@"chooseRecipientsSegue" sender:self];
    }else{
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }
}

- (void) refresh
{
    NSString *message = @"Êtes-vous sûr de vouloir recommencer ce message ?";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Recommencer" message:message delegate:self cancelButtonTitle:@"Non" otherButtonTitles:@"Confirmer", nil];
    [alertView show];
}

#pragma mark - Alert Methods
- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self initializeActivity];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _flashs.count;
}

- (UICollectionViewCell *) collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FTSendCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"sendCell" forIndexPath:indexPath];
    [cell setExclusiveTouch:YES];
    
    // Configuration par défaut
    [[FTToolBox sharedGlobalData] designSendTextField:cell.flashTextField];
    cell.flashTextField.delegate = self;
    cell.flashTextField.text = @"";
    [cell.flashImageButton setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    
    // Chargement
    if(!_isRefresh){
        NSString *sms = _flashs[indexPath.row][@"sms"];
        NSData *imageData = _flashs[indexPath.row][@"imageData"];
        NSString *faceObjectId = _flashs[indexPath.row][@"faceObjectId"];
        
        if(sms != nil)
            cell.flashTextField.text = sms;
        
        if(faceObjectId != nil){
            cell.flashTextField.enabled = NO;
            cell.flashTextField.textColor = [UIColor lightGrayColor];
            [cell.flashImageButton setBackgroundImage:[UIImage imageWithData:imageData] forState:UIControlStateNormal];
        }
        
        else if(imageData != nil){
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *rotateImage = image;// [[FTToolBox sharedGlobalData] rotateImage:image withDegrees:90];
            [cell.flashImageButton setBackgroundImage:rotateImage forState:UIControlStateNormal];
            cell.flashTextField.enabled = NO;
            cell.flashTextField.textColor = [UIColor lightGrayColor];
            
        }
    }

    // Configuration des évenements sur les UITextFields
    [cell.flashImageButton addTarget:self action:@selector(takePicture:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}


/* Cliquer sur un ajout de face ou de photo */
-(void)takePicture:(UIButton *) sender {
    id superView = sender.superview;
    while (superView && ![superView isKindOfClass:[UICollectionViewCell class]]) {
        superView = [superView superview];
    }
    NSIndexPath *selectedPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)superView];
    
    NSLog(@"Clic sur le indexPath: %d", selectedPath.row);

    // On sauvegarde les flashs déjà construit sur le disque
    [self synchronizeFlash];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:selectedPath.row forKey:@"currentFlashIndex"];
    [defaults synchronize];

    [self performSegueWithIdentifier:@"chooseFaceSegue" sender:self];
}

// Footer Implementation
- (UICollectionReusableView *) collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    FTSendFooterReusableView *footer = nil;
    
    if([kind isEqual:UICollectionElementKindSectionFooter])
    {
        footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"sendFooter" forIndexPath:indexPath];
        
        // Configuration du bouton dynamiquement
        //[footer.sendFooterButton setTitle:@"Ajouter un flash" forState:UIControlStateNormal];
        [[FTToolBox sharedGlobalData] makeCornerRadius:footer.sendFooterButton];
    }
    
    return footer;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(25.0, 0, 40.0, 0);
}

#pragma mark - Image Picker Controller delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *resizeImage = [[FTToolBox sharedGlobalData] resizeImageForFace:image];
    
    FTSendCollectionViewCell *cell = (FTSendCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:_selectedIndexPath];
    [cell.flashImageButton setBackgroundImage:resizeImage forState:UIControlStateNormal];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - IBAction
- (IBAction)addFlash:(id)sender {
    NSLog(@"Ajouter un flash");
    
    NSMutableArray *flashs = [[FTToolBox sharedGlobalData] getFlashs];
    
    if(flashs.count >= 7){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Désolé..." message:@"Vous ne pouvez envoyer que 7 flashs par message !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }else{
        
        [_flashs removeAllObjects];
        
        NSUInteger index = 0;
        for(NSMutableDictionary *flashCurrent in flashs) {
            
            NSMutableDictionary *flash = [NSMutableDictionary dictionaryWithDictionary:flashCurrent];
            //int index = [flashs indexOfObject:flash];
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
            FTSendCollectionViewCell *cell = (FTSendCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            
            // Todo nettoyer le code !
            if(cell.flashTextField.text != nil){
                NSString *sms = cell.flashTextField.text;
                [flash setObject:sms forKey:@"sms"];
            }
            
            if(cell.flashImageButton.currentBackgroundImage != [UIImage imageNamed:@"photo.png"]){
                NSData *imageData = UIImagePNGRepresentation(cell.flashImageButton.currentBackgroundImage);
                //NSData *imageData = nil;
                [flash setObject:imageData forKey:@"imageData"];
            }

            [_flashs addObject:flash];
            index++;
        }
        
        NSMutableDictionary *newEmptyFlash = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, @"sms", nil, @"image", nil, @"faceObjectId", nil];
        [_flashs addObject:newEmptyFlash];
        [[FTToolBox sharedGlobalData] saveFlashs:_flashs];
        
        [self.collectionView reloadData];
    }
}

#pragma mark - SlideNavigationController Methods -
- (BOOL)slideNavigationControllerShouldDisplayLeftMenu
{
	return YES;
}

- (BOOL)slideNavigationControllerShouldDisplayRightMenu
{
	return NO;
}

#pragma mark - Hide Keyboard
- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - Helper Methods
- (void) synchronizeFlash
{
    NSMutableArray *flashs = [[FTToolBox sharedGlobalData] getFlashs];
    [_flashs removeAllObjects];
    
    NSUInteger index = 0;
    for(NSMutableDictionary *flashCurrent in flashs) {
        
        NSMutableDictionary *flash = [NSMutableDictionary dictionaryWithDictionary:flashCurrent];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        FTSendCollectionViewCell *cell = (FTSendCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        
        if(cell.flashTextField.text != nil){
            NSString *sms = cell.flashTextField.text;
            [flash setObject:sms forKey:@"sms"];
        }
        
        if(cell.flashImageButton.currentBackgroundImage != [UIImage imageNamed:@"photo.png"]){
            NSData *imageData = UIImagePNGRepresentation(cell.flashImageButton.currentBackgroundImage);
            [flash setObject:imageData forKey:@"imageData"];
        }
        
        [_flashs addObject:flash];
        index++;
    }

    [[FTToolBox sharedGlobalData] saveFlashs:_flashs];
}

- (void) reloadData
{
    [self.collectionView reloadData];
    _isRefresh = NO;
}

#pragma mark - Send Message
- (void) sendMessage {
    NSLog(@"Envoie d'un flash à : ");
    
    /* Initialisation */
    [self synchronizeFlash];
    PFUser *author = [PFUser currentUser];
    NSString *authorObjectId = author.objectId;
    NSMutableArray *flashs = [[FTToolBox sharedGlobalData] getFlashs];
    NSArray *recipient = [[NSArray alloc] initWithObjects:_destinataire.objectId, nil];
    [[FTToolBox sharedGlobalData] displayFlashs];
    /* Vérification d'usage */
    
    if(![[FTToolBox sharedGlobalData] isNetworkAvailable]){
        [[FTToolBox sharedGlobalData] networkUnavailableAlert];
    }
    else if([[FTToolBox sharedGlobalData] isFlashsEmpty]){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Petit problème..." message:@"Vous n'allez quand même pas envoyer un message vide à vos amis Appuyer sur retour et écrivez un message sympas !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else if(!_destinataire){
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Petit problème..." message:@"Vous n'avez pas sélectionnez de destinataire !" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else {
        [[FTToolBox sharedGlobalData] startLoaderWithTitle:@"Envoie en cours" forView:self.view];
        
        // 1. Message
        NSLog(@"Création du message");
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"authorObjectId"] = authorObjectId;
        [message addUniqueObjectsFromArray:recipient forKey:@"recipientsObjectId"];
        message[@"animation"] = @0;
        message[@"seen"] = @NO;
        message[@"time"] = @0;
        
        // 2. Flashs
        NSLog(@"Création des flashs");
        int index = 0;
        for(NSMutableDictionary *currentFlash in (NSArray *)flashs){
            PFObject *flash = [PFObject objectWithClassName:@"Flash"];
            flash[@"message"] = message;
            flash[@"index"] = [NSNumber numberWithInt:index];
            
            NSString *sms = [currentFlash objectForKey:@"sms"];
            NSData *imageData = [currentFlash objectForKey:@"imageData"];
            NSString *faceObjectId = [currentFlash objectForKey:@"faceObjectId"];
            
            if(![[FTToolBox sharedGlobalData] isFlashEmpty:currentFlash]){
                if(faceObjectId != nil){
                    NSLog(@"Flahs %d is Face.", index);
                    flash[@"faceObjectId"] = faceObjectId;
                    flash[@"sms"] = [NSNull null];
                    flash[@"image"] = [NSNull null];
                    [flash saveInBackground];
                    // Stats
                    [[PFUser currentUser] incrementKey:@"flashFaceSendCount"];
                    
                }else{
                    if(![sms isEqualToString:@""]){
                        NSLog(@"Flahs %d is Sms.", index);
                        flash[@"sms"] = sms;
                        flash[@"image"] = [NSNull null];
                        flash[@"faceObjectId"] = [NSNull null];
                        [flash saveInBackground];
                        // Stats
                        [[PFUser currentUser] incrementKey:@"flashSmsSendCount"];
                    }
                    else if(imageData){
                        NSLog(@"Flahs %d is Picture.", index);
                        PFFile *imageFile = [PFFile fileWithName:@"picture.png" data:imageData];
                        
                        [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                            if(!error){
                                NSLog(@"Upload de l'image successfull !");
                                flash[@"sms"] = [NSNull null];
                                flash[@"image"] = imageFile;
                                flash[@"faceObjectId"] = [NSNull null];
                                [flash saveInBackground];
                                // Stats
                                [[PFUser currentUser] incrementKey:@"flashPhotoSendCount"];
                            }
                        }];
                    }
                }
                // Stats
                [[PFUser currentUser] incrementKey:@"flashSendCount"];

            }else
                NSLog(@"Flash vide");

            index++;
        }

        // Stats
        [[PFUser currentUser] incrementKey:@"messageSendCount"];
        [[PFUser currentUser] saveInBackground];
        
        // Push notification
        [[FTToolBox sharedGlobalData] sendPushForMessageToRecipients:message[@"recipientsObjectId"]];

        // 3. Fin de l'envoie
        [self performSelector:@selector(displaySuccess) withObject:nil afterDelay:1];
    }
}

- (void) displaySuccess
{
    [[FTToolBox sharedGlobalData] stopLoaderForView:self.view];
    [[FTToolBox sharedGlobalData] displayCheckmarkWithLabelText:@"Envoie réussie" forView:self.view];
    [self performSelector:@selector(redirectToReception) withObject:nil afterDelay:1];
    [[FTToolBox sharedGlobalData] resetDisk];
}

- (void) redirectToReception
{
    [[FTToolBox sharedGlobalData] redirectToReception:self];
}

@end
