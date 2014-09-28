//
//  FTDemandeViewCell.h
//  Fametome
//
//  Created by Famille on 12/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FTDemandeViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *avatarDemandeurImageView;
@property (weak, nonatomic) IBOutlet UILabel *demandLabel;
@property (weak, nonatomic) IBOutlet UIButton *demandAcceptButton;
@property (weak, nonatomic) IBOutlet UIButton *demandRefusedButton;

@end