//
//  ComposeNewPostViewController.m
//  CampusJobs
//
//  Created by Sophia Khezri on 7/16/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "ComposeNewPostViewController.h"
#import "Post.h"
#import "JobLocationMapViewController.h"

@interface ComposeNewPostViewController ()

@end

@implementation ComposeNewPostViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefinesPresentationContext:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)didTapCancelButton:(id)sender {
    [self performSegueWithIdentifier:@"cancelComposeSegue" sender:nil];
}
- (IBAction)didTapPostButton:(id)sender {
    [Post postJob:self.enteredTitle.text withSummary:self.enteredDescription.text withLocation:self.savedLocation
       withImages:nil withDate:nil withCompletion:^(BOOL succeeded, NSError * _Nullable error){
           if(succeeded){
               NSLog(@"Shared Successfully");
           } else{
               NSLog(@"%@", error.localizedDescription);
           }
       }];
    [self performSegueWithIdentifier:@"backToPersonalFeedSegue" sender:nil];
}

- (IBAction)tapGesture:(UITapGestureRecognizer *)sender {
    [self.view endEditing:YES];
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
