//
//  Player.m
//  Jumper
//
//  Created by Jake Jermanok on 5/9/15.
//

#import "Player.h"
#import "SKTUtils.h"

@implementation Player

- (instancetype)initWithImageNamed:(NSString *)name {
    if (self == [super initWithImageNamed:name]) {
        self.velocity = CGPointMake(0.0, 0.0);
    }
    return self;
}

- (CGRect)collisionBoundingBox {
    CGRect boundingBox = CGRectInset(self.frame, 2, 0);
    CGPoint diff = CGPointSubtract(self.desiredPosition, self.position);
    return CGRectOffset(boundingBox, diff.x, diff.y);
}

- (void)update:(NSTimeInterval)delta
{
    CGPoint gravity = CGPointMake(0.0, -700.0);
    CGPoint gravityStep = CGPointMultiplyScalar(gravity, delta);
    CGPoint forwardMove = CGPointMake(950.0, 0.0);
    CGPoint forwardMoveStep = CGPointMultiplyScalar(forwardMove, delta);
    CGPoint backwardMove = CGPointMake(-950.0, 0.0);
    CGPoint backwardMoveStep = CGPointMultiplyScalar(backwardMove, delta);
    
    self.velocity = CGPointAdd(self.velocity, gravityStep);
    self.velocity = CGPointMake(self.velocity.x * 0.9, self.velocity.y);
    if (self.forwardMarch) {
        self.velocity = CGPointAdd(self.velocity, forwardMoveStep);
    }
    if (self.backwardMarch) {
        self.velocity = CGPointAdd(self.velocity, backwardMoveStep);
    }
    CGPoint minMovement = CGPointMake(-180.0, -650);
    CGPoint maxMovement = CGPointMake(180.0, 400.0);
    self.velocity = CGPointMake(Clamp(self.velocity.x, minMovement.x, maxMovement.x), Clamp(self.velocity.y, minMovement.y, maxMovement.y));
    
    CGPoint velocityStep = CGPointMultiplyScalar(self.velocity, delta);
    
    self.desiredPosition = CGPointAdd(self.position, velocityStep);
}

- (void)jumpOnce {
    //NSLog(@"%i", self.jumpCount);
    if (!self.jumpCount == 0) {
        CGPoint jumpForce = CGPointMake(0.0, 310.0);
        self.velocity = CGPointMake(self.velocity.x, jumpForce.y);
        //float jumpCutoff = 150.0;
        //else if (!self.mightAsWellJump && self.velocity.y > jumpCutoff) {
        // self.velocity = CGPointMake(self.velocity.x, jumpCutoff);
        //}
        self.jumpCount--;
    }
}

@end
