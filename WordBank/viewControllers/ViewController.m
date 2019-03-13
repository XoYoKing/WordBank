//
//  ViewController.m
//  WordBank
//
//  Created by Hisen on 20/03/2018.
//  Copyright © 2018 Hisen. All rights reserved.
//

#import "ViewController.h"
#import "WordModel.h"
#import "WordCollectionViewCell.h"
#import "HeaderReusableView.h"
#import "JHHeaderFlowLayout.h"
#import "WordListViewController.h"

#define RGBACOLOR(R,G,B,A)      [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define ScreenW  ([UIScreen mainScreen].bounds.size.width - 80)



@interface ViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *headerView;
@property (weak, nonatomic) IBOutlet UILabel *iconLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) NSDictionary *wordDataSource;
@property (strong, nonatomic) NSMutableArray *prefixs;
@property (strong, nonatomic) NSDictionary *rawWordDataSource;


@end

@implementation ViewController
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
    self.prefixs = [NSMutableArray arrayWithArray: @[@"a", @"b", @"c", @"d", @"e", @"f", @"g", @"h",
                                      @"i", @"j", @"k", @"l", @"m", @"o", @"p", @"q",
                                      @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z"]];
    NSString *path = [[NSBundle mainBundle] pathForResource:self.fileName ofType:@"json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    //数组里存放字典
    NSArray *jsonArr = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSError *error = nil;
    NSMutableDictionary *dataSource = [NSMutableDictionary new];
    NSMutableDictionary *rawDataSource = [NSMutableDictionary new];
    NSMutableArray *wordModelArr = [WordModel arrayOfModelsFromDictionaries:jsonArr error:&error];
    for (WordModel *wordModel in wordModelArr) {

        if (![dataSource objectForKey:wordModel.prefix]) {
            dataSource[wordModel.prefix] = [NSMutableDictionary new];
            rawDataSource[wordModel.prefix] = [NSMutableArray new];
        }

        NSMutableDictionary *dic = dataSource[wordModel.prefix];

        if ([dic objectForKey:wordModel.word]) {
            [dic[wordModel.word] addObject:wordModel];
        } else {
            dic[wordModel.word] = [NSMutableArray new];
            [dic[wordModel.word] addObject:wordModel];
            [rawDataSource[wordModel.prefix] addObject:wordModel.word];
        }
    }

    self.wordDataSource = dataSource;
    NSLog(@"****************dataSource:%@",dataSource);
    self.rawWordDataSource = rawDataSource;
    NSLog(@"****************dataSource:%@",rawDataSource);
    NSArray *prefixArr = [self.prefixs copy];
    for (NSString *prefix in prefixArr) {
        if (![[dataSource allKeys] containsObject:prefix]) {
            [self.prefixs removeObject:prefix];
        }
    }
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
    
    layout.itemSize = CGSizeMake(ScreenW / 3, ScreenW / 3);
    layout.minimumInteritemSpacing = 10;
    layout.minimumLineSpacing = 10;
    //设置头部视图的尺寸
    layout.headerReferenceSize = CGSizeMake(ScreenW, 40);
    self.collectionView.collectionViewLayout = layout;
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    //    self.automaticallyAdjustsScrollViewInsets = NO;
        
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([HeaderReusableView class]) bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerID];
}

#pragma mark - UICollectionViewDataSource & UICollectionViewDelegate
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.prefixs count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.wordDataSource) {
        NSString *key = [self.prefixs objectAtIndex:section];
        return [[[self.wordDataSource objectForKey:key] allKeys] count];
    }
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    //如果是头部视图
    if (kind == UICollectionElementKindSectionHeader) {
        HeaderReusableView *headerRV = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:headerID forIndexPath:indexPath];
        [headerRV configWithPrefix:[self.prefixs objectAtIndex: indexPath.section]];
        return headerRV;
    } else {
        return nil;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
     WordCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    
    
    NSString *key = [self.prefixs objectAtIndex:indexPath.section];
    
    NSArray *arr = [self.rawWordDataSource objectForKey:key];
    
    NSString *word = [arr objectAtIndex:indexPath.row];
    NSInteger count = [[[self.wordDataSource objectForKey:key] objectForKey:word] count];
    [cell configWithWord:word wordCount:count type:@"detail"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"show"]) {
        NSIndexPath *indexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        NSString *key = [self.prefixs objectAtIndex:indexPath.section];
        NSString *wordKey = [[self.rawWordDataSource objectForKey:key] objectAtIndex:indexPath.row];
        NSArray *arr = [[self.wordDataSource objectForKey:key] objectForKey:wordKey];
        WordListViewController *wordListVC = (WordListViewController *)segue.destinationViewController;
        wordListVC.word = wordKey;
        wordListVC.wordModels = arr;
    }
}

# pragma mark - IBAction

- (IBAction)backBtnClicked:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
