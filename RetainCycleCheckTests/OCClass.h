//
//  OCClass.h
//  RetainCycleCheckTests
//
//  Created by 翟泉 on 2019/10/18.
//  Copyright © 2019 cezres. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCClass : NSObject

@property (nonatomic, strong) id strongValue1;
@property (nonatomic, strong) id strongValue2;
@property (nonatomic, strong) id strongValue3;
@property (nonatomic, weak) id weakValue1;
@property (nonatomic, weak) id weakValue2;

@end

NS_ASSUME_NONNULL_END
