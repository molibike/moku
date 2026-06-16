package com.moku.erp.filter;

import com.moku.erp.service.redis.RedisService;
import org.springframework.util.StringUtils;

import javax.annotation.Resource;
import javax.servlet.*;
import javax.servlet.annotation.WebFilter;
import javax.servlet.annotation.WebInitParam;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(filterName = "LogCostFilter", urlPatterns = {"/*"},
        initParams = {@WebInitParam(name = "filterPath",
                      value = "/MokuERP-boot/user/login#/MokuERP-boot/user/weixinLogin#/MokuERP-boot/user/weixinBind#" +
                              "/MokuERP-boot/user/registerUser#/MokuERP-boot/user/randomImage#/MokuERP-boot/user/getUserBtnByCurrentUser#" +
                              "/MokuERP-boot/platformConfig/getPlatform#/MokuERP-boot/v2/api-docs#/MokuERP-boot/webjars#" +
                              "/MokuERP-boot/systemConfig/static#/MokuERP-boot/api/plugin/wechat/weChat/share#" +
                              "/MokuERP-boot/api/plugin/general-ledger/pdf/voucher#" +
                              "/api/user/login#/api/user/weixinLogin#/api/user/weixinBind#" +
                              "/api/user/registerUser#/api/user/randomImage#/api/user/getUserBtnByCurrentUser#" +
                              "/api/platformConfig/getPlatform#/api/v2/api-docs#/api/webjars#" +
                              "/api/systemConfig/static#/api/plugin/wechat/weChat/share#" +
                              "/api/plugin/general-ledger/pdf/voucher")})
public class LogCostFilter implements Filter {

    private static final String FILTER_PATH = "filterPath";

    private String[] allowUrls;
    @Resource
    private RedisService redisService;

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        String filterPath = filterConfig.getInitParameter(FILTER_PATH);
        if (!StringUtils.isEmpty(filterPath)) {
            allowUrls = filterPath.contains("#") ? filterPath.split("#") : new String[]{filterPath};
        }
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response,
                         FilterChain chain) throws IOException, ServletException {
        HttpServletRequest servletRequest = (HttpServletRequest) request;
        HttpServletResponse servletResponse = (HttpServletResponse) response;
        String requestUrl = servletRequest.getRequestURI();
        //具体，比如：处理若用户未登录，则跳转到登录页
        Object userId = redisService.getObjectFromSessionByKey(servletRequest,"userId");
        if(userId!=null) { //如果已登录，不阻止
            chain.doFilter(request, response);
            return;
        }
        if (requestUrl != null && (requestUrl.contains("/doc.html") ||
            requestUrl.contains("/user/login") || requestUrl.contains("/user/register") ||
            requestUrl.equals("/") || requestUrl.equals("/index.html") ||
            requestUrl.endsWith(".js") || requestUrl.endsWith(".css") ||
            requestUrl.endsWith(".png") || requestUrl.endsWith(".jpg") ||
            requestUrl.endsWith(".jpeg") || requestUrl.endsWith(".gif") ||
            requestUrl.endsWith(".ico") || requestUrl.endsWith(".woff") ||
            requestUrl.endsWith(".woff2") || requestUrl.endsWith(".ttf") ||
            requestUrl.endsWith(".eot") || requestUrl.endsWith(".svg"))) {
            chain.doFilter(request, response);
            return;
        }
        if (null != allowUrls && allowUrls.length > 0) {
            for (String url : allowUrls) {
                if (requestUrl.startsWith(url)) {
                    chain.doFilter(request, response);
                    return;
                }
                // 同时匹配不带 /MokuERP-boot 前缀的路径
                String shortUrl = url.replaceFirst("/MokuERP-boot", "");
                if (!shortUrl.equals(url) && requestUrl.startsWith(shortUrl)) {
                    chain.doFilter(request, response);
                    return;
                }
            }
        }
        servletResponse.setStatus(500);
        if(requestUrl != null && !requestUrl.contains("/user/logout") && !requestUrl.contains("/function/findMenuByPNumber")) {
            servletResponse.getWriter().write("loginOut");
        }
    }

    @Override
    public void destroy() {

    }
}