//
//  WordListViewController.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "WordListViewController.h"
#import "WordDetailViewCell.h"
#import "SCLAlertView.h"
#import "LoginViewController.h"
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]

@interface WordListViewController ()<WordDetailViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *backBtn;

@end

@implementation WordListViewController
- (void)popAlert {
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.cornerRadius = 15;
    [alert showNotice:self title:@"提示" subTitle:@"您已添加过该单词，请在生词本中查看" closeButtonTitle:@"完成" duration:0.0f];
    [alert alertIsDismissed:^{
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}
- (void)pushToLoginView {
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    alert.cornerRadius = 15;
    [alert addButton:@"登录" target:self selector:@selector(login)];
    [alert showNotice:self title:@"您当前未登录" subTitle:@"是否现在登录？" closeButtonTitle:@"取消" duration:0.0f];
    [alert alertIsDismissed:^{
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
    }];
}
-(void)login {
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    [self.navigationController pushViewController:loginVC animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self configUI];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - private
- (void)configUI {
    self.headerView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.headerView.layer.shadowOpacity = 0.05;
    self.headerView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
    self.wordLabel.text = self.word;
    self.wordLabel.layer.borderColor = RGBACOLOR(26, 59, 114, 1).CGColor;
    self.wordLabel.layer.borderWidth = 1;
    self.wordLabel.layer.cornerRadius = self.wordLabel.frame.size.width / 2;
    self.wordLabel.layer.masksToBounds = YES;
    
    self.backBtn.layer.cornerRadius = self.backBtn.frame.size.width / 2;
    self.backBtn.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.backBtn.layer.shadowOpacity = 0.05;
    self.backBtn.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
    self.tableView.estimatedRowHeight = 80.0f;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_wordModels count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WordDetailViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WordDetailViewCell" forIndexPath:indexPath];

    // Configure the cell...
    cell.WordDetailViewCellDelegate = self;
    [cell configWithWordModel: [self.wordModels objectAtIndex:indexPath.row]];
    return cell;
}
# pragma mark - IBAction

- (IBAction)backBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
