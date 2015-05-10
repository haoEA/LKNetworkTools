
#import "LKNetTools.h"
#import "NSString+Hash.h"
#import "SSKeychain.h"

@implementation LKNetTools

// 全局的单例接口
+ (instancetype)sharedNetTools
{
    static id obj;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        obj = [[self alloc] init];
    });
    
    return obj;
}

// 对象被初始化时
- (instancetype)init
{
    if(self = [super init])
    {
        // 初始化操作
        [self loadUserInfo];
    }
    return self;
}
// 用户登录
- (void)userLoginWithFailed:(void (^)())failed
{
    // 如果用户名或者密码为空 直接返回
    if(self.username.length == 0 || self.password.length == 0)
    {
            return;
    }
    
    // 登录的脚本
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/loginhmac.php"];
    
    // 请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // 设置请求体
    request.HTTPMethod = @"POST";
    
    // 把密码加密后，在发送给服务器
    NSString *pwd = [self timeEncrypt];
    
    //    NSLog(@"发送的密码是%@", pwd);
    NSString *bodyString = [NSString stringWithFormat:@"username=%@&password=%@", self.username, pwd];
    
    request.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];
    
    // 连接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError)
     {
         NSDictionary * result = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
         NSLog(@"响应%@", result);
         
         if([result[@"userId"] integerValue]> 0)
         {
             NSLog(@"登陆成功\n%d", [result[@"userId"] intValue]);
             [self saveUserInfo];
         
             // 登录成功 发送通知
             [[NSNotificationCenter defaultCenter] postNotificationName:LKLoginSuccessedNotification object:nil];
         }
         else
         {
             // 登录失败了 回调block
             if(failed)
                 failed();
         }
     }];
}

/// 时间戳加密
- (NSString *)timeEncrypt
{
    // 把key用MD5加密一次
    NSString *key = @"LK".md5String;
    
    // 做一次加密，(密码+MD5)HMAC
    NSString *pwd = [self.password hmacMD5StringWithKey:key];
    
    // 利用脚本获得服务器的时间
    NSURL *url = [NSURL URLWithString:@"http://127.0.0.1/hmackey.php"];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
    
    // 取出当前时间
    NSString *time = dict[@"key"];
    
    // 把当前时间拼接到密码后面
    pwd = [pwd stringByAppendingString:time];
    
    return [pwd hmacMD5StringWithKey:key];
}

// 加密的key
#define LKUserName @"LKUserName"
#define LKPwdName @"LKPwdName"
// 把用户名和密码保存到沙盒
- (void)saveUserInfo
{
    // 保存用户信息
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    [d setObject:self.username forKey:LKUserName];
    
    [d synchronize];
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;

    [SSKeychain setPassword:self.password forService:bundleId account:self.username];

}

// 加载沙盒中保存的数据
- (void)loadUserInfo
{
    // 加载用户信息
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    self.username = [d objectForKey:LKUserName];
    
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
   
    self.password = [SSKeychain passwordForService:bundleId account:self.username];
}
@end
