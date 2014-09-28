//
//  FTFlashContentViewController.m
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTFlashContentViewController.h"

@interface FTFlashContentViewController ()

@end

@implementation FTFlashContentViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    //NSLog(@"Index : %ld", (long)self.index);
    // Configuration

    self.answerButton.hidden = YES;
    self.pageControl.hidden = YES;
    
    if(!(_index == (_messageLength - 1))){
        
    }else{
        [[FTToolBox sharedGlobalData] makeCornerRadius:_answerButton];
        [[FTToolBox sharedGlobalData] makeCornerRadius:_avatarAuthorImageView];
        self.answerButton.hidden = NO;
        self.navigationController.navigationBar.hidden = NO;
        
        if(!_avatarAuthorImageView.image)
            _avatarAuthorImageView.image = [UIImage imageNamed:@"avatar.jpg"];
        // Back button configuration
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Retour" style:UIBarButtonItemStylePlain target:self action:@selector(back)];
        
        // Réactiver le menu
        SlideNavigationController *so = [SlideNavigationController sharedInstance];
        so.enableSwipeGesture = YES;
    }
    
    self.flashImageView.image = self.flashImage;
    self.flashLabel.text = self.textFlashLabel;
    
    // Evenement sur le bouton "Répondre"
    [self.answerButton addTarget:self action:@selector(answerMessage) forControlEvents:UIControlEventTouchUpInside];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // Modification du UIPageControl
    //self.pageControl.currentPage = self.index;
    
    // Désactivation des gestures pour le UIPageViewController
    /*if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }*/
}

- (void) back
{
    [[FTToolBox sharedGlobalData] redirectToReception:self];
}

- (void)answerMessage
{
    NSLog(@"Redirection & redirection du menu!");
    SlideNavigationController *slideNavigationController = [SlideNavigationController sharedInstance];
    slideNavigationController.enableSwipeGesture = YES;
    
    [self performSegueWithIdentifier:@"answerSegue" sender:self];
}

#pragma mark - Perform Segue Method
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"answerSegue"])
    {
        FTSendCollectionViewController *nextController = segue.destinationViewController;
        NSLog(@"Auteur : %@", _author.username);
        [nextController setDestinataire:_author];
    }
    
}
@end
