
// 登陆成功的通知
#define LKLoginSuccessedNotification @"LKLoginSuccessedNotification"
// 注销的通知
#define LKLogoutNotofication @"LKLogoutNotofication"
#import <Foundation/Foundation.h>

@interface LKNetTools : NSObject
/**
 *  全局的单例接口
 *
 *  @return 当前类
 */
+ (instancetype)sharedNetTools;

/**
 *  用户登录
 *
 *  @param failed 登录失败的回调
 */
- (void)userLoginWithFailed:(void (^)())failed;

/**
 *  用户名
 */
@property (nonatomic, copy) NSString *username;
/**
 *  密码
 */
@property (nonatomic, copy) NSString *password;
@end
