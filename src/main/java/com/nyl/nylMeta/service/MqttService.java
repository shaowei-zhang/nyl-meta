package com.nyl.nylMeta.service;

public interface MqttService {
    /**
     * 发布主题
     */
    boolean publish(String topic, Object message);

    /**
     * 订阅主题
     */
    boolean sub(String topic);
}
