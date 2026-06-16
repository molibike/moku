package com.moku.erp.datasource.entities;

public class RoleEx extends Role{

    private String priceLimitStr;

    private String creatorName;

    public String getPriceLimitStr() {
        return priceLimitStr;
    }

    public void setPriceLimitStr(String priceLimitStr) {
        this.priceLimitStr = priceLimitStr;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }
}