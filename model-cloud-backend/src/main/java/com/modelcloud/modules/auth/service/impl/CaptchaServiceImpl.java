package com.modelcloud.modules.auth.service.impl;

import com.modelcloud.modules.auth.service.CaptchaService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import javax.imageio.ImageIO;
import java.awt.*;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;
import java.util.concurrent.TimeUnit;

/**
 * 验证码服务实现类
 * 
 * @author model-cloud
 */
@Slf4j
@Service
public class CaptchaServiceImpl implements CaptchaService {
    
    private final StringRedisTemplate redisTemplate;
    private static final String CAPTCHA_PREFIX = "captcha:";
    private static final int CAPTCHA_EXPIRE_MINUTES = 5;
    private static final int CAPTCHA_WIDTH = 100;
    private static final int CAPTCHA_HEIGHT = 40;
    private static final int CAPTCHA_LENGTH = 4;
    
    public CaptchaServiceImpl(StringRedisTemplate redisTemplate) {
        this.redisTemplate = redisTemplate;
    }
    
    @Override
    public Map<String, String> generateCaptcha() {
        // 生成验证码key
        String key = generateKey();
        
        // 生成验证码
        String code = generateCode();
        
        // 存储到Redis，5分钟过期
        redisTemplate.opsForValue().set(
            CAPTCHA_PREFIX + key, 
            code.toLowerCase(), 
            CAPTCHA_EXPIRE_MINUTES, 
            TimeUnit.MINUTES
        );
        
        // 生成验证码图片
        String imageBase64 = generateImage(code);
        
        Map<String, String> result = new HashMap<>();
        result.put("key", key);
        result.put("image", imageBase64);
        
        return result;
    }
    
    @Override
    public boolean validateCaptcha(String key, String code) {
        if (key == null || code == null) {
            return false;
        }
        
        String storedCode = redisTemplate.opsForValue().get(CAPTCHA_PREFIX + key);
        if (storedCode == null) {
            return false;
        }
        
        // 验证后删除验证码
        redisTemplate.delete(CAPTCHA_PREFIX + key);
        
        return storedCode.equalsIgnoreCase(code);
    }
    
    /**
     * 生成验证码key
     */
    private String generateKey() {
        return System.currentTimeMillis() + "_" + new Random().nextInt(10000);
    }
    
    /**
     * 生成验证码字符串
     */
    private String generateCode() {
        String chars = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"; // 排除容易混淆的字符
        Random random = new Random();
        StringBuilder code = new StringBuilder();
        for (int i = 0; i < CAPTCHA_LENGTH; i++) {
            code.append(chars.charAt(random.nextInt(chars.length())));
        }
        return code.toString();
    }
    
    /**
     * 生成验证码图片
     */
    private String generateImage(String code) {
        BufferedImage image = new BufferedImage(CAPTCHA_WIDTH, CAPTCHA_HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        
        // 设置抗锯齿
        g.setRenderingHint(RenderingHints.KEY_ANTIALIASING, RenderingHints.VALUE_ANTIALIAS_ON);
        
        // 填充背景
        g.setColor(Color.WHITE);
        g.fillRect(0, 0, CAPTCHA_WIDTH, CAPTCHA_HEIGHT);
        
        // 绘制干扰线
        Random random = new Random();
        g.setColor(Color.LIGHT_GRAY);
        for (int i = 0; i < 5; i++) {
            int x1 = random.nextInt(CAPTCHA_WIDTH);
            int y1 = random.nextInt(CAPTCHA_HEIGHT);
            int x2 = random.nextInt(CAPTCHA_WIDTH);
            int y2 = random.nextInt(CAPTCHA_HEIGHT);
            g.drawLine(x1, y1, x2, y2);
        }
        
        // 绘制验证码
        g.setFont(new Font("Arial", Font.BOLD, 28));
        for (int i = 0; i < code.length(); i++) {
            g.setColor(new Color(random.nextInt(100), random.nextInt(100), random.nextInt(100)));
            int x = 20 + i * 20;
            int y = 28 + random.nextInt(5);
            g.drawString(String.valueOf(code.charAt(i)), x, y);
        }
        
        g.dispose();
        
        // 转换为Base64
        try {
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            ImageIO.write(image, "png", baos);
            byte[] imageBytes = baos.toByteArray();
            return Base64.getEncoder().encodeToString(imageBytes);
        } catch (IOException e) {
            log.error("生成验证码图片失败", e);
            return "";
        }
    }
}



