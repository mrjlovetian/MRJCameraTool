//
//  MRJViewController.m
//  MRJCameraTool
//
//  Created by mrjlovetian@gmail.com on 09/18/2017.
//  Copyright (c) 2017 mrjlovetian@gmail.com. All rights reserved.
//

#import "MRJViewController.h"
#import <MRJCameraTool/MRJCameraTool.h>

@interface MRJViewController ()

@end

@implementation MRJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(60, 60, 60, 60);
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(Click) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)Click{
    [MRJCameraTool cameraAtView:self imageWidth:320 maxNum:6 success:^(NSArray *images) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
