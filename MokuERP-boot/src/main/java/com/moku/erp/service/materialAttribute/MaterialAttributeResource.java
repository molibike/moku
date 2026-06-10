package com.moku.erp.service.materialAttribute;

import com.moku.erp.service.ResourceInfo;

import java.lang.annotation.*;

/**
 * @author jishenghua 2021-07-21 22:26:27
 */
@ResourceInfo(value = "materialAttribute")
@Inherited
@Target(ElementType.TYPE)
@Retention(RetentionPolicy.RUNTIME)
public @interface MaterialAttributeResource {
}
