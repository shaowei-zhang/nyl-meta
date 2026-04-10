package com.nyl.nylMeta.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.nyl.nylMeta.service.MqttService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 设备管理控制器
 * 提供设备查询和控制接口
 */
@RestController
@RequestMapping("/api/device")
public class DeviceController {
    @Autowired
    private MqttService mqttService;
    private final ObjectMapper objectMapper = new ObjectMapper();

    // ==================== 设备查询 ====================

    /**
     * 根据房间号查询设备列表（原有功能，路径调整为 /{roomNumber}）
     *
     * @param roomNumber 房间号，如 "101"
     * @return 该房间下的所有设备列表，按类别分组
     */
    @GetMapping("/{roomNumber}")
    public Map<String, Object> getDevicesByRoom(@PathVariable String roomNumber) {
        Map<String, Object> result = new HashMap<>();

        try {
            ClassPathResource resource = new ClassPathResource("device.json");
            JsonNode rootNode = objectMapper.readTree(resource.getInputStream());

            JsonNode roomNode = rootNode.get(roomNumber);
            if (roomNode == null) {
                result.put("code", 404);
                result.put("message", "房间号不存在: " + roomNumber);
                result.put("data", null);
                return result;
            }

            Map<String, List<Map<String, String>>> devicesByCategory = new HashMap<>();

            roomNode.fields().forEachRemaining(categoryEntry -> {
                String category = categoryEntry.getKey();
                JsonNode devicesNode = categoryEntry.getValue();
                List<Map<String, String>> deviceList = new ArrayList<>();

                devicesNode.fields().forEachRemaining(deviceEntry -> {
                    Map<String, String> device = new HashMap<>();
                    device.put("name", deviceEntry.getKey());
                    device.put("entityId", deviceEntry.getValue().asText());
                    deviceList.add(device);
                });

                devicesByCategory.put(category, deviceList);
            });

            result.put("code", 200);
            result.put("message", "查询成功");
            result.put("data", devicesByCategory);

        } catch (IOException e) {
            result.put("code", 500);
            result.put("message", "读取设备数据失败: " + e.getMessage());
            result.put("data", null);
        }

        return result;
    }

    /**
     * 获取所有房间列表
     *
     * @return 所有房间号列表
     */
    @GetMapping("/rooms")
    public Map<String, Object> getAllRooms() {
        Map<String, Object> result = new HashMap<>();

        try {
            ClassPathResource resource = new ClassPathResource("device.json");
            JsonNode rootNode = objectMapper.readTree(resource.getInputStream());

            List<String> rooms = new ArrayList<>();
            rootNode.fieldNames().forEachRemaining(rooms::add);

            result.put("code", 200);
            result.put("message", "查询成功");
            result.put("data", rooms);

        } catch (IOException e) {
            result.put("code", 500);
            result.put("message", "读取设备数据失败: " + e.getMessage());
            result.put("data", null);
        }

        return result;
    }

    // ==================== 设备控制 ====================

    /**
     * 控制灯光
     *
     * @param roomNumber 房间号
     * @param state      状态 ON/OFF
     * @return 包含 ctrlList 的控制结果
     */
    @GetMapping("/light/state")
    public Map<String, Object> controlLight(@RequestParam String roomNumber, @RequestParam String state) {
        Map<String, Object> result = new HashMap<>();
        try {
            // 1. 读取 device.json
            ClassPathResource resource = new ClassPathResource("device.json");
            JsonNode rootNode = objectMapper.readTree(resource.getInputStream());

            List<Map<String, Object>> ctrlList = new ArrayList<>();

            // 2. 判断是否为全部房间
            if ("all".equalsIgnoreCase(roomNumber)) {
                // 遍历所有房间
                rootNode.fields().forEachRemaining(roomEntry -> {
                    JsonNode roomNode = roomEntry.getValue();
                    JsonNode lightNode = roomNode.get("灯光");
                    if (lightNode != null && !lightNode.isEmpty()) {
                        lightNode.fields().forEachRemaining(deviceEntry -> {
                            String entityId = deviceEntry.getValue().asText();
                            Map<String, Object> ctrl = new HashMap<>();
                            ctrl.put("entityId", "switch." + entityId);
                            ctrl.put("type", "switch");
                            ctrl.put("ctrlPoint", "state");
                            ctrl.put("value", state);
                            ctrlList.add(ctrl);
                        });
                    }
                });
                if (ctrlList.isEmpty()) {
                    result.put("code", 404);
                    result.put("message", "没有找到任何灯光设备");
                    return result;
                }
            } else {
                // 3. 单房间逻辑
                JsonNode roomNode = rootNode.get(roomNumber);
                if (roomNode == null) {
                    result.put("code", 404);
                    result.put("message", "房间号不存在: " + roomNumber);
                    return result;
                }
                JsonNode lightNode = roomNode.get("灯光");
                if (lightNode == null || lightNode.isEmpty()) {
                    result.put("code", 404);
                    result.put("message", "房间 " + roomNumber + " 没有灯光设备");
                    return result;
                }
                lightNode.fields().forEachRemaining(entry -> {
                    String entityId = entry.getValue().asText();
                    Map<String, Object> ctrl = new HashMap<>();
                    ctrl.put("entityId", "switch." + entityId);
                    ctrl.put("type", "switch");
                    ctrl.put("ctrlPoint", "state");
                    ctrl.put("value", state);
                    ctrlList.add(ctrl);
                });
            }

            // 4. 下发 MQTT 控制指令
            for (Map<String, Object> ctrl : ctrlList) {
                mqttService.publish("device/ctrl", ctrl);
            }

            // 5. 返回成功结果
            String message = "all".equalsIgnoreCase(roomNumber) ?
                    String.format("所有房间灯光已%s", "ON".equalsIgnoreCase(state) ? "开启" : "关闭") :
                    String.format("房间 %s 灯光已%s", roomNumber, "ON".equalsIgnoreCase(state) ? "开启" : "关闭");
            result.put("code", 200);
            result.put("message", message);
            result.put("data", ctrlList);

        } catch (IOException e) {
            result.put("code", 500);
            result.put("message", "读取设备数据失败: " + e.getMessage());
        }
        return result;
    }
}