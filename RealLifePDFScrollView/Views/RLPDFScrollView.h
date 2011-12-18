/******************************************************************************
 *  \file RLPDFScrollView.h
 *  \author Matt Nunogawa
 *  \date 12/14/11
 *  \class RLPDFScrollView
 *  \brief <#BRIEF#>
 *  \details from https://github.com/amattn/RealLifeXcode4Templates
 *  \abstract <#ABSTRACT#> 
 *  \copyright Copyright Matt Nunogawa 2011. All rights reserved.
 */

#import <UIKit/UIKit.h>
#import "RLOnDemandScrollView.h"

#pragma mark ** Constant Defines **

#pragma mark ** Protocols & Declarations **

@interface RLPDFScrollView : UIScrollView <RLOnDemandScrollViewDataSource>
{

}

#pragma mark ** Designated Initializer **
//- (id)initWithFrame:(CGRect)frame;

#pragma mark ** Properties **

@property (nonatomic, strong) NSURL *pdfURL;


#pragma mark ** Methods **

+ (NSString *)reasonForPDFOpenErrorForDocument:(CGPDFDocumentRef)pdfDocumentRef;
+ (BOOL)hasErrorOpeningPDFDocument:(CGPDFDocumentRef)pdfDocumentRef;

@end
