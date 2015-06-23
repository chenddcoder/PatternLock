//
//  NormalCircle.h
//  SuQian
//
//  Created by Suraj on 24/9/12.
//  Copyright (c) 2012 Suraj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NormalCircle : UIView

@property (nonatomic) BOOL selected;
@property (nonatomic) CGContextRef cacheContext;

- (id)initwithRadius:(CGFloat)radius
         andOutColor:(UIColor*)outColor
       andInnerColor:(UIColor*)innerColor
   andHighlightColor:(UIColor*)highlightColor;

- (void)highlightCell;
- (void)resetCell;

@end
