//
//  SPLockScreen.h
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPLockScreen;

@protocol LockScreenDelegate <NSObject>

- (void)lockScreen:(SPLockScreen *)lockScreen didEndWithPattern:(NSString *)patternNumber;

@end

@interface SPLockScreen : UIView

@property (nonatomic, strong) id<LockScreenDelegate> delegate;

@property (nonatomic) BOOL allowClosedPattern;			// Set to YES to allow a closed pattern, a complex type pattern; NO by default

// Init Method

- (id)initWithDelegate:(id<LockScreenDelegate>)lockDelegate;
- (id)initWithFrame:(CGRect)frame
      andNodeRadius:(CGFloat)nodeRadius
     andOuterRadius:(CGFloat)outerRadius
        andOutColor:(UIColor*)outerColor
      andInnerColor:(UIColor*)innerColor
  andHighlightColor:(UIColor*)highlightColor
       andLineColor:(UIColor*)lineColor
   andLineGridColor:(UIColor*)lineGridColor;
@end
