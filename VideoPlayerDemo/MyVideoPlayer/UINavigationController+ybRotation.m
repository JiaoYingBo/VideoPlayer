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
    // 需要改变的viewController需要重写shouldAutorotate
    return [[self.viewControllers lastObject] shouldAutorotate];
}

@end
