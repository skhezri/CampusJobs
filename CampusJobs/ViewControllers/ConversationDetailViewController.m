//
//  ConversationDetailViewController.m
//  CampusJobs
//
//  Created by Sophia Zheng on 7/18/18.
//  Copyright © 2018 So What. All rights reserved.
//

#import "ConversationDetailViewController.h"
#import "MessageCollectionViewCell.h"
#import "SuggestPriceViewController.h"
#import "Message.h"
#import "Helper.h"

@interface ConversationDetailViewController () <UICollectionViewDelegate, UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *messagesCollectionView;
@property (weak, nonatomic) IBOutlet UITextField *messageTextField;
@property (strong, nonatomic) PFUser *user;
@property (assign, nonatomic) CGFloat maxCellWidth;
@property (assign, nonatomic) CGFloat maxCellHeight;

@end

@implementation ConversationDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];    
    self.user = [PFUser currentUser];
    self.messagesCollectionView.delegate = self;
    self.messagesCollectionView.dataSource = self;
    
    // put other user's username label in navigation bar
    UILabel *otherUserLabel = [[UILabel alloc] init];
    otherUserLabel.text = [NSString stringWithFormat:@"%@ - %@", self.otherUser.username, self.conversation.post.title];
    self.navigationItem.titleView = otherUserLabel;
}

- (void)reloadData {
    [self.messagesCollectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.conversation.messages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MessageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MessageCell" forIndexPath:indexPath];
    
    [cell configureCellWithMessage:self.conversation.messages[indexPath.item] withConversation:self.conversation withMaxWidth:self.maxCellWidth withMaxHeight:self.maxCellHeight];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    self.maxCellWidth = collectionView.frame.size.width;
    self.maxCellHeight = collectionView.frame.size.height * 3; // arbitrary large height
    
    Message *message = self.conversation.messages[indexPath.item];
    NSString *messageText = message[@"text"];
    
    // estimate frame size based on message text
    CGSize boundedSize = CGSizeMake(self.maxCellWidth, self.maxCellHeight);
    NSStringDrawingOptions options = NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin;
    CGRect estimatedFrame = [messageText boundingRectWithSize:boundedSize options:options attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:15]} context:nil];
    
    // show/hide the accept/decline suggested price buttons
    CGFloat buttonsStackViewAllowance = 0;
    if (message[@"suggestedPrice"] && ![message.sender.objectId isEqualToString:[PFUser currentUser].objectId]) {
        buttonsStackViewAllowance = 40;
    }

    return CGSizeMake(collectionView.frame.size.width, estimatedFrame.size.height + 20 + buttonsStackViewAllowance);
}

- (IBAction)didTapSuggestPriceButton:(id)sender {
    [self setDefinesPresentationContext:YES];
    [self performSegueWithIdentifier:@"suggestPriceModalSegue" sender:nil];
}

- (IBAction)didTapBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapAway:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)didTapSendMessage:(id)sender {
    [Message createMessageWithText:self.messageTextField.text withSender:self.user withReceiver:self.otherUser withCompletion:^(PFObject *createdMessage, NSError *error) {
        if (createdMessage) {
            [self.conversation addToConversationWithMessage:(Message *)createdMessage withCompletion:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    self.messageTextField.text = @"";
                    [self.messagesCollectionView reloadData];
                } else {
                    [Helper callAlertWithTitle:@"Error sending message" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:self];
                }
            }];
        } else {
            [Helper callAlertWithTitle:@"Error sending message" alertMessage:[NSString stringWithFormat:@"%@", error.localizedDescription] viewController:self];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"suggestPriceModalSegue"]) {
        SuggestPriceViewController *suggestPriceController = [segue destinationViewController];
        suggestPriceController.conversation = self.conversation;
        suggestPriceController.otherUser = self.otherUser;
    }
}

@end
