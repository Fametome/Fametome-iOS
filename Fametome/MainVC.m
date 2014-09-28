//
//  MainVC.m
//  Fametome
//
//  Created by Famille on 16/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (NSString *) segueIdentifierForIndexPathInLeftMenu:(NSIndexPath *)indexPath
{
    NSString *identifier;
    
    switch (indexPath.row) {
        case 0:
            identifier = @"profilSegue";
            break;
        case 1:
            identifier = @"receptionSegue";
            break;
        case 2:
            identifier = @"sendSegue";
            break;
        case 3:
            identifier = @"friendsSegue";
            break;
        case 4:
            identifier = @"logoutSegue";
            break;
        default:
            break;
    }
    
    return identifier;
}

- (NSString *) segueIdentifierForIndexPathInRightMenu:(NSIndexPath *)indexPath
{
    NSString *identifier;
    
    switch (indexPath.row) {
        case 0:
            identifier = @"proposSegue";
            break;
        case 1:
            identifier = @"cguSegue";
            break;
            
        default:
            break;
    }
    
    return identifier;
}


- (void)configureLeftMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"icon-menu"] forState:UIControlStateNormal];
}

-(void)configureRightMenuButton:(UIButton *)button
{
    CGRect frame = button.frame;
    frame.origin = (CGPoint){0,0};
    frame.size = (CGSize){40,40};
    button.frame = frame;
    
    [button setImage:[UIImage imageNamed:@"icon-menu"] forState:UIControlStateNormal];
}

-(CGFloat)leftMenuWidth
{
    return 280;
}

- (BOOL)deepnessForLeftMenu
{
    return YES;
}

- (NSIndexPath *)initialIndexPathForLeftMenu
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:4 inSection:0];
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:[self segueIdentifierForIndexPathInLeftMenu:indexPath] sender:self];
}

@end
