//
//  ApiDefine.h
//  weidian
//
//  Created by YoungShook on 14-1-20.
//  Copyright (c) 2014年 folse. All rights reserved.
//

#ifndef weidian_ApiDefine_h
#define weidian_ApiDefine_h

#define TEST TRUE

#if TEST
#define API_BASE_URL @"http://202.112.114.13:9999"
#else
#define API_BASE_URL @"http://112.126.71.94:8080"
#endif

//登录
#define API_LOGIN [NSString stringWithFormat:@"%@/smart/login.do",API_BASE_URL]

//注册
#define API_REG [NSString stringWithFormat:@"%@/smart/register.do",API_BASE_URL]

//上传文件
#define API_UPLOAD [NSString stringWithFormat:@"%@/smart/upload.do",API_BASE_URL]

//获取绑定关系
#define API_RELATION [NSString stringWithFormat:@"%@/smart/relations.do",API_BASE_URL]

//上传照片和声音
#define API_SEND_PHOTO_VOICE [NSString stringWithFormat:@"%@/smart/upload_header.do",API_BASE_URL]

//用户信息
#define API_USER [NSString stringWithFormat:@"%@/smart/user.do",API_BASE_URL]

//管理照片
#define API_MANAGE_PHOTO [NSString stringWithFormat:@"%@/smart/manage.do",API_BASE_URL]

//管理账户
#define API_MANAGE_ACCOUNT [NSString stringWithFormat:@"%@/smart/account.do",API_BASE_URL]

//解除绑定
#define API_DELETE_RELATION [NSString stringWithFormat:@"%@/smart/relieve.do",API_BASE_URL]

//意见反馈
#define API_FEEDBACK [NSString stringWithFormat:@"%@/smart/feedback.do",API_BASE_URL]

#endif
