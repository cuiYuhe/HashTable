//
//  Person.h
//  HashMap
//
//  Created by cuiyuheMacAir on 2019/9/28.
//  Copyright © 2019年 qinger. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Person : NSObject

@property (nonatomic, assign) int age;
@property (nonatomic, assign) float height;
@property (nonatomic, copy) NSString *name;

+ (__kindof Person *)personWithAge:(int)age height:(CGFloat)height name:(NSString *)name;

@end


