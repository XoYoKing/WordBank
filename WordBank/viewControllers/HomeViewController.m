//
//  ViewController.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "HomeViewController.h"
#import "WordModel.h"
#import "WordCollectionViewCell.h"
#import "HeaderReusableView.h"
#import "JHHeaderFlowLayout.h"
#import "ViewController.h"
#import "ProfileViewController.h"
#import "DictViewController.h"
#import <Masonry.h>
#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define ScreenW  ([UIScreen mainScreen].bounds.size.width - 75)



@interface HomeViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
//个人中心
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSArray *dataSource;


@end

@implementation HomeViewController
static NSString *const cellID = @"WordCollectionViewCell";
static NSString *const headerID = @"HeaderReusableView";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configDataSource];
    [self configUI];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - private
- (void)configDataSource {
    self.dataSource = @[
                        @{@"name": @"总词库", @"fileName": @"all"},
                        @{@"name": @"基础入门", @"fileName": @"basic"},
                        @{@"name": @"N1词汇", @"fileName": @"n1"},
                        @{@"name": @"N2词汇", @"fileName": @"n2"},
                        @{@"name": @"N3词汇", @"fileName": @"n3"},
                        @{@"name": @"N4&N5", @"fileName": @"n45"},
                        @{@"name": @"HSK", @"fileName": @"hsk-pinyin"},
                        @{@"name": @"人体&医学", @"fileName": @"medical"},
                        @{@"name": @"四字成语", @"fileName": @"idiom"},
                        @{@"name": @"动物", @"fileName": @"animal"},
                        @{@"name": @"常用动词", @"fileName": @"verb"},
                    ];
}
- (void)configUI {
    self.headerView.layer.shadowOffset = CGSizeMake(0, 2.5);
    self.headerView.layer.shadowOpacity = 0.05;
    self.headerView.layer.shadowColor = RGBACOLOR(0, 0, 0, 1).CGColor;
    
    self.iconLabel.layer.borderColor = RGBACOLOR(26, 59, 114, 1).CGColor;
    self.iconLabel.layer.borderWidth = 1;
    self.iconLabel.layer.cornerRadius = self.iconLabel.frame.size.width / 2;
    self.iconLabel.layer.masksToBounds = YES;
    
    JHHeaderFlowLayout *layout = [[JHHeaderFlowLayout alloc] init];
    
    layout.itemSize = CGSizeMake(ScreenW / 2, ScreenW / 2);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    //设置头部视图的尺寸
    layout.headerReferenceSize = CGSizeMake(ScreenW, 0);
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return [self.dataSource count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    WordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
    NSString *word = [dic objectForKey:@"name"];
    [cell configWithWord:word wordCount:0 type:@"home"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        ViewController *vc = (ViewController *)segue.destinationViewController;
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        NSDictionary *dic = [self.dataSource objectAtIndex:indexPath.row];
        NSString *fileName = [dic objectForKey:@"fileName"];
        NSLog(@"filename:%@",fileName);
        vc.fileName = fileName;
    }
}




@end
