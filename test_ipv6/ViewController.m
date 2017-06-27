//
//  ViewController.m
//  test_ipv6
//
//  Created by wangyuhong2267 on 17/6/26.
//  Copyright © 2017年 wangyuhong2267. All rights reserved.
//

#import "ViewController.h"
#import <arpa/inet.h>
#import <netdb.h>
#import "GCNetworkReachability.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	//[self createConnect];
	self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.google.com"];
	//self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.alipay.com"];
	//self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.baidu.com"];
	//self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.qq.com"];
	//self.reachability = [GCNetworkReachability reachabilityWithHostName:@"www.hb3344.com"];
	
	
//	[self.reachability startMonitoringNetworkReachabilityWithHandler:^(GCNetworkReachabilityStatus status) {
//		
//		// this block is called on the main thread
//		switch (status) {
//			case GCNetworkReachabilityStatusNotReachable:
//				NSLog(@"No connection");
//				break;
//			case GCNetworkReachabilityStatusWWAN:
//				//break;
//			case GCNetworkReachabilityStatusWiFi:
//				NSLog(@"have connection");
//				break;
//			default:
//				break;
//		}
//	}];
	//BOOL flag = [ViewController resolveHost:@"hb3344.com"];
	//BOOL flag = [ViewController resolveHost:@"www.google.com"];
	BOOL flag = [ViewController resolveHost:@"www.alipay.com"];
	if (flag) {
		NSLog(@"resolve success");
	}else{
		NSLog(@"resolve failure");
	}
	
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.
}

CFSocketRef  m_pSocket;
- (void)createConnect
{
	/////////////////***********************************/////////////////lb
	struct addrinfo hints, *res, *res0;
	int error, s;
	const char *cause =NULL;
	const char *ipv4_or_ipv6_str ="64:ff9b::122.152.205.226";//or IPv6 address string is well /ip地址
	//       const char *ipv4_or_ipv6_str = "http://www.i-things.cn";
	NSUInteger port =7890;//port of connecting server/端口号
	memset(&hints,0,sizeof(hints));//分配一个hints结构体，把它清零后填写需要的字段，再调用getaddrinfo，然后遍历一个链表逐个尝试每个返回地址。
	
	hints.ai_family = PF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = AI_DEFAULT;
	
	
	error = getaddrinfo(ipv4_or_ipv6_str, NULL, &hints, &res0);//函数的返回值：成功返回0，失败返回非零的 sockets error code
	
	if (error)//非零则失败
	{
		//errx(1,"%s",gai_strerror(error));
		/*NOTREACHED*/
		NSLog(@"非零则失败");
	}
	s = -1;
	for (res = res0; res; res = res->ai_next)
	{
//		s = socket(res->ai_family,
//				   res->ai_socktype,
//				   res->ai_protocol);//返回值：非负描述符成功,返回一个新的套接字描述，出错返回-1
//		
//		close(s);/////////////很关键,释放占用的socket描述//////////
//		NSLog(@"ssssssss%d",s);
		//socket上下文
		CFSocketContext sockContext = {0,
			CFBridgingRetain(self),
			NULL,
			NULL,
			NULL};
		
		//创建socket
		m_pSocket =CFSocketCreate(kCFAllocatorDefault,
								  res->ai_family,//AF_UNSPEC不限,PF_INET,PF_INET6
								  res->ai_socktype,
								  res->ai_protocol,
								  kCFSocketConnectCallBack,
								  kCFSocketNoCallBack,  //连接后的回调函数
								  &sockContext
								  );
		
//		if (s < 0)
//		{
//			cause = "socket";
//			continue;
//		}
		
		switch(res->ai_addr->sa_family)//是IPV4还是IPV6
		{
			case AF_INET://IPV4
			{
				struct sockaddr_in *v4sa = (struct sockaddr_in *)res->ai_addr;
				v4sa->sin_port = htons(port);
				CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&v4sa,sizeof(v4sa));
				
				// 建立连接
				CFSocketConnectToAddress(m_pSocket,
										 address,
										 -1     //超时
										 );
				
				CFRunLoopRef cRunRef = CFRunLoopGetCurrent();
				
				CFRunLoopSourceRef sourceRef =CFSocketCreateRunLoopSource(kCFAllocatorDefault,m_pSocket,0);
				CFRunLoopAddSource(cRunRef,
								   sourceRef,
								   kCFRunLoopCommonModes
								   );
				CFRelease(sourceRef);
				CFRelease(address);
				NSLog(@"连接成功1");
				
			}
				break;
			case AF_INET6://IPV6
			{
				
				struct sockaddr_in6 *v6sa = (struct sockaddr_in6 *)res->ai_addr;
				v6sa->sin6_port = htons(port);
				
				CFDataRef address6 = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&v6sa,sizeof(v6sa));
				//建立连接IPV6
				CFSocketConnectToAddress(m_pSocket,
										 address6,
										 -1
										 );
				
				CFRunLoopRef cRunRef = CFRunLoopGetCurrent();
				
				CFRunLoopSourceRef sourceRef =CFSocketCreateRunLoopSource(kCFAllocatorDefault,m_pSocket,0);
				CFRunLoopAddSource(cRunRef,
								   sourceRef,
								   kCFRunLoopCommonModes
								   );
				CFRelease(sourceRef);
				CFRelease(address6);
				NSLog(@"连接成功2");
				
				
			}
				break;
		}
		
		
		
		break; /* okay we got one *///连接成功就跳出循环
	}
	if (s <0)//socket描述失败
	{
		//err(1,"%s", cause);
		/*NOTREACHED*/
		NSLog(@"描述失败connected");
	}
	else//socket描述成功
	{
		printf("描述成功connected");
		
	}
	
	freeaddrinfo(res);

}

