//
//  FTAddFaceViewController.m
//  Fametome
//
//  Created by Famille on 07/08/14.
//  Copyright (c) 2014 Fametome. All rights reserved.
//

#import "FTAddFaceViewController.h"

@interface FTAddFaceViewController ()

@end

@implementation FTAddFaceViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Design Initialisation
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.faceImageView];
    [[FTToolBox sharedGlobalData] designExternTextField:self.faceSmsField];
    [[FTToolBox sharedGlobalData] makeCornerRadius:self.faceSubmitButton];
    
    // Add Event
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(useCamera:)];
    singleTap.numberOfTapsRequired = 1;
    self.faceImageView.userInteractionEnabled = YES;
    [self.faceImageView addGestureRecognizer:singleTap];

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //[self disableSlidePanGestureForLeftMenu];
}

#pragma mark - IBAction Methods
- (IBAction)useCamera:(id)sender {
    UIImagePickerController *imagePicker = [[FTToolBox sharedGlobalData] activeCamera];
    imagePicker.delegate = self;
    
    [self presentViewController:imagePicker animated:NO completion:nil];
}

- (IBAction)addFaceSubmit:(id)sender {

    NSString *sms = [self.faceSmsField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    UIImage *image = self.faceImageView.image;
    PFUser *user = [PFUser currentUser];
    
    [_faceSmsField resignFirstResponder]; // On cache le clavier pendant l'appel...
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:nil]; // et aussi le bouton de retour !
    
    [[FTParseBackendApi sharedGlobalData] addFaceInBackgroundAndCoreData:sms withImage:image forUser:user andController:self];
}

- (IBAction)textFieldReturn:(id)sender
{
    [sender resignFirstResponder];
}

#pragma mark - Image Picker Controller delegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.faceImageView.image = image;
    [self dismissViewControllerAnimated:NO completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:NO completion:nil];
}

@end
