//
//  AdminViewController.m
//  NissanPoker
//
//  Created by Jasper Kahn on 7/3/14.
//  Copyright (c) 2014 AppDelegates. All rights reserved.
//

#import "AdminViewController.h"
#import <AFNetworking/AFNetworking.h>

@interface AdminViewController ()

@property (strong, nonatomic) PokerHand *previousHand;

@end


@implementation AdminViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Life Cycle Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)exitButtonTapped:(id)sender {
    
    UIAlertView *exitAlert = [[UIAlertView alloc] initWithTitle:@"Exit"
                                                        message:@"Do you want to save changes?"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Exit & Save", @"Exit without Saving", nil];
    [exitAlert show];
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Exit & Save"])
        {
            //Save Changes
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        
    }
}

- (IBAction)testTapped:(id)sender {
    
    /*
    NSURL *url = [[NSURL alloc] initWithString:@"http://www.xplorious.com/wineryxplorer/wino/venue_product_features"];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSDictionary *responseDictionary = responseObject;
        
        NSArray *features = [responseDictionary objectForKey:@"venue_features"];
        NSString *firstFeature = features[0];
        
        UIAlertView *successAlert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                               message:firstFeature
                                                              delegate:nil
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles: nil];
        
        [successAlert show];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        UIAlertView *failureAlert = [[UIAlertView alloc] initWithTitle:@"Failure!"
                                                               message:nil
                                                              delegate:nil
                                                     cancelButtonTitle:@"Cancel"
                                                     otherButtonTitles:nil];
        
        [failureAlert show];
        
    }];
    
    [operation start];
    */
    
    PokerDeck *testDeck = [[PokerDeck alloc] init];
    PokerHand *testHand = [[PokerHand alloc] init];
    
    for (int i = 0; i < 7; i++){
        [testHand addCard:[testDeck drawCard]];
    }
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSDictionary *params = @{@"First Name": @"Yosefu",
                             @"Last Name": @"Nissan",
                             @"Hand": [testHand bestHandAsStringInitials],
                             @"Hand Value": [NSNumber numberWithInt:testHand.handValue]};
    
    
    [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeGradient];
    
    [manager POST:@"http://localhost/phptest/postbarf.php" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        [SVProgressHUD showSuccessWithStatus:@"Succeeded"];
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Failed"];
    }];
    
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
