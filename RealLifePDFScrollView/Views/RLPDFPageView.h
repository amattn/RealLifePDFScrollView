/******************************************************************************
 *  \file RLPDFPageView.h
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLPDFPageView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#> 
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import <UIKit/UIKit.h>

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@interface RLPDFPageView : UIView
{

}

#pragma mark ** Designated Initializer **
- (id)initWithFrame:(CGRect)frame andScale:(CGFloat)scale;

#pragma mark ** Properties **
@property (nonatomic, assign) CGPDFPageRef pdfPageRef;
@property (nonatomic, assign) CGPDFBox pdfBoxType;

- (CGRect)rectForCurrentBounds;

#pragma mark ** Methods **

@end
