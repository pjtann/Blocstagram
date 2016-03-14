//
//  CircleSpinnerView.m
//  Blocstagram
//
//  Created by PT on 3/11/16.
//  Copyright (c) 2016 PeterTanner. All rights reserved.
//

#import "CircleSpinnerView.h"

@interface CircleSpinnerView ()

@property (nonatomic, strong) CAShapeLayer *circleLayer;


@end

@implementation CircleSpinnerView


// create a cirlelayer by overriding the getter
- (CAShapeLayer*)circleLayer {
    if(!_circleLayer) {
        
        // the CGPoint is calculated here to represent the center of the arc which in this case is an entire circle
        CGPoint arcCenter = CGPointMake(self.radius+self.strokeThickness/2+5, self.radius+self.strokeThickness/2+5);
        CGRect rect = CGRectMake(0, 0, arcCenter.x*2, arcCenter.y*2);
        
        
        // arcCenter is used to construct a CGRect that the spinning circle will fit inside of. This also makes a UIBezierPath object; bezier path is a path which can have both straight and curved line segments.
        // the bezierPathWithArcCenter.... makes a new bezier path in teh shape of an arc and the smoothedPath represents a smooth circle
        UIBezierPath* smoothedPath = [UIBezierPath bezierPathWithArcCenter:arcCenter
                                                                    radius:self.radius
                                                                startAngle:M_PI*3/2
                                                                  endAngle:M_PI/2+M_PI*5
                                                                 clockwise:YES];
        
        
        // here we are creating a CAShaperLayer; a core animation from a bezier path.
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.contentsScale = [[UIScreen mainScreen] scale];
        _circleLayer.frame = rect;
        // center of circle to be transparent/clear
        _circleLayer.fillColor = [UIColor clearColor].CGColor;
        _circleLayer.strokeColor = self.strokeColor.CGColor;
        _circleLayer.lineWidth = self.strokeThickness;
        // shape of the ends of the line
        _circleLayer.lineCap = kCALineCapRound;
        // specifys shape of joints between parts of the line
        _circleLayer.lineJoin = kCALineJoinBevel;
        // assign the circular path to the layer
        _circleLayer.path = smoothedPath.CGPath;
        
        // make a mask layer allowing circle to have a gradient on it
        CALayer *maskLayer = [CALayer layer];
        maskLayer.contents = (id)[[UIImage imageNamed:@"angle-mask"] CGImage];
        maskLayer.frame = _circleLayer.bounds;
        _circleLayer.mask = maskLayer;
        
        // animate the maske in a circular motion
        // animation duration is set to 1 second
        CFTimeInterval animationDuration = 1;
        CAMediaTimingFunction *linearCurve = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
        // specify this animation will animate the layers rotation from 0 to pi*2 (one full circle)
        animation.fromValue = @0;
        animation.toValue = @(M_PI*2);
        animation.duration = animationDuration;
        animation.timingFunction = linearCurve;
        animation.removedOnCompletion = NO;
        // repeat the animation an infinite number of times
        animation.repeatCount = INFINITY;
        // specify what happens when teh animation is complete; we specify to leave the animation on the screen versus hiding the layer so it's not visible anymore
        animation.fillMode = kCAFillModeForwards;
        animation.autoreverses = NO;
        [_circleLayer.mask addAnimation:animation forKey:@"rotate"];
        
        // add the animation to the layer. The two animations we are using (strokeStart.. and strokeEnd..) are added to an animation group (animationGroup) which groups multiple animations together and runs them concurently
        CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
        animationGroup.duration = animationDuration;
        animationGroup.repeatCount = INFINITY;
        animationGroup.removedOnCompletion = NO;
        animationGroup.timingFunction = linearCurve;
        
        CABasicAnimation *strokeStartAnimation = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
        strokeStartAnimation.fromValue = @0.015;
        strokeStartAnimation.toValue = @0.515;
        
        CABasicAnimation *strokeEndAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
        strokeEndAnimation.fromValue = @0.485;
        strokeEndAnimation.toValue = @0.985;
        
        animationGroup.animations = @[strokeStartAnimation, strokeEndAnimation];
        [_circleLayer addAnimation:animationGroup forKey:@"progress"];
        
    }
    return _circleLayer;
}

// this method positions the circle layer in the center of the view
-(void)layoutAnimatedLayer{
    [self.layer addSublayer:self.circleLayer];
    
    self.circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    
}

// adds a subview to the layoutAnimatedLayer
-(void)willMoveToSuperview:(UIView *)newSuperview{
    if (newSuperview != nil) {
        [self layoutAnimatedLayer];
    }else{
        [self.circleLayer removeFromSuperlayer];
        self.circleLayer = nil;
        
    }
}

// update teh position of the layer if the frame changes
-(void) setFrame:(CGRect)frame{
    [super setFrame:frame];
    
    if (self.superview != nil) {
        [self layoutAnimatedLayer];
        
    }
}

// if we change the radius of the circle the positioning is affected so we update by overriding the setter (setRadius) to recreate the circle layer
-(void) setRadius:(CGFloat)radius{
    _radius = radius;
    
    [_circleLayer removeFromSuperlayer];
    _circleLayer = nil;
    
    [self layoutAnimatedLayer];
    
}

// inform the self.circleLayer if the other two properties change (stroke width or color)
-(void)setStrokeColor:(UIColor *)strokeColor{
    _strokeColor = strokeColor;
    _circleLayer.strokeColor = strokeColor.CGColor;
    
}
// inform the self.circleLayer if the other two properties change (stroke width or color)
-(void) setStrokeThickness:(CGFloat)strokeThickness{
    _strokeThickness = strokeThickness;
    _circleLayer.lineWidth = _strokeThickness;
    
}

// set some default values in the initializer and provide a hint about our size
-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.strokeThickness = 1;
        self.radius = 12;
        self.strokeColor = [UIColor purpleColor];
        
    }
    return self;
    
}

// provide a hint about our size
-(CGSize) sizeThatFits:(CGSize)size {
    return CGSizeMake((self.radius+self.strokeThickness/2+5)*2, (self.radius+self.strokeThickness/2+5)*2);
    
}






/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
