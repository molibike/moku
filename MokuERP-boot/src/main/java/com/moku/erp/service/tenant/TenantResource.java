package com.moku.erp.service.tenant;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2019-6-27 22:56:56
 */
@ResourceInfo(value = "tenant")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface TenantResource {
}
