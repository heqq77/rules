[rewrite_local]

^https:\/\/spclient\.wg\.spotify\.com\/(bootstrap\/v1\/bootstrap|user-customization-service\/v1\/customize)$ url script-response-body https://raw.githubusercontent.com/app2smile/rules/master/js/spotify-proto.js
^https:\/\/spclient\.wg\.spotify\.com\/(artistview\/v1\/artist|album-entity-view\/v2\/album)\/ url script-request-header https://raw.githubusercontent.com/app2smile/rules/master/js/spotify-json.js
  
^https?:\/\/((h5|api)\.xiuxiu|api-sub|api\.posters)\.meitu\.com\/.+\/(vip|user|h\d|center|home) url script-response-body https://raw.githubusercontent.com/chxm1023/Rewrite/main/mtxx.js

^https:\/\/.*\.(intsig\.net|camscanner\.com) url script-response-body https://raw.githubusercontent.com/chxm1023/Rewrite/main/CamScanner.js

^https?:\/\/api\.(aliyundrive|alipan)\.com\/business\/v1\.1\/users\/me\/vip\/info url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/member\.(aliyundrive|alipan)\.com\/v1\/users\/tools url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/member\.(aliyundrive|alipan)\.com\/v1\/users\/me url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/api\.(aliyundrive|alipan)\.com\/business\/v1\.0\/users\/vip\/info url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/api\.(aliyundrive|alipan)\.com\/business\/v1\.0\/users\/feature\/list url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/api\.(aliyundrive|alipan)\.com\/apps\/v2\/users\/home\/widgets url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/member\.(aliyundrive|alipan)\.com\/v1\/users\/onboard_list url reject
^https?:\/\/user\.(aliyundrive|alipan)\.com\/v2\/user\/get url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js
^https?:\/\/api\.(aliyundrive|alipan)\.com\/adrive\/v2\/backup\/device url reject
^https?:\/\/member\.(aliyundrive|alipan)\.com\/v2\/activity\/sign_in_info url script-response-body https://gist.githubusercontent.com/ddgksf2013/f4752e632fd3375ea2811985c5b635dc/raw/alicloud.js

# > 百度网盘_开屏广告@ddgksf2013
^https?:\/\/pan\.baidu\.com\/api\/getsyscfg url script-response-body https://gist.githubusercontent.com/ddgksf2013/f43026707830c7818ee3ba624e383c8d/raw/baiduCloud.vip.js
# > 百度网盘_设置信息流@ddgksf2013
^https?:\/\/pan\.baidu\.com\/act\/v\d\/(bchannel|welfare)\/list url reject-200
# > 百度网盘_通用广告@ddgksf2013
^https?:\/\/pan\.baidu\.com\/rest\/.*\/pcs\/ad url reject-200
# > 百度网盘_活动推广@ddgksf2013
^https?:\/\/pan\.baidu\.com\/act\/api\/activityentry url reject-200
# > 百度网盘_会员权益@ddgksf2013
^https:\/\/pan\.baidu\.com\/rest\/.*\/membership\/user\?app_id url script-response-body https://gist.githubusercontent.com/ddgksf2013/f43026707830c7818ee3ba624e383c8d/raw/baiduCloud.vip.js

^https?:\/\/(api-\w+|xiaoshuo)\.wtzw\.com\/api\/v\d\/ url script-response-body https://raw.githubusercontent.com/I-am-R-E/QuantumultX/main/JavaScript/QiMaoXiaoShuo.js

https://xluser-ssl.xunlei.com/xluser.core.login/v3/getuserinfo url script-response-body https://raw.githubusercontent.com/Marol62926/MarScrpt/main/xunlei.js

^https?:\/\/translator\.felo\.me\/api\/plan\/current url script-response-body https://raw.githubusercontent.com/chxm1023/Rewrite/main/Felo.js

^https?:\/\/baimiao\.uzero\.cn\/api\/.+\/(appLaunchWithUser|getAnnouncement|checkLoginClient) url script-response-body https://raw.githubusercontent.com/chxm1023/Rewrite/main/baimiao.js

^https:\/\/mobile-stream\.api\.mgtv\.com\/v1\/video\/source\? url script-request-header https://raw.githubusercontent.com/Yu9191/Rewrite/main/MGTV.js
^http:\/\/[\d\.]+:\d{5}\/\?cmd=indexes url reject
^http:\/\/[\d\.]+\/odin\/c1\/(channel\/ads|skin\/config)\? url reject-dict
^https:\/\/damang\.api\.mgtv\.com\/station\/album\/red\/dot\? url reject-dict
^https:\/\/hb-boom\.api\.mgtv\.com\/release\/pullReleaseInfo url reject-dict
^https:\/\/me\.bz\.mgtv\.com\/v3\/module\/list\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^http:\/\/mob-st\.bz\.mgtv\.com\/odin\/c1\/channel\/index\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^https?:\/\/dc2?\.bz\.mgtv\.com\/dynamic\/v1\/channel\/(index|vrsList)\/\w url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^https:\/\/mobile\.api\.mgtv\.com\/mobile\/config\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^https:\/\/mobile\.api\.mgtv\.com\/v2\/mobile\/checkUpdate\? url reject-dict
^http:\/\/mobile-thor\.api\.mgtv\.com\/v1\/vod\/cms\/list\? url reject-dict
^https:\/\/mobile\.api\.mgtv\.com\/v10\/video\/info\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^https:\/\/mobile-thor\.api\.mgtv\.com\/v1\/vod\/info\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js
^http:\/\/mobileso\.bz\.mgtv\.com\/spotlight\/search\/v1\? url reject-dict
^https?:\/\/mobileso\.bz\.mgtv\.com\/mobile\/recommend\/v2\? url script-response-body https://raw.githubusercontent.com/RuCu6/QuanX/main/Scripts/cnftp.js

^https?:\/\/(biz|wrapper|starplucker)\.(cyapi|caiyunapp)\.(cn|com)\/(.+\/(user\?app_name|activity\?app_name|visitors|operation\/banners|operation\/homefeatures|config)|p\/v\d\/(vip_info|user_info|entries|privileges|trial_card\/info)) url script-response-body https://raw.githubusercontent.com/chxm1023/Rewrite/main/caiyuntianqi.js
^https?:\/\/(api|wrapper)\.(cyapi|caiyunapp)\.(cn|com)\/v\d\/(satellite|nafp\/origin_images) url script-request-header https://raw.githubusercontent.com/chxm1023/Rewrite/main/caiyuntianqi.js






  
[mitm]
hostname = spclient.wg.spotify.com, *.xiuxiu.meitu.com, api.posters.meitu.com, api-sub.meitu.com, *.camscanner.com, *.intsig.net, api.alipan.com, member.aliyundrive.com, member.alipan.com, api.aliyundrive.com, pan.baidu.com, *.wtzw.com, xluser-ssl.xunlei.com, translator.felo.me, baimiao.uzero.cn, *.mgtv.com, *.cyapi.cn, *.caiyunapp.com
