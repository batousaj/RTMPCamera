//
//  ViewController.m
//  RTMPLiveStreaming
//
//  Created by Mac Mini 2021_1 on 24/07/2023.
//

#import "ViewController.h"
#import "LFLivePreview.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
     [self.view addSubview:[[LFLivePreview alloc] initWithFrame:self.view.bounds]];
}

//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskLandscape;
//}
//
//- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
//    return YES;
//}

@end
