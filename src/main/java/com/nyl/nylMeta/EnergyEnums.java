package com.nyl.nylMeta;


import java.util.HashMap;
import java.util.Map;

public enum EnergyEnums {

    //    POWER_MODULE_TOTAL_GENERATED_ELECTRICITY("光伏三台逆变器总发电量", "guang_fu_san_tai_ni_bian_qi_zong_fa_dian_liang"),
//    POWER_MODULE_TOTAL_GENERATION("D12柜_光伏回路电表_正向电能", "d12ju_guang_fu_hui_lu_dian_biao_zheng_xiang_dian_neng"),
//    POWER_MODULE_TOTAL_ELECTRICITY_CONSUMPTION("交直流用电量", "jiao_zhi_liu_yong_dian_liang"),
// 101室1号照明面板（面板ID: 1081162416）
    SWITCH_PANEL1_LEFT("101室1号照明面板左键", "lumi_cn_1081162416_acn018_on_p_2_1"),
    SWITCH_PANEL1_MID("101室1号照明面板中键", "lumi_cn_1081162416_acn018_on_p_3_1"),
    SWITCH_PANEL1_RIGHT("101室1号照明面板右键", "lumi_cn_1081162416_acn018_on_p_4_1"),

    // 101室2号照明面板（面板ID: 1080161615）
    SWITCH_PANEL2_LEFT("101室2号照明面板左键", "lumi_cn_1080161615_acn018_on_p_2_1"),
    SWITCH_PANEL2_MID("101室2号照明面板中键", "lumi_cn_1080161615_acn018_on_p_3_1"),
    SWITCH_PANEL2_RIGHT("101室2号照明面板右键", "lumi_cn_1080161615_acn018_on_p_4_1");

    //101房间灯
    private final String description;

    private final String entityId;

    EnergyEnums(String description, String entityId) {

        this.description = description;
        this.entityId = entityId;
    }


    public String getDescription() {
        return description;
    }

    public String getEntityId() {
        return entityId;
    }

    public static Map<String, String> toMap() {
        Map<String, String> map = new HashMap<>();
        for (EnergyEnums energyEnum : EnergyEnums.values()) {
            map.put(energyEnum.getEntityId(), energyEnum.getDescription());
        }
        return map;
    }
}