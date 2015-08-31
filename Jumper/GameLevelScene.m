//
//  GameLevelScene.m
//  Jumper
//
//  Created by Jake Jermanok on 5/9/15.
//

#import "GameLevelScene.h"
#import "JSTileMap.h"
#import "Player.h"
#import "SKTUtils.h"

@interface GameLevelScene()

@property (nonatomic, strong) TMXLayer *hazards;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, strong) JSTileMap *map;
@property (nonatomic, assign) NSTimeInterval previousUpdateTime;
@property (nonatomic, strong) TMXLayer *walls;
@property (nonatomic, strong) SKLabelNode *jumpsLabel;

@end

@implementation GameLevelScene

-(id)initWithSize:(CGSize)size {
  if (self = [super initWithSize:size]) {
    self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
    self.map = [JSTileMap mapNamed:@"level1.tmx"];
    [self addChild:self.map];
    self.player = [[Player alloc] initWithImageNamed:@"koalio_stand"];
    self.player.position = CGPointMake(150, 50);
    self.player.zPosition = 15;
    self.player.jumpCount = 20;
    [self.map addChild:self.player];
    self.walls = [self.map layerNamed:@"walls"];
    self.hazards = [self.map layerNamed:@"hazards"];
    self.userInteractionEnabled = YES;
    self.jumpsLabel = [SKLabelNode labelNodeWithFontNamed:@"Trebuchet MS"];
    self.jumpsLabel.fontColor = [UIColor blackColor];
    self.jumpsLabel.fontSize = 18;
    self.jumpsLabel.text = [NSString stringWithFormat:@"Jumps Left: %i", self.player.jumpCount];
    self.jumpsLabel.color = [UIColor blackColor];
    self.jumpsLabel.position = CGPointMake(70, 295);
    [self addChild:self.jumpsLabel];
  }
  return self;
}

- (void)update:(NSTimeInterval)currentTime
{
  if (self.gameOver) return;
  NSTimeInterval delta = currentTime - self.previousUpdateTime;
  if (delta > 0.02) {
    delta = 0.02;
  }
  self.previousUpdateTime = currentTime;
  [self.player update:delta];
  [self checkForAndResolveCollisionsForPlayer:self.player forLayer:self.walls];
  [self handleHazardCollisions:self.player];
  [self checkForWin];
  [self setViewpointCenter:self.player.position];
}

-(CGRect)tileRectFromTileCoords:(CGPoint)tileCoords {
  float levelHeightInPixels = self.map.mapSize.height * self.map.tileSize.height;
  CGPoint origin = CGPointMake(tileCoords.x * self.map.tileSize.width, levelHeightInPixels - ((tileCoords.y + 1) * self.map.tileSize.height));
  return CGRectMake(origin.x, origin.y, self.map.tileSize.width, self.map.tileSize.height);
}

- (NSInteger)tileGIDAtTileCoord:(CGPoint)coord forLayer:(TMXLayer *)layer {
  TMXLayerInfo *layerInfo = layer.layerInfo;
  return [layerInfo tileGidAtCoord:coord];
}

- (void)checkForAndResolveCollisionsForPlayer:(Player *)player forLayer:(TMXLayer *)layer {
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  player.onGround = NO;
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [layer coordForPoint:player.desiredPosition];
    if (playerCoord.y >= self.map.mapSize.height - 1) {
      [self gameOver:0];
      return;
    }
    if (player.position.x < 6)
      player.desiredPosition =  CGPointMake(6, player.desiredPosition.y);
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:layer];
    if (gid) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        CGRect intersection = CGRectIntersection(playerRect, tileRect);
        if (tileIndex == 7) {
          //tile is directly below Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
          player.onGround = YES;
        } else if (tileIndex == 1) {
          //tile is directly above Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y - intersection.size.height);
          player.velocity = CGPointMake(player.velocity.x, 0.0);
        } else if (tileIndex == 3) {
          //tile is left of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x + intersection.size.width, player.desiredPosition.y);
        } else if (tileIndex == 5) {
          //tile is right of Koala
          player.desiredPosition = CGPointMake(player.desiredPosition.x - intersection.size.width, player.desiredPosition.y);
        } else {
          if (intersection.size.width > intersection.size.height) {
            //tile is diagonal, but resolving collision vertically
            float intersectionHeight;
            if (tileIndex > 4) {
              intersectionHeight = intersection.size.height;
              player.onGround = YES;
            } else {
              intersectionHeight = -intersection.size.height;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x, player.desiredPosition.y + intersection.size.height );
          } else {
            //tile is diagonal, but resolving horizontally
            float intersectionWidth;
            if (tileIndex == 6 || tileIndex == 0) {
              intersectionWidth = intersection.size.width;
            } else {
              intersectionWidth = -intersection.size.width;
            }
            player.desiredPosition = CGPointMake(player.desiredPosition.x  + intersectionWidth, player.desiredPosition.y);
          }
        }
      }
    }
  }
  player.position = player.desiredPosition;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    
    if (CGRectContainsPoint(CGRectMake(10, 10, 60, 60), touchLocation))
      self.player.backwardMarch = YES;
    if (CGRectContainsPoint(CGRectMake(70, 10, 60, 60), touchLocation))
      self.player.forwardMarch = YES;
    if (CGRectContainsPoint(CGRectMake(500, 10, 60, 60), touchLocation)) {
      [self.player jumpOnce];
      self.jumpsLabel.text = [NSString stringWithFormat:@"Jumps Left: %i", self.player.jumpCount];
    }
    if (CGRectContainsPoint(CGRectMake(505, 290, 60, 60), touchLocation)) {
      [UIView animateWithDuration:0.1 animations:^() {
        self.view.alpha = 0.0;
      }];
      [self performSelector:@selector(replay:) withObject:NULL afterDelay:.2];
    }
      
  }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    CGPoint previousTouchLocation = [touch previousLocationInNode:self];
    if (CGRectContainsPoint(CGRectMake(70, 10, 60, 60), previousTouchLocation) &&
        !CGRectContainsPoint(CGRectMake(70, 10, 60, 60), touchLocation))
      self.player.forwardMarch = NO;
    if (CGRectContainsPoint(CGRectMake(10, 10, 60, 60), previousTouchLocation) &&
        !CGRectContainsPoint(CGRectMake(10, 10, 60, 60), touchLocation))
      self.player.backwardMarch = NO;
    if (CGRectContainsPoint(CGRectMake(500, 10, 60, 60), previousTouchLocation) &&
        !CGRectContainsPoint(CGRectMake(500, 10, 60, 60), touchLocation))
      self.player.mightAsWellJump = NO;
    if (CGRectContainsPoint(CGRectMake(70, 10, 60, 60), touchLocation))
      self.player.forwardMarch = YES;
    if (CGRectContainsPoint(CGRectMake(10, 10, 60, 60), touchLocation))
      self.player.backwardMarch = YES;
    if (CGRectContainsPoint(CGRectMake(500, 10, 60, 60), touchLocation))
      self.player.mightAsWellJump = YES;
  }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  
  for (UITouch *touch in touches) {
    CGPoint touchLocation = [touch locationInNode:self];
    if (CGRectContainsPoint(CGRectMake(10, 10, 60, 60), touchLocation) ||
        CGRectContainsPoint(CGRectMake(70, 10, 60, 60), touchLocation)) {
      self.player.backwardMarch = NO;
      self.player.forwardMarch = NO;
    }
    if (CGRectContainsPoint(CGRectMake(500, 10, 60, 60), touchLocation))
      self.player.mightAsWellJump = NO;
  }
}

