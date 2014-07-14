//
//  ApiDefine.h
//  weidian
//
//  Created by YoungShook on 14-1-20.
//  Copyright (c) 2014年 folse. All rights reserved.
//

#ifndef weidian_ApiDefine_h
#define weidian_ApiDefine_h

#define TEST FALSE

#if TEST
#define API_BASE_URL @"http://0.com"
#else
#define API_BASE_URL @"http://1.duapp.com"
#endif

#define API_LOGIN [NSString stringWithFormat:@"%@/qmm/wd/app/login",API_BASE_URL]

#define API_REG [NSString stringWithFormat:@"%@/qmm/wd/app/reg",API_BASE_URL]


#endif
