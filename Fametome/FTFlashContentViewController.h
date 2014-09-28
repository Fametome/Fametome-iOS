//
//  FTFlashContentViewController.h
//  Fametome
//
//  Created by Famille on 13/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTToolBox.h"
#import "MBProgressHUD.h"
#import "FTSendCollectionViewController.h"

@interface FTFlashContentViewController : UIViewController

@property (assign, nonatomic) NSInteger index;
@property (assign, nonatomic) NSInteger messageLength;
@property (assign, nonatomic) NSString *messageObjectId;
@property (strong, nonatomic) PFUser *author;

@property (strong, nonatomic) UIImage *flashImage;
@property (weak, nonatomic) IBOutlet UILabel *flashLabel;

@property (weak, nonatomic) IBOutlet UIImageView *flashImageView;
@property (strong, nonatomic) NSString *textFlashLabel;
@property (weak, nonatomic) IBOutlet UIButton *answerButton;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;

// Avatar auteur
@property (weak, nonatomic) IBOutlet UIImageView *avatarAuthorImageView;


@end
