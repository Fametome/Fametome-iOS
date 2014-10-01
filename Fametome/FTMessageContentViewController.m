//
//  FTMessageContentViewController.m
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTMessageContentViewController.h"

@interface FTMessageContentViewController ()

@end

@implementation FTMessageContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _flashs = [[NSMutableArray alloc] init];
    [_flashs removeAllObjects];
    
    // On cache la barre de navigation pour être FullScreen
    self.navigationController.navigationBar.hidden = YES;

    // Download all flashes
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Chargement";
    hud.detailsLabelText = @"Téléchargement du message";

    PFQuery *query = [PFQuery queryWithClassName:@"Flash"];
    [query whereKey:@"message" equalTo:[PFObject objectWithoutDataWithClassName:@"Message" objectId:_messageObjectId]];
    [query orderByAscending:@"index"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        _flashsToDelete = (NSMutableArray *)objects;
        
        if(!error){
            /* BOUCLE FOR */
            for(PFObject *currentFlash in objects){
                
                NSString *sms = currentFlash[@"sms"];
                PFFile *imageFile = currentFlash[@"image"];
                NSString *faceObjectId = currentFlash[@"faceObjectId"];
                
                // Flash FACE
                if(![faceObjectId isEqual:[NSNull null]]){
                    // Appel synchrone
                    PFQuery *queryFace = [PFQuery queryWithClassName:@"Face"];
                    PFObject *face = [queryFace getObjectWithId:faceObjectId];
                    NSString *sms = face[@"sms"];
                    PFFile *imageFile = face[@"image"];
                    NSData *imageData = [imageFile getData];
                    NSMutableDictionary *flash;
                    if(imageData != nil)
                        flash = [NSMutableDictionary dictionaryWithObjectsAndKeys:sms, @"sms", imageData, @"imageData", faceObjectId, @"faceObjectId", nil];
                    else // Face supprimé
                        flash = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Face supprimé :(", @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
                    [_flashs addObject:flash];
                }
                // Flash IMAGE
                else if(imageFile && ![imageFile isEqual:[NSNull null]]){
                    
                    // Appel synchrone
                    NSData *imageData = [imageFile getData];
                    NSMutableDictionary *flash;
                    if(imageData && ![imageData isEqual:[NSNull null]]){
                        NSLog(@"AJOUT DE L'IMAGE !");
                        flash = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"sms", imageData, @"imageData", @"fakeId", @"faceObjectId", nil];
                    }else{
                        flash = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"Impossible de télécharger l'image :(", @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
                    }
                    [_flashs addObject:flash];
                }
                // Flash SMS
                else if(![sms isEqual:[NSNull null]]){
                    NSMutableDictionary *flash = [NSMutableDictionary dictionaryWithObjectsAndKeys:sms, @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
                    [_flashs addObject:flash];
                }
            }

            NSMutableDictionary *justForLastScreen = [NSMutableDictionary dictionaryWithObjectsAndKeys:nil, @"sms", nil, @"imageData", nil, @"faceObjectId", nil];
            [_flashs addObject:justForLastScreen];

            NSLog(@"Longeur du message : %d", _flashs.count - 1);

            // Initialisation UIPageViewContoller
            _pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
            _pageController.dataSource = self;
            [[_pageController view] setFrame:[[self view] bounds]];
            FTFlashContentViewController *initialViewController = [self viewControllerAtIndex:0];
            NSArray *viewControllers = [NSArray arrayWithObjects:initialViewController, nil];
            [_pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
            [self addChildViewController:_pageController];
            [[self view] addSubview:[_pageController view]];
            [_pageController didMoveToParentViewController:self];
            
            // Lock gesture UIPageViewController
            for (UIScrollView *view in self.pageController.view.subviews) {
                if ([view isKindOfClass:[UIScrollView class]]) {
                    view.scrollEnabled = NO;
                }
            }
            
            // Enable automatic scrolling
            int time = 2; // Configure time of message here.
            for(int i = 0; i < _flashs.count; i++){
                int delay = time + i*time;
                [self performSelector:@selector(goToNextPage) withObject:@"sleep 5 worked" afterDelay:delay];
            }
            
            // Lock gesture for menu
            SlideNavigationController *so = [SlideNavigationController sharedInstance];
            so.enableSwipeGesture = NO;
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }else{
            NSLog(@"Error %@ %@", error, [error userInfo]);
            [[FTToolBox sharedGlobalData] redirectToReception:self];
        }
    }];
    
    // Récupération de l'auteur
    PFQuery *queryMessage = [PFQuery queryWithClassName:@"Message"];
    [queryMessage getObjectInBackgroundWithId:_messageObjectId block:^(PFObject *object, NSError *error) {
        if(!error){
            PFObject *message = object;
            NSString *authorObjectId = message[@"authorObjectId"];
            
            // On récupère l'auteur
            PFQuery *queryAuteur = [PFUser query];
            [queryAuteur getObjectInBackgroundWithId:authorObjectId block:^(PFObject *object, NSError *error) {
                if(!error){
                    _author = (PFUser *)object;
                }
            }];
            
            // Suppression du message
            NSArray *recipients = message[@"recipientsObjectId"];
            if(recipients.count > 1){
                [message removeObjectsInArray:@[[PFUser currentUser].objectId] forKey:@"recipientsObjectId"];
                [message saveInBackground];
            }else{
                // Suppression du message
                [message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if(!error){
                        // Suppression des flashs
                        for(PFObject *currentFlash in _flashsToDelete){
                            [currentFlash deleteInBackground];
                        }
                    }
                }];
                
            }
        }
    }];
    
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void) goToNextPage
{
    [self changePage:UIPageViewControllerNavigationDirectionForward];
}

