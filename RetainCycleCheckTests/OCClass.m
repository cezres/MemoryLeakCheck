//
//  OCClass.m
//  RetainCycleCheckTests
//
//  Created by 翟泉 on 2019/10/18.
//  Copyright © 2019 cezres. All rights reserved.
//

#import "OCClass.h"

@interface OCClass ()

@property (nonatomic, assign) int index;

@end

@implementation OCClass

- (instancetype)init {
    if (self = [super init]) {
        static int number = 0;
        self.index = ++number;
    }
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%p-%d", self, _index];
}

@end
