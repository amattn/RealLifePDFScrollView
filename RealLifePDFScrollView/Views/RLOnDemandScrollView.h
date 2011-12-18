/******************************************************************************
 *  \file RLOnDemandScrollView.h
 *  \author Matt Nunogawa
 *  \date 12/17/11
 *  \class RLOnDemandScrollView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#> 
 *  \copyright Copyright __MyCompanyName__ 2011. All rights reserved.
 */

#import <UIKit/UIKit.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@protocol RLOnDemandScrollViewDataSource <NSObject>

@required
- (UIView *)viewForIndex:(NSUInteger)index;
- (CGFloat)heightForViewAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfViews;
@optional

// TBD

@end

@interface RLOnDemandScrollView : UIScrollView <UIScrollViewDelegate>
{

}

#pragma mark ** Designated Initializer **

#pragma mark ** Properties **

@property (nonatomic, weak) NSObject <RLOnDemandScrollViewDataSource> *dataSource;
@property (nonatomic, assign) CGFloat gutterBetweenViews;  //default 0
#pragma mark ** Methods **

- (void)reloadData;

@end
