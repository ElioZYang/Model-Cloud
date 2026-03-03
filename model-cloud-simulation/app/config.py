"""
应用配置
"""
from pydantic_settings import BaseSettings
from pydantic import field_validator
from typing import List
import os
import json


class Settings(BaseSettings):
    """应用配置类"""
    
    # 应用基础配置
    APP_NAME: str = "model-cloud-simulation"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"
    
    # 服务端口
    API_PORT: int = 8000
    API_HOST: str = "0.0.0.0"
    
    # Redis配置
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_HOST: str = "localhost"
    REDIS_PORT: int = 6379
    REDIS_DB: int = 0
    
    # OpenModelica配置
    OMC_PATH: str = "omc"
    OMC_WORK_DIR: str = "./runtime/modelica_simulations"
    
    # 文件存储配置
    TEMP_DIR: str = "./runtime/modelica_simulations"
    RESULT_DIR: str = "./runtime/modelica_results"
    CLEANUP_INTERVAL: int = 3600  # 清理间隔（秒）
    FILE_RETENTION_HOURS: int = 24  # 文件保留时间（小时）
    
    # 后端API配置
    BACKEND_API_URL: str = "http://localhost:8080/api"
    BACKEND_API_TIMEOUT: int = 30
    
    # 任务配置
    TASK_TIMEOUT: int = 3600  # 任务超时时间（秒）
    MAX_CONCURRENT_TASKS: int = 5  # 最大并发任务数
    
    # CORS配置（从环境变量读取，支持逗号分隔的字符串）
    CORS_ORIGINS: str = "http://localhost:5173,http://localhost:3000"
    
    @field_validator('CORS_ORIGINS', mode='before')
    @classmethod
    def parse_cors_origins(cls, v):
        """解析CORS_ORIGINS，支持字符串或列表，统一转换为字符串"""
        if v is None:
            return "http://localhost:5173,http://localhost:3000"
        # 如果pydantic-settings解析成了列表，转换为字符串
        if isinstance(v, list):
            return ','.join(str(origin) for origin in v)
        # 如果是字符串，直接返回
        if isinstance(v, str):
            return v
        # 其他情况返回默认值
        return "http://localhost:5173,http://localhost:3000"
    
    def get_cors_origins_list(self) -> List[str]:
        """获取CORS origins列表"""
        if isinstance(self.CORS_ORIGINS, str):
            try:
                # 尝试解析JSON格式
                parsed = json.loads(self.CORS_ORIGINS)
                if isinstance(parsed, list):
                    return parsed
            except:
                pass
            # 按逗号分隔字符串
            return [origin.strip() for origin in self.CORS_ORIGINS.split(',') if origin.strip()]
        # 如果已经是列表（不应该发生，但为了安全）
        if isinstance(self.CORS_ORIGINS, list):
            return self.CORS_ORIGINS
        return ["http://localhost:5173", "http://localhost:3000"]
    
    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True
        # 禁用自动JSON解析，避免CORS_ORIGINS被解析为列表
        json_schema_extra = {
            "CORS_ORIGINS": {
                "type": "string"
            }
        }


# 创建全局配置实例
settings = Settings()

# 确保目录存在
os.makedirs(settings.TEMP_DIR, exist_ok=True)
os.makedirs(settings.RESULT_DIR, exist_ok=True)
os.makedirs(settings.OMC_WORK_DIR, exist_ok=True)