- (void)setViewpointCenter:(CGPoint)position {
  NSInteger x = MAX(position.x, self.size.width / 2);
  NSInteger y = MAX(position.y, self.size.height / 2);
  x = MIN(x, (self.map.mapSize.width * self.map.tileSize.width) - self.size.width / 2);
  y = MIN(y, (self.map.mapSize.height * self.map.tileSize.height) - self.size.height / 2);
  CGPoint actualPosition = CGPointMake(x, y);
  CGPoint centerOfView = CGPointMake(self.size.width/2, self.size.height/2);
  CGPoint viewPoint = CGPointSubtract(centerOfView, actualPosition);
  self.map.position = viewPoint;
}

- (void)handleHazardCollisions:(Player *)player
{
  if (self.gameOver) return;
  NSInteger indices[8] = {7, 1, 3, 5, 0, 2, 6, 8};
  
  for (NSUInteger i = 0; i < 8; i++) {
    NSInteger tileIndex = indices[i];
    
    CGRect playerRect = [player collisionBoundingBox];
    CGPoint playerCoord = [self.hazards coordForPoint:player.desiredPosition];
    
    NSInteger tileColumn = tileIndex % 3;
    NSInteger tileRow = tileIndex / 3;
    CGPoint tileCoord = CGPointMake(playerCoord.x + (tileColumn - 1), playerCoord.y + (tileRow - 1));
    
    NSInteger gid = [self tileGIDAtTileCoord:tileCoord forLayer:self.hazards];
    if (gid != 0) {
      CGRect tileRect = [self tileRectFromTileCoords:tileCoord];
      if (CGRectIntersectsRect(playerRect, tileRect)) {
        [self gameOver:0];
      }
    }
  }
}

-(void)gameOver:(BOOL)won {
  self.gameOver = YES;
  [UIView animateWithDuration:0.1 animations:^() {
    self.view.alpha = 0.0;
  }];
  NSString *gameText;
  SKLabelNode *endGameLabel = [SKLabelNode labelNodeWithFontNamed:@"Marker Felt"];
  endGameLabel.text = gameText;
  endGameLabel.fontSize = 40;
  if (won) {
    gameText = @"You Won!";
    endGameLabel.color = [UIColor greenColor];
  } else {
    gameText = @"You Died!";
    endGameLabel.color = [UIColor redColor];
  }
  endGameLabel.position = CGPointMake(self.size.width / 2.0, self.size.height / 1.7);
  [self addChild:endGameLabel];
  [self performSelector:@selector(replay:) withObject:NULL afterDelay:.2];
}

- (void)replay:(id)sender
{
  [UIView animateWithDuration:0.2 animations:^() {
    self.view.alpha = 1.0;
  }];
  [self.view presentScene:[[GameLevelScene alloc] initWithSize:self.size]];
}

-(void)checkForWin {
  if (self.player.position.x > 3130.0) {
    [self gameOver:1];
  }
  if (self.player.position.y > 310) {
    self.player.position = CGPointMake(self.player.position.x, 310);
    self.player.velocity = CGPointMake(self.player.velocity.x, 0.0);
  }
}

@end
