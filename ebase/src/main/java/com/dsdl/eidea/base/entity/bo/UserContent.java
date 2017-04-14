package com.dsdl.eidea.base.entity.bo;

import lombok.Getter;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Created by 刘大磊 on 2016/12/26 16:45.
 */
@Getter
public class UserContent implements java.io.Serializable{
    private Map<String, List<String>> privileges = new HashMap<>();
    private List<Integer> orgIdList;

    /**
     * token 串
     */
    private String token;
    public UserContent(Map<String, List<String>> privileges, String token,List<Integer> orgIdList) {
        this.privileges = privileges;
            this.token = token;
        this.orgIdList=orgIdList;
    }


}
