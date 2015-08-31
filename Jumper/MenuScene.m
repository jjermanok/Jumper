//
//  MenuScene.m
//  Jumper
//
//  Created by Jake Jermanok on 5/9/15.
//

#import "MenuScene.h"
#import "GameLevelScene.h"

@interface MenuScene() {
    SKLabelNode *startButton;
}

@end

@implementation MenuScene

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor colorWithRed:.4 green:.4 blue:.95 alpha:1.0];
        SKLabelNode *jumpsLabel = [SKLabelNode labelNodeWithFontNamed:@"Trebuchet MS"];
        jumpsLabel.fontColor = [UIColor blackColor];
        jumpsLabel.fontSize = 40;
        jumpsLabel.text = @"Jumper";
        jumpsLabel.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * .6);
        [self addChild: jumpsLabel];
        startButton = [[SKLabelNode alloc]init];
        startButton.text = @"start";
        startButton.fontColor = [UIColor blackColor];
        startButton.fontSize = 40;
        startButton.position = CGPointMake(self.frame.size.width/2, self.frame.size.height * .3);
        [self addChild: startButton];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInNode:self];
        if (CGRectContainsPoint(startButton.frame, touchLocation)) {
            [UIView animateWithDuration:0.2 animations:^() {
                self.view.alpha = 0.0;
            [self performSelector:@selector(start:) withObject:NULL afterDelay:.2];
            }];
        }
    }
}

-(void)start:(id)sender
{
    UIImageView *leftButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Left Button.png"]];
    leftButton.frame = CGRectMake(10, 250, 60, 60);
    UIImageView *rightButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"RightButton.png"]];
    rightButton.frame = CGRectMake(70, 250, 60, 60);
    UIImageView *upButton =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Up Button.png"]];
    upButton.frame = CGRectMake(500, 250, 60, 60);
    UIImageView *restartButton = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"restart.png"]];
    restartButton.frame = CGRectMake(515, 15, 30, 30);
    // Configure the view.
    SKView * skView = (SKView *)self.view;
    [skView addSubview:leftButton];
    [skView addSubview:rightButton];
    [skView addSubview:upButton];
    [skView addSubview:restartButton];
    // Create and configure the scene.
    SKScene * scene = [GameLevelScene sceneWithSize:skView.bounds.size];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    [UIView animateWithDuration:0.2 animations:^() {
        self.view.alpha = 1.0;
    }];
    [skView presentScene:scene];
}

@end
