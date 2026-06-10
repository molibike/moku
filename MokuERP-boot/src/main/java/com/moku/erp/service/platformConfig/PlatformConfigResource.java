package com.moku.erp.service.platformConfig;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2020-10-16 22:26:27
 */
@ResourceInfo(value = "platformConfig")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface PlatformConfigResource {
}
