//
//  BlockStrongReference.h
//  block底层
//
//  Created by Jane on 2017/6/26.
//  Copyright © 2017年 Jane. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 block 的强引用检测(release 模式下)
 
 @param block block
 @param check 变量
 @return 是否有强引用
 */
bool isBlockStrongReference(id block, id check);

#ifdef __cplusplus
}
#endif
