/**
 * Copyright (c) Facebook, Inc. and its affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "ARTNode.h"

#import "ARTContainer.h"
#import "RCTConvert+ART.h"

@implementation ARTNode

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
  [super insertReactSubview:subview atIndex:atIndex];
  [self insertSubview:subview atIndex:atIndex];
  [self invalidate];
}

- (void)removeReactSubview:(UIView *)subview
{
  [super removeReactSubview:subview];
  [self invalidate];
}

- (void)didUpdateReactSubviews
{
  // Do nothing, as subviews are inserted by insertReactSubview:
}

- (void)setOpacity:(CGFloat)opacity
{
  [self invalidate];
  _opacity = opacity;
}

- (void)setTransform:(CGAffineTransform)transform
{
  [self invalidate];
  super.transform = transform;
}

- (void)setShadow:(ARTShadow)shadow
{
  [self invalidate];
  _shadow = shadow;
}

- (void)invalidate
{
  id<ARTContainer> container = (id<ARTContainer>)self.superview;
  [container invalidate];
}

- (void)renderTo:(CGContextRef)context
{
  if (self.opacity <= 0) {
    // Nothing to paint
    return;
  }
  if (self.opacity >= 1) {
    // Just paint at full opacity
    [self renderContentTo:context];
    [self renderLayerTo:context];
    CGContextRestoreGState(context);
    return;
  }
  
  // This needs to be painted on a layer before being composited.
  [self renderContentTo:context];
  CGContextBeginTransparencyLayer(context, NULL);
  [self renderLayerTo:context];
  CGContextEndTransparencyLayer(context);
  CGContextRestoreGState(context);
}

- (void)renderContentTo:(CGContextRef)context {
  CGContextSaveGState(context);
  CGContextConcatCTM(context, self.transform);
  CGContextSetAlpha(context, self.opacity);
  UIColor *color = [UIColor colorWithCGColor:[RCTConvert CGColor:@(self.shadow.color)]];
  color = [color colorWithAlphaComponent:self.shadow.alpha];
  CGContextSetShadowWithColor(context, self.shadow.offset, self.shadow.blur, color.CGColor);
}

- (void)renderLayerTo:(CGContextRef)context
{
  // abstract
}

@end