- (void)changePage:(UIPageViewControllerNavigationDirection)direction {
    NSUInteger pageIndex = ((FTFlashContentViewController *) [self.pageController.viewControllers objectAtIndex:0]).index;
    
    if (direction == UIPageViewControllerNavigationDirectionForward) {
        pageIndex++;
    }
    else {
        pageIndex--;
    }
    
    FTFlashContentViewController *viewController = [self viewControllerAtIndex:pageIndex];
    
    if (viewController == nil) {
        return;
    }
    
    [_pageController setViewControllers:@[viewController] direction:direction animated:YES completion:nil];
}

#pragma mark - protocol of UIPageViewController
- (FTFlashContentViewController *)viewControllerAtIndex:(NSUInteger)index
{
    // On bloque de chaque côté
    if (index >= _flashs.count)
        return nil;
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:[NSBundle mainBundle]];
    FTFlashContentViewController *dataViewController = [storyboard instantiateViewControllerWithIdentifier:@"flashContentView"];

    dataViewController.answerButton.hidden = YES; // On cache le bouton pour pouvoir répondre
    dataViewController.avatarAuthorImageView.hidden = YES; // On cache l'avatar de l'auteur
    
    NSString *sms = [_flashs[index] objectForKey:@"sms"];
    NSData *imageData = [_flashs[index] objectForKey:@"imageData"];
    NSString *faceObjectId = [_flashs[index] objectForKey:@"faceObjectId"];
     
    if(!(index == (_flashs.count - 1))){
        
        if(faceObjectId) {
            dataViewController.textFlashLabel = sms;
            dataViewController.flashImage = [UIImage imageWithData:imageData];
            //NSLog(@"FACE !");
        }else{
            if(sms) {
                dataViewController.textFlashLabel = sms;
                dataViewController.flashImage = nil;
                //NSLog(@"SMS !");
            }
            else if(imageData) {
                dataViewController.textFlashLabel = nil;
                dataViewController.flashImage = [UIImage imageWithData:imageData];
                //NSLog(@"PHOTO !");
            }
        }
        
    }else{
        // Avatar auteur
        PFFile *avatarFile = _author[@"avatar"];
        if(avatarFile){
            [avatarFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                if(!error && ![data isEqual:[NSNull null]])
                    dataViewController.avatarAuthorImageView.image = [UIImage imageWithData:data];
            }];
        }
        // Screen de réponse
        dataViewController.flashImage = nil;
        dataViewController.textFlashLabel = [NSString stringWithFormat:@"Voulez-vous répondre à %@ ?", [_author.username capitalizedString]];
        dataViewController.answerButton.hidden = NO;
        dataViewController.avatarAuthorImageView.hidden = NO;
        dataViewController.pageControl.hidden = YES;
    }
    
    dataViewController.index = index;
    dataViewController.messageLength = _flashs.count;
    
    if(_author != nil)
        dataViewController.author = _author;
    
    return dataViewController;
}

/*
- (NSUInteger)indexOfViewController:(FTFlashContentViewController *)viewController
{
    return [_pageContent indexOfObject:viewController.flashImage];
}
*/

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.flashs count];
}

#pragma mark - data source protocol UIPageViewController
- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = [(FTFlashContentViewController *)viewController index];
    
    if(index == NSNotFound){
        return nil;
    }
    
    if(index == 0){
        return nil;
    }
    
    index--;
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = [(FTFlashContentViewController *)viewController index];

    if (index >= _flashs.count){
        return nil;
    }
    
    index++;
    return [self viewControllerAtIndex:index];
}

#pragma mark - prepareForSegue Methods
- (void) setMessage:(NSString *)messageObjectId
{
    self.messageObjectId = messageObjectId;
}

@end