+(BOOL)resolveHost:(NSString*)hostname

{
	
	Boolean result;
	
	CFHostRef hostRef;
	
	CFArrayRef addresses;
	
	NSString*ipAddress =nil;
	
	hostRef =CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
	NSLog(@"resolve hostRef=%@",hostRef);
	if(hostRef) {
		
		result =CFHostStartInfoResolution(hostRef,kCFHostAddresses,NULL);// pass an error instead of NULL here to find out why it failed
		NSLog(@"resolve result=%d",result);
		if(result) {
			
			addresses =CFHostGetAddressing(hostRef, &result);
			
		}
		
	}
	
	if(result) {
		
		CFIndex index =0;
		
		CFDataRef ref = (CFDataRef)CFArrayGetValueAtIndex(addresses, index);
		
		int port=0;
		
		struct sockaddr*addressGeneric;
		
		NSData*myData = (__bridge NSData*)ref;
		
		addressGeneric = (struct sockaddr*)[myData bytes];
		
		switch(addressGeneric->sa_family) {
				
			case AF_INET: {
				
				struct sockaddr_in*ip4;
				
				char dest[INET_ADDRSTRLEN];
				
				ip4 = (struct sockaddr_in*)[myData bytes];
				
				port =ntohs(ip4->sin_port);
				
				ipAddress = [NSString stringWithFormat:@"%s",inet_ntop(AF_INET, &ip4->sin_addr, dest,sizeof dest)];
				NSLog(@"resolve AF_INET,ipAddress=%@",ipAddress);
			}
				
				break;
				
			case AF_INET6: {
				//NSLog(@"resolve AF_INET6");
				struct sockaddr_in6*ip6;
				
				char dest[INET6_ADDRSTRLEN];
				
				ip6 = (struct sockaddr_in6*)[myData bytes];
				
				port =ntohs(ip6->sin6_port);
				
				ipAddress = [NSString stringWithFormat:@"%s",inet_ntop(AF_INET6, &ip6->sin6_addr, dest,sizeof dest)];
				NSLog(@"resolve AF_INET6,ipAddress=%@",ipAddress);
			}
				
				break;
				
			default:
				
				ipAddress =nil;
				NSLog(@"resolve NO NET TYPE");
				break;
				
		}
		
	}
	
	if(ipAddress) {
		
		return YES;
		
	}else{
		
		return NO;
		
	}
	
}

@end
