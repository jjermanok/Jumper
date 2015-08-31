#import "ViewController.h"
#import "MenuScene.h"

@implementation ViewController

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  SKView * skView = (SKView *)self.view;
  SKScene * scene = [MenuScene sceneWithSize:skView.bounds.size];
  scene.scaleMode = SKSceneScaleModeAspectFill;
  // Present the scene.
  [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
  return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
  return UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Release any cached data, images, etc that aren't in use.
}

@end
