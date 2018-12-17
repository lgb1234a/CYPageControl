//
//  TTNHomePageControl.h
//  spring
//
//  Created by chenyn on 2018/12/11.
//  Copyright © 2018 chenyn. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYHomePageControl;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft,
} ScrollDirection;

NS_ASSUME_NONNULL_BEGIN

// 当前页码的indicator
@interface AnimateIndicator : CALayer

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) CGFloat contentInsetOffsetHorzontal;

// 移动时的形变计算
- (void)animateIndicatorWithScrollView:(UIScrollView *)scrollView
                          andIndicator:(CYHomePageControl *)pgctl;
// 回复时的弹性动画
- (void)restoreAnimation:(id)scrlDistance;

@end

// 其他页的indicator
@interface PageCtrlIndicator : CALayer

@property (nonatomic, assign) CGFloat lastContentOffset;
@property (nonatomic, assign) NSInteger currentPage;
@property (nonatomic, assign) CGFloat contentInsetOffsetHorzontal;

// 更新indicators
- (void)updateIndicatorDisplayWithScrollView:(UIScrollView *)scrollView;
// 重置indicators
- (void)resetIndicatorDisplayWithScrollView:(UIScrollView *)scrollView;

@end

// pagecontrol组件
@interface CYHomePageControl : UIView

// 当前页的indicator的size
@property (nonatomic, assign) CGSize currentCtrlSize;
// 其他页indicator
@property (nonatomic, assign) CGSize normalCtrlSize;

// 当前页的indicator的颜色
@property (nonatomic, strong) UIColor *highlightCtrlColor;
// 其他页的indicator的颜色
@property (nonatomic, strong) UIColor *normalCtrlColor;

// 总页数
@property (nonatomic, assign) NSInteger pageCount;
// 当前页码
@property (nonatomic, assign) NSInteger currentPage;

// 绑定的scrollView
@property (nonatomic, strong) UIScrollView *bindScrollView;
// 水平方向 scrollView的content size内边距（为实现无限轮播，插值用）
@property (nonatomic, assign) CGFloat contentInsetOffsetHorzontal;

// readonly
// 当前页的indicator
@property (nonatomic, strong, readonly) AnimateIndicator *indicator;
// 其他页indicator
@property (nonatomic, strong, readonly) PageCtrlIndicator *pageIndicators;

//@property (nonatomic, copy) void(^didSelectIndicator)(NSInteger selectedIdx);

@end

NS_ASSUME_NONNULL_END
