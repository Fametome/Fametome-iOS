//
//  FTLeftMenuViewController.m
//  Fametome
//
//  Created by Famille on 17/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTLeftMenuViewController.h"
#import "SlideNavigationContorllerAnimatorFade.h"
#import "SlideNavigationContorllerAnimatorSlide.h"
#import "SlideNavigationContorllerAnimatorScale.h"
#import "SlideNavigationContorllerAnimatorScaleAndFade.h"
#import "SlideNavigationContorllerAnimatorSlideAndFade.h"

@interface FTLeftMenuViewController ()

@end

@implementation FTLeftMenuViewController

#pragma mark - UIViewController Methods -

- (id)initWithCoder:(NSCoder *)aDecoder
{
	self.slideOutAnimationEnabled = YES;
	
	return [super initWithCoder:aDecoder];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorColor = [UIColor lightGrayColor];
	
	/*UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"login_background.png"]];
	self.tableView.backgroundView = imageView;
	*/
	self.view.layer.borderWidth = .6;
	self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    //UIViewController *leftMenu = [SlideNavigationController sharedInstance].leftMenu;
    //[SlideNavigationController sharedInstance].leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:nil];;
    
    self.tableView.tableFooterView.tintColor = [UIColor orangeColor];
    
    // own customisation
    [[FTToolBox sharedGlobalData] makeCornerRadiusAndBorder:_avatarImageView];
    
}

#pragma mark - UITableView Delegate & Datasrouce -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	if(section == 0)
        return 4;
    return 1;
}

- (UILabel *) newLabelWithTitle:(NSString *)paramTitle
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = paramTitle;
    label.backgroundColor = [UIColor clearColor];
    [label sizeToFit];
    return label;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *header;
    
    if(section == 0){
        UILabel *label = [self newLabelWithTitle:@"Fametome"];
        
        /* Move the label 10 points to the right */
        label.frame = CGRectMake(label.frame.origin.x + 10.0f, 20.0f, label.frame.size.width, label.frame.size.height);
        
        /* Give the container view 10 points more in width than our label because the label needs a 10 extra points left-margin */
        CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width + 10.0f, label.frame.size.height);
        header = [[UIView alloc] initWithFrame:resultFrame];
        [header addSubview:label];
    }
    
    return header;
}

-(UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *footer = nil;
    
    if(section == 0){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
        
        /* Move the label 10 points to the right */
        label.frame = CGRectMake(label.frame.origin.x + 10.0f, 5.0f, label.frame.size.width, label.frame.size.height);
        
        /* Give the container view 10 points more in width than our label because the label needs a 10 extra points left-margin */
        CGRect resultFrame = CGRectMake(0.0f, 0.0f, label.frame.size.width + 10.0f, label.frame.size.height);
        footer = [[UIView alloc] initWithFrame:resultFrame];
        [footer addSubview:label];
    }
    return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == 0){
        return @"© Fametome 2014 ";
    }
    
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
        return 50.0f;

    return 0.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if(section == 0)
        return 30.0f;
    
    //if(section == 1)
      //  return 30.0f;
    
    return 0.0f;
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"leftMenuCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"leftMenuCell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
	switch (indexPath.row)
	{
		case 0:
			cell.textLabel.text = @"Profil";
			break;
			
		case 1:
			cell.textLabel.text = @"Réception";
            cell.imageView.image = [UIImage imageNamed:@"tag.png"];
			break;
			
		case 2:
			cell.textLabel.text = @"Envoie";
            cell.imageView.image = [UIImage imageNamed:@"news.png"];
			break;
			
		case 3:
			cell.textLabel.text = @"Amis";
            cell.imageView.image = [UIImage imageNamed:@"wishlist.png"];
			break;
            
        case 4:
            cell.textLabel.text = @"Déconnexion";
            break;
	}
	
	cell.backgroundColor = [UIColor clearColor];
	
	return cell;
}*/
 

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle: nil];
	
	UIViewController *vc ;
    
    if(indexPath.section == 0){
    	switch (indexPath.row)
        {
            case 0:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ProfilViewController"];
                break;
                
            case 1:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier: @"ReceptionViewController"];
                break;
                
            case 2:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"SendViewController"];
                break;
                
            case 3:
                vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"AmisViewController"];
                break;
        }
    }else{
        [PFUser logOut];
        [PFQuery clearAllCachedResults];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
        [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    }
    
	
	[[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
															 withSlideOutAnimation:self.slideOutAnimationEnabled
																	 andCompletion:nil];
}

@end
