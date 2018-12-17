//
//  ViewController.m
//  spring
//
//  Created by chenyn on 2018/12/11.
//  Copyright © 2018 chenyn. All rights reserved.
//

#import "ViewController.h"
#import "CYHomePageControl.h"

@interface ViewController () <UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrolView;
@property (nonatomic, strong) CYHomePageControl *pageCtrl;
@property (nonatomic, strong) NSArray *colors;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _colors = @[
                [UIColor redColor],
                [UIColor blackColor],
                [UIColor redColor],
                [UIColor blackColor],
                [UIColor redColor],
                [UIColor blackColor]
                ];
    
    self.scrolView.frame = self.view.bounds;
    self.scrolView.contentSize = CGSizeMake(CGRectGetWidth(self.view.bounds)*_colors.count, 0);
    self.scrolView.pagingEnabled = YES;
    for (int i = 0; i < _colors.count; i++) {
        UIView *colorView = [UIView new];
        colorView.backgroundColor = _colors[i];
        colorView.frame = CGRectMake(CGRectGetWidth(self.view.bounds) * i, 0, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds));
        [self.scrolView addSubview:colorView];
    }
    
    [self.view addSubview:self.pageCtrl];
    
    self.scrolView.delegate = self;
    
    [self.pageCtrl.indicator animateIndicatorWithScrollView:self.scrolView
                                               andIndicator:self.pageCtrl];
    [self.pageCtrl.pageIndicators updateIndicatorDisplayWithScrollView:self.scrolView];
}

- (CYHomePageControl *)pageCtrl
{
    if(!_pageCtrl) {
        CGRect frame = CGRectMake((self.view.bounds.size.width - 100)*0.5, self.view.bounds.size.height - 200, 90, 30);
        _pageCtrl = [[CYHomePageControl alloc] initWithFrame:frame];
        _pageCtrl.pageCount = _colors.count;
        _pageCtrl.currentPage = 0;
        _pageCtrl.highlightCtrlColor = [UIColor whiteColor];
        _pageCtrl.normalCtrlColor = [UIColor colorWithWhite:1.0 alpha:0.7];
        _pageCtrl.normalCtrlSize = CGSizeMake(5, 5);
        _pageCtrl.currentCtrlSize = CGSizeMake(18, 5);
        _pageCtrl.bindScrollView = self.scrolView;
    }
    return _pageCtrl;
}

#pragma mark-- UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // Indicator动画
    [self.pageCtrl.indicator animateIndicatorWithScrollView:scrollView
                                                  andIndicator:self.pageCtrl];
    [self.pageCtrl.pageIndicators updateIndicatorDisplayWithScrollView:scrollView];
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    [self.pageCtrl.indicator restoreAnimation:@(1.0 / self.pageCtrl.pageCount)];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageCtrl.pageIndicators resetIndicatorDisplayWithScrollView:scrollView];
    
    self.pageCtrl.indicator.lastContentOffset = scrollView.contentOffset.x;
    self.pageCtrl.pageIndicators.lastContentOffset = scrollView.contentOffset.x;
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self.pageCtrl.indicator restoreAnimation:@(1.0 / self.pageCtrl.pageCount)];
    [self.pageCtrl.pageIndicators resetIndicatorDisplayWithScrollView:scrollView];
    
    self.pageCtrl.indicator.lastContentOffset = scrollView.contentOffset.x;
    self.pageCtrl.pageIndicators.lastContentOffset = scrollView.contentOffset.x;
}


@end
