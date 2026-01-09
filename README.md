# Model Cloud - 模型管理系统

## 项目简介

Model Cloud 是一个前后端分离的模型管理系统，用于管理、发布和分发各类模型资源。

## 技术架构

### 后端技术栈
- **框架**: Spring Boot 3.2.0
- **安全**: Spring Security + JWT
- **ORM**: MyBatis-Flex
- **数据库**: MySQL 8.0+
- **NoSQL**: MongoDB
- **缓存**: Redis
- **版本控制**: Gitea API
- **构建工具**: Maven

### 前端技术栈
- **框架**: Vue 3
- **语言**: TypeScript
- **构建工具**: Vite
- **路由**: Vue Router 4
- **状态管理**: Pinia
- **UI框架**: Element Plus
- **HTTP客户端**: Axios


## 功能模块

### 业务模块 (business)
- 模型管理（增删改查、审核、发布）
- 模型分类管理
- 模型标签管理
- 模型收藏
- 模型参数管理（MongoDB）
- 模型模板管理（MongoDB）
- Gitea集成

### 系统模块 (sys)
- 用户管理
- 角色管理
- 权限管理
- 文件管理
- 日志管理
- 系统监控

### 认证模块 (auth)
- 用户登录/登出
- JWT Token管理
- 验证码
- 权限验证

## 开发指南

### 环境要求
- JDK 17+
- Node.js 18+
- MySQL 8.0+
- MongoDB 6.0+
- Redis 6.0+

### 后端启动
```bash
cd model-cloud-backend
mvn clean install
mvn spring-boot:run
```

### 前端启动
```bash
cd model-cloud-frontend
npm install
npm run dev
```


## 许可证

待定



## 项目结构（缩略版）

