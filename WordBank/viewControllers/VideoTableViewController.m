//
//  VideoTableViewController.m
//  WordBank
//
//  Created by Peter on 2019/3/2.
//  Copyright © 2019年 Hisen. All rights reserved.
//

#import "VideoTableViewController.h"
#import "JPVPNetEasyTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "JPVideoPlayerKit.h"
#import <Masonry.h>
#import <BmobSDK/Bmob.h>
@interface VideoTableViewController ()<JPVideoPlayerDelegate,JPVPNetEasyTableViewCellDelegate>
@property (nonatomic, strong) NSArray *urlArray;
@property (nonatomic, strong) JPVPNetEasyTableViewCell *playingCell;
@end

@implementation VideoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.separatorStyle = UITableViewCellEditingStyleNone;
    [self setup];
    [self getUrlListAndFrontPicsFromServer];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.urlArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ([UIScreen mainScreen].bounds.size.width) * 9 / 16 + 10;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = NSStringFromClass([JPVPNetEasyTableViewCell class]);
    JPVPNetEasyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    cell.indexPath = indexPath;
    cell.playButton.hidden = NO;
    NSURL *url = [NSURL URLWithString:[self.urlArray[indexPath.row] objectForKey:@"frontImgUrl"]];
    [cell.videoPlayView sd_setImageWithURL:url
                          placeholderImage:[UIImage imageNamed:@"placeholder1"]];
    return cell;
}

-(void)getUrlListAndFrontPicsFromServer
{
    BmobQuery* query = [BmobQuery queryWithClassName:@"urlList"];
    [query orderByAscending:@"createdAt"];
    __block NSMutableArray *mutalArray = [NSMutableArray array];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        NSLog(@"%lu",(unsigned long)array.count);
        //        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        for (BmobObject *obj in array) {
            NSString* url = [obj objectForKey:@"url"];
            NSLog(@"%@",url);
            NSString* frontImgUrl = [obj objectForKey:@"frontImg"];
            NSLog(@"%@",frontImgUrl);
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setObject:frontImgUrl forKey:@"frontImgUrl"];
            [dict setObject:url forKey:@"url"];
            NSDictionary *tempDict = [[NSDictionary alloc] init];
            tempDict = dict;
            [mutalArray addObject:tempDict];
        }
        self.urlArray = mutalArray;
        [self.tableView reloadData];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.playingCell) {
        [self.playingCell.videoPlayView jp_stopPlay];
    }
}

- (void)cellPlayButtonDidClick:(JPVPNetEasyTableViewCell *)cell {
    if (self.playingCell) {
        [self.playingCell.videoPlayView jp_stopPlay];
        self.playingCell.playButton.hidden = NO;
    }
    self.playingCell = cell;
    self.playingCell.playButton.hidden = YES;
    self.playingCell.videoPlayView.jp_videoPlayerDelegate = self;
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    [self.playingCell.videoPlayView jp_playVideoWithURL:[NSURL URLWithString:[self.urlArray[indexPath.row] objectForKey:@"url"]]
                                     bufferingIndicator:[JPVideoPlayerBufferingIndicator new]
                                            controlView:[[JPVideoPlayerControlView alloc] initWithControlBar:nil blurImage:nil]
                                           progressView:nil
                                          configuration:nil];
}

-(void)setup
{
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([JPVPNetEasyTableViewCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([JPVPNetEasyTableViewCell class])];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"TableView Did Clicked IndexPath - %ld",(long)indexPath.row);
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.playingCell) {
        return;
    }
    if (cell.hash == self.playingCell.hash) {
        [self.playingCell.videoPlayView jp_stopPlay];
        self.playingCell.playButton.hidden = NO;
        self.playingCell = nil;
    }
}

#pragma mark - JPVideoPlayerDelegate

- (BOOL)shouldShowBlackBackgroundWhenPlaybackStart {
    return YES;
}

- (BOOL)shouldShowBlackBackgroundBeforePlaybackStart {
    return YES;
}

- (BOOL)shouldAutoHideControlContainerViewWhenUserTapping {
    return YES;
}

- (BOOL)shouldShowDefaultControlAndIndicatorViews {
    return NO;
}

@end
