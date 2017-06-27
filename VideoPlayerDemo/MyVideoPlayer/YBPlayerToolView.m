//
//  YBPlayerToolView.m
//  VideoPlayerDemo
//
//  Created by 焦英博 on 2017/6/27.
//  Copyright © 2017年 焦英博. All rights reserved.
//

#import "YBPlayerToolView.h"

@implementation YBPlayerToolView

+ (instancetype)instanceView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass(self) owner:nil options:nil] firstObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self pv_resetUI];
}

- (void)pv_resetUI {
    [self.slider setThumbImage:[UIImage imageNamed:@"point"] forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[self pv_imageWithColor:[UIColor clearColor] size:CGSizeMake(300, 2)] forState:UIControlStateNormal];
    [self.progressView setProgressTintColor:[UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:.8]];
    [self.progressView setTrackTintColor:[UIColor whiteColor]];
}

- (UIImage *)pv_imageWithColor:(UIColor *)color size:(CGSize)size {
    @autoreleasepool {
        CGRect rect = CGRectMake(0, 0, size.width, size.height);
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, color.CGColor);
        CGContextFillRect(ctx, rect);
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"%@",NSStringFromCGRect(self.frame));
}

@end