```
model-cloud
├─ 📁model-cloud-backend
│  ├─ 📁src
│  │  └─ 📁main
│  │     ├─ 📁java
│  │     │  └─ 📁com
│  │     │     └─ 📁modelcloud
│  │     │        ├─ 📁common
│  │     │        │  ├─ 📁config
│  │     │        │  │  ├─ 📄GiteaConfig.java
│  │     │        │  │  ├─ 📄MybatisConfig.java
│  │     │        │  │  ├─ 📄SecurityConfig.java
│  │     │        │  │  ├─ 📄SecurityUtilsConfig.java
│  │     │        │  │  └─ 📄WebConfig.java
│  │     │        │  ├─ 📁constant
│  │     │        │  │  └─ 📄CommonConstant.java
│  │     │        │  ├─ 📁exception
│  │     │        │  │  ├─ 📄BusinessException.java
│  │     │        │  │  └─ 📄GlobalExceptionHandler.java
│  │     │        │  ├─ 📁security
│  │     │        │  │  └─ 📄JwtAuthenticationFilter.java
│  │     │        │  ├─ 📁tools
│  │     │        │  │  ├─ 📄JwtUtil.java
│  │     │        │  │  ├─ 📄PasswordUtil.java
│  │     │        │  │  └─ 📄SecurityUtils.java
│  │     │        │  └─ 📁web
│  │     │        │     └─ 📁domain
│  │     │        │        ├─ 📁request
│  │     │        │        │  └─ 📄PageRequest.java
│  │     │        │        └─ 📁response
│  │     │        │           ├─ 📄Result.java
│  │     │        │           └─ 📄ResultCode.java
│  │     │        ├─ 📁modules
│  │     │        │  ├─ 📁auth
│  │     │        │  │  ├─ 📁controller
│  │     │        │  │  │  └─ 📄AuthController.java
│  │     │        │  │  ├─ 📁model
│  │     │        │  │  │  ├─ 📁domain
│  │     │        │  │  │  └─ 📁dto
│  │     │        │  │  │     ├─ 📄CaptchaResponse.java
│  │     │        │  │  │     ├─ 📄LoginRequest.java
│  │     │        │  │  │     ├─ 📄LoginResponse.java
│  │     │        │  │  │     └─ 📄RegisterRequest.java
│  │     │        │  │  └─ 📁service
│  │     │        │  │     ├─ 📁impl
│  │     │        │  │     │  ├─ 📄AuthServiceImpl.java
│  │     │        │  │     │  └─ 📄CaptchaServiceImpl.java
│  │     │        │  │     ├─ 📄AuthService.java
│  │     │        │  │     └─ 📄CaptchaService.java
│  │     │        │  ├─ 📁business
│  │     │        │  │  ├─ 📁controller
│  │     │        │  │  │  ├─ 📄BsModelCollectController.java
│  │     │        │  │  │  ├─ 📄BsModelController.java
│  │     │        │  │  │  └─ 📄BsModelLabelController.java
│  │     │        │  │  ├─ 📁mapper
│  │     │        │  │  │  ├─ 📄BsModelCollectMapper.java
│  │     │        │  │  │  ├─ 📄BsModelLabelMapper.java
│  │     │        │  │  │  └─ 📄BsModelMapper.java
│  │     │        │  │  ├─ 📁model
│  │     │        │  │  │  ├─ 📁domain
│  │     │        │  │  │  │  ├─ 📄BsModel.java
│  │     │        │  │  │  │  ├─ 📄BsModelCollect.java
│  │     │        │  │  │  │  ├─ 📄BsModelLabel.java
│  │     │        │  │  │  │  └─ 📄BsModelParams.java
│  │     │        │  │  │  ├─ 📁dto
│  │     │        │  │  │  ├─ 📁request
│  │     │        │  │  │  │  └─ 📄ModelUploadRequest.java
│  │     │        │  │  │  └─ 📁vo
│  │     │        │  │  ├─ 📁repository
│  │     │        │  │  └─ 📁service
│  │     │        │  │     ├─ 📁impl
│  │     │        │  │     │  ├─ 📄BsModelCollectServiceImpl.java
│  │     │        │  │     │  ├─ 📄BsModelLabelServiceImpl.java
│  │     │        │  │     │  └─ 📄BsModelServiceImpl.java
│  │     │        │  │     ├─ 📄BsModelCollectService.java
│  │     │        │  │     ├─ 📄BsModelLabelService.java
│  │     │        │  │     ├─ 📄BsModelService.java
│  │     │        │  │     └─ 📄GiteaService.java
│  │     │        │  └─ 📁sys
│  │     │        │     ├─ 📁controller
│  │     │        │     │  └─ 📄SysUserController.java
│  │     │        │     ├─ 📁mapper
│  │     │        │     │  ├─ 📄SysRoleMapper.java
│  │     │        │     │  ├─ 📄SysUserMapper.java
│  │     │        │     │  └─ 📄SysUserRoleMapper.java
│  │     │        │     ├─ 📁model
│  │     │        │     │  ├─ 📁domain
│  │     │        │     │  │  ├─ 📄SysFile.java
│  │     │        │     │  │  ├─ 📄SysPower.java
│  │     │        │     │  │  ├─ 📄SysRole.java
│  │     │        │     │  │  ├─ 📄SysUser.java
│  │     │        │     │  │  └─ 📄SysUserRole.java
│  │     │        │     │  └─ 📁dto
│  │     │        │     │     ├─ 📄ChangePasswordRequest.java
│  │     │        │     │     ├─ 📄ResetPasswordRequest.java
│  │     │        │     │     ├─ 📄RoleVO.java
│  │     │        │     │     ├─ 📄UserCreateRequest.java
│  │     │        │     │     ├─ 📄UserProfileUpdateRequest.java
│  │     │        │     │     ├─ 📄UserQueryRequest.java
│  │     │        │     │     ├─ 📄UserUpdateRequest.java
│  │     │        │     │     └─ 📄UserVO.java
│  │     │        │     └─ 📁service
│  │     │        │        ├─ 📁impl
│  │     │        │        │  ├─ 📄SysRoleServiceImpl.java
│  │     │        │        │  └─ 📄SysUserServiceImpl.java
│  │     │        │        ├─ 📄SysRoleService.java
│  │     │        │        └─ 📄SysUserService.java
│  │     │        └─ 📄ModelCloudApplication.java
│  │     └─ 📁resources
│  │        ├─ 📁db
│  │        │  └─ 📄init.sql
│  │        ├─ 📁mapper
│  │        │  └─ 📁business
│  │        │     └─ 📄BsModelMapper.xml
│  │        ├─ 📄application-dev.yml
│  │        ├─ 📄application-prod.yml
│  │        └─ 📄application.yml
│  ├─ 📁target
│  ├─ 📄.gitignore
│  ├─ 📄pom.xml
│  ├─ 📄README.md
│  ├─ 📄README_AUTH.md
│  ├─ 📄数据库初始化指南.md
│  ├─ 📄数据库设计-ER图说明.md
│  └─ 📄数据库设计说明-登录注册.md
├─ 📁model-cloud-frontend
│  ├─ 📁node_modules
│  ├─ 📁src
│  │  ├─ 📁api
│  │  │  ├─ 📄auth.ts
│  │  │  ├─ 📄model.ts
│  │  │  ├─ 📄request.ts
│  │  │  └─ 📄user.ts
│  │  ├─ 📁layouts
│  │  │  └─ 📄MainLayout.vue
│  │  ├─ 📁router
│  │  │  └─ 📄index.ts
│  │  ├─ 📁stores
│  │  │  └─ 📄user.ts
│  │  ├─ 📁views
│  │  │  ├─ 📁auth
│  │  │  │  ├─ 📄Login.vue
│  │  │  │  └─ 📄Register.vue
│  │  │  ├─ 📁business
│  │  │  │  ├─ 📄ModelDetail.vue
│  │  │  │  ├─ 📄ModelList.vue
│  │  │  │  └─ 📄MyCollects.vue
│  │  │  ├─ 📁dashboard
│  │  │  │  └─ 📄Home.vue
│  │  │  ├─ 📁error
│  │  │  │  └─ 📄404.vue
│  │  │  └─ 📁system
│  │  │     ├─ 📄Profile.vue
│  │  │     └─ 📄UserList.vue
│  │  ├─ 📄App.vue
│  │  ├─ 📄main.ts
│  │  └─ 📄style.css
│  ├─ 📄.gitignore
│  ├─ 📄index.html
│  ├─ 📄package-lock.json
│  ├─ 📄package.json
│  ├─ 📄README.md
│  ├─ 📄tsconfig.json
│  ├─ 📄tsconfig.node.json
│  └─ 📄vite.config.ts
├─ 📄README.md
├─ 📄技术报告.md

```























