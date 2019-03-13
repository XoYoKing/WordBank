//
//  NoteBookTableViewController.m
//  WordBank
//
//  Created by Peter on 2019/2/20.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "NoteBookTableViewController.h"
#import "NoteBookTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "WordModel.h"
#import <Masonry.h>

//屏幕宽
#define kScreenW [UIScreen mainScreen].bounds.size.width
//屏幕高
#define kScreenH [UIScreen mainScreen].bounds.size.height

@interface NoteBookTableViewController ()
{
    NSMutableArray  *_mutableArray;
}
@property(nonatomic,strong) NSArray *dataArray;
@property (nonatomic, strong) UIWindow *window;
@end

@implementation NoteBookTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"\n seld.dataArray: \n %@",self.dataArray);
    self.tableView .separatorStyle = UITableViewCellEditingStyleNone;
    _mutableArray = [[NSMutableArray alloc] initWithCapacity:1];
    [self getNoteBookFromServer];
}


#pragma 点击返回
-(void)didClickBackBtn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NoteBookTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noteCell"];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"NoteBookTableViewCell" owner:nil options:nil] lastObject];
    }
    WordModel *model = self.dataArray[indexPath.row];
    cell.kanaLabel.text = model.kana;
    cell.sampleLabel.text = model.sample;
    cell.jpWordLabel.text = model.jpword;
    cell.meanLabel.text = model.mean;
    return cell;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WordModel *model = self.dataArray[indexPath.row];
        BmobQuery* query = [BmobQuery queryWithClassName:@"words"];
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSArray *array =  @[@{@"userID":[user objectForKey:@"userID"]},@{@"kanaLabel":model.kana},@{@"sampleLabel":model.sample},@{@"jpWordLabel":model.jpword},@{@"meanLabel":model.mean}];
        [query addTheConstraintByAndOperationWithArray:array];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            BmobObject *obj = [array firstObject];
            [obj deleteInBackground];
        }];
    }
    NSMutableArray *tmpArray = [[NSMutableArray alloc] init];
    [tmpArray addObjectsFromArray:self.dataArray];
    [tmpArray removeObjectAtIndex:indexPath.row];
    self.dataArray = tmpArray;
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}


-(void)getNoteBookFromServer
{
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *userID = [user objectForKey:@"userID"];
    NSLog(@"\n userID: \n %@",userID);
    if (userID == nil) {
        NSLog(@"暂未登陆");
    }else{
        [self->_mutableArray removeAllObjects];
        BmobQuery* query = [BmobQuery queryWithClassName:@"words"];
        [query orderByAscending:@"createdAt"];
        [query whereKey:@"userID" equalTo:userID];
        [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            NSLog(@"%lu",(unsigned long)array.count);
            for (BmobObject *obj in array) {
                WordModel *model = [[WordModel alloc] init];
                model.sample = [obj objectForKey:@"sampleLabel"];
                model.mean = [obj objectForKey:@"meanLabel"];
                model.kana = [obj objectForKey:@"kanaLabel"];
                model.jpword = [obj objectForKey:@"jpWordLabel"];
                [self->_mutableArray addObject:model];
            }
            self.dataArray = self->_mutableArray;
            NSLog(@"self.dataArray.count:%lu",self.dataArray.count);
            [self.tableView reloadData];
        }];
    }
}
@end
