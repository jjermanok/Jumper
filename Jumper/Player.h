//
//  Player.h
//  Jumper
//
//  Created by Jake Jermanok on 5/9/15.
//

#import <SpriteKit/SpriteKit.h>

@interface Player : SKSpriteNode
@property (nonatomic, assign) CGPoint velocity;
@property (nonatomic, assign) CGPoint desiredPosition;
@property (nonatomic, assign) BOOL onGround;
@property (nonatomic, assign) BOOL forwardMarch;
@property (nonatomic, assign) BOOL backwardMarch;
@property (nonatomic, assign) BOOL mightAsWellJump;
@property (nonatomic, assign) int jumpCount;
- (void)update:(NSTimeInterval)delta;
-(void)jumpOnce;
-(CGRect)collisionBoundingBox;
@end
