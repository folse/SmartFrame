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
#define API_BASE_URL @"http://112.126.71.94"
#endif

#define API_LOGIN [NSString stringWithFormat:@"%@/smart/login.do",API_BASE_URL]

#define API_REG [NSString stringWithFormat:@"%@/smart/register.do",API_BASE_URL]


#endif
