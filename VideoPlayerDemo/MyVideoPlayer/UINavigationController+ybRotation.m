//
//  UINavigationController+ybRotation.m
//  VideoPlayerDemo
//
//  Created by 焦英博 on 2017/6/27.
//  Copyright © 2017年 焦英博. All rights reserved.
//

#import "UINavigationController+ybRotation.h"

@implementation UINavigationController (ybRotation)

- (BOOL)shouldAutorotate
{
    //在viewControllers中返回需要改变的viewController
    UIViewController *vc = nil;
    NSLog(@"%@",self.viewControllers);
    for (UIViewController *v in self.viewControllers) {
        if ([v isKindOfClass:NSClassFromString(@"LocalVideoController")]) {
            vc = v;
        }
    }
    return [[self.viewControllers lastObject] shouldAutorotate];
}

@end
