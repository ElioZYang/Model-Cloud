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
























```
model-cloud
├─ 📁model-cloud-backend
│  ├─ 📁runtime
│  │  └─ 📁modelica-icons
│  │     └─ 📄24.svg
│  ├─ 📁src
│  │  └─ 📁main
│  │     ├─ 📁java
│  │     │  └─ 📁com
│  │     │     └─ 📁modelcloud
│  │     │        ├─ 📁common
│  │     │        │  ├─ 📁config
│  │     │        │  │  ├─ 📄AsyncConfig.java
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
│  │     │        │  │  │  ├─ 📄BsModelLabelController.java
│  │     │        │  │  │  ├─ 📄ModelDeployController.java
│  │     │        │  │  │  └─ 📄SseController.java
│  │     │        │  │  ├─ 📁event
│  │     │        │  │  │  └─ 📄VisitCountEvent.java
│  │     │        │  │  ├─ 📁mapper
│  │     │        │  │  │  ├─ 📄BsComponentMapper.java
│  │     │        │  │  │  ├─ 📄BsModelCollectMapper.java
│  │     │        │  │  │  ├─ 📄BsModelingProjectMapper.java
│  │     │        │  │  │  ├─ 📄BsModelLabelMapper.java
│  │     │        │  │  │  ├─ 📄BsModelMapper.java
│  │     │        │  │  │  ├─ 📄BsSimulationTaskMapper.java
│  │     │        │  │  │  └─ 📄ModelLabelCategoryMapper.java
│  │     │        │  │  ├─ 📁model
│  │     │        │  │  │  ├─ 📁domain
│  │     │        │  │  │  │  ├─ 📄BsComponent.java
│  │     │        │  │  │  │  ├─ 📄BsComponentParseMeta.java
│  │     │        │  │  │  │  ├─ 📄BsComponentParseMetaOmc.java
│  │     │        │  │  │  │  ├─ 📄BsModel.java
│  │     │        │  │  │  │  ├─ 📄BsModelCollect.java
│  │     │        │  │  │  │  ├─ 📄BsModelingProject.java
│  │     │        │  │  │  │  ├─ 📄BsModelLabel.java
│  │     │        │  │  │  │  ├─ 📄BsModelParams.java
│  │     │        │  │  │  │  ├─ 📄BsSimulationTask.java
│  │     │        │  │  │  │  └─ 📄ModelLabelCategory.java
│  │     │        │  │  │  ├─ 📁dto
│  │     │        │  │  │  │  └─ 📄ComponentVO.java
│  │     │        │  │  │  └─ 📁request
│  │     │        │  │  │     ├─ 📄ComponentUploadRequest.java
│  │     │        │  │  │     ├─ 📄ModelingProjectRequest.java
│  │     │        │  │  │     ├─ 📄ModelUploadRequest.java
│  │     │        │  │  │     └─ 📄SimulationRequest.java
│  │     │        │  │  ├─ 📁repository
│  │     │        │  │  │  ├─ 📄BsComponentParseMetaOmcRepository.java
│  │     │        │  │  │  └─ 📄BsComponentParseMetaRepository.java
│  │     │        │  │  ├─ 📁service
│  │     │        │  │  │  ├─ 📁impl
│  │     │        │  │  │  │  ├─ 📄BsModelCollectServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄BsModelLabelServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄BsModelServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄ModelDeployServiceImpl.java
│  │     │        │  │  │  │  └─ 📄ModelLabelCategoryServiceImpl.java
│  │     │        │  │  │  ├─ 📄BsModelCollectService.java
│  │     │        │  │  │  ├─ 📄BsModelLabelService.java
│  │     │        │  │  │  ├─ 📄BsModelService.java
│  │     │        │  │  │  ├─ 📄GiteaService.java
│  │     │        │  │  │  ├─ 📄ModelDeployService.java
│  │     │        │  │  │  └─ 📄ModelLabelCategoryService.java
│  │     │        │  │  └─ 📁utils
│  │     │        │  │     ├─ 📄ModelicaIconSvgRenderer.java
│  │     │        │  │     └─ 📄ModelicaParser.java
│  │     │        │  └─ 📁sys
│  │     │        │     ├─ 📁controller
│  │     │        │     │  └─ 📄SysUserController.java
│  │     │        │     ├─ 📁mapper
│  │     │        │     │  ├─ 📄SysRoleMapper.java
│  │     │        │     │  ├─ 📄SysSiteStatMapper.java
│  │     │        │     │  ├─ 📄SysUserMapper.java
│  │     │        │     │  └─ 📄SysUserRoleMapper.java
│  │     │        │     ├─ 📁model
│  │     │        │     │  ├─ 📁domain
│  │     │        │     │  │  ├─ 📄SysFile.java
│  │     │        │     │  │  ├─ 📄SysPower.java
│  │     │        │     │  │  ├─ 📄SysRole.java
│  │     │        │     │  │  ├─ 📄SysSiteStat.java
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
│  │     │        │        │  ├─ 📄SiteStatServiceImpl.java
│  │     │        │        │  ├─ 📄SysRoleServiceImpl.java
│  │     │        │        │  └─ 📄SysUserServiceImpl.java
│  │     │        │        ├─ 📄SiteStatService.java
│  │     │        │        ├─ 📄SysRoleService.java
│  │     │        │        └─ 📄SysUserService.java
│  │     │        └─ 📄ModelCloudApplication.java
│  │     └─ 📁resources
│  │        ├─ 📁mapper
│  │        │  └─ 📁business
│  │        │     └─ 📄BsModelMapper.xml
│  │        ├─ 📁static
│  │        │  ├─ 📁component_icon
│  │        │  │  ├─ 📁Electrical
│  │        │  │  │  ├─ 📄AbsoluteSensor.svg
│  │        │  │  │  ├─ 📄ACAC.svg
│  │        │  │  │  ├─ 📄ACACConcept.svg
│  │        │  │  │  ├─ 📄ACCircuit.svg
│  │        │  │  │  ├─ 📄ACDC.svg
│  │        │  │  │  ├─ 📄ACDCConcept.svg
│  │        │  │  │  ├─ 📄ACpin.svg
│  │        │  │  │  ├─ 📄ACplug.svg
│  │        │  │  │  ├─ 📄activePower.svg
│  │        │  │  │  ├─ 📄ACtwoPin.svg
│  │        │  │  │  ├─ 📄ACtwoPlug.svg
│  │        │  │  │  ├─ 📄Add.svg
│  │        │  │  │  ├─ 📄Adder.svg
│  │        │  │  │  ├─ 📄Adder4.svg
│  │        │  │  │  ├─ 📄Additionals.svg
│  │        │  │  │  ├─ 📄Admittance.svg
│  │        │  │  │  ├─ 📄AD_Converter.svg
│  │        │  │  │  ├─ 📄AD_DA_conversion.svg
│  │        │  │  │  ├─ 📄AirGapDC.svg
│  │        │  │  │  ├─ 📄AirGapR.svg
│  │        │  │  │  ├─ 📄AirGapS.svg
│  │        │  │  │  ├─ 📄AmplifierWithOpAmpDetailed.svg
│  │        │  │  │  ├─ 📄Analog.svg
│  │        │  │  │  ├─ 📄AnalysatorAC.svg
│  │        │  │  │  ├─ 📄AnalysatorDC.svg
│  │        │  │  │  ├─ 📄And.svg
│  │        │  │  │  ├─ 📄AndGate.svg
│  │        │  │  │  ├─ 📄AronSensor.svg
│  │        │  │  │  ├─ 📄AsymmetricalLoad.svg
│  │        │  │  │  ├─ 📄BalancingDelta.svg
│  │        │  │  │  ├─ 📄BalancingStar.svg
│  │        │  │  │  ├─ 📄BaseCellRecord.svg
│  │        │  │  │  ├─ 📄BaseCellStack.svg
│  │        │  │  │  ├─ 📄BaseCellWithSensors.svg
│  │        │  │  │  ├─ 📄BaseClasses.svg
│  │        │  │  │  ├─ 📄BaseStackData.svg
│  │        │  │  │  ├─ 📄BaseStackRecord.svg
│  │        │  │  │  ├─ 📄BaseStackWithSensors.svg
│  │        │  │  │  ├─ 📄Basic.svg
│  │        │  │  │  ├─ 📄BasicMachines.svg
│  │        │  │  │  ├─ 📄Batteries.svg
│  │        │  │  │  ├─ 📄Battery.svg
│  │        │  │  │  ├─ 📄BatteryDischargeCharge.svg
│  │        │  │  │  ├─ 📄BatteryIcon.svg
│  │        │  │  │  ├─ 📄BatteryStacks.svg
│  │        │  │  │  ├─ 📄BatteryStacksWithSensors.svg
│  │        │  │  │  ├─ 📄Bjt.svg
│  │        │  │  │  ├─ 📄BJT2.svg
│  │        │  │  │  ├─ 📄BjtCalc.svg
│  │        │  │  │  ├─ 📄bjtCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄bjtInitEquations.svg
│  │        │  │  │  ├─ 📄bjtModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄BjtModelLineParams.svg
│  │        │  │  │  ├─ 📄bjtNoBypassCode.svg
│  │        │  │  │  ├─ 📄bjtRenameParameters.svg
│  │        │  │  │  ├─ 📄bjtRenameParametersDev.svg
│  │        │  │  │  ├─ 📄Blocks.svg
│  │        │  │  │  ├─ 📄BooleanToLogic.svg
│  │        │  │  │  ├─ 📄Brush.svg
│  │        │  │  │  ├─ 📄BrushParameters.svg
│  │        │  │  │  ├─ 📄brushVoltageDrop.svg
│  │        │  │  │  ├─ 📄BUF3S.svg
│  │        │  │  │  ├─ 📄BUF3SL.svg
│  │        │  │  │  ├─ 📄Buffer.svg
│  │        │  │  │  ├─ 📄BufGate.svg
│  │        │  │  │  ├─ 📄BusTranscription.svg
│  │        │  │  │  ├─ 📄calculateGateCap.svg
│  │        │  │  │  ├─ 📄Capacitance.svg
│  │        │  │  │  ├─ 📄Capacitor.svg
│  │        │  │  │  ├─ 📄capacitorInitEquations.svg
│  │        │  │  │  ├─ 📄CapacitorModelLineParams.svg
│  │        │  │  │  ├─ 📄capacitorRenameParameters.svg
│  │        │  │  │  ├─ 📄capacitorRenameParametersDev.svg
│  │        │  │  │  ├─ 📄capDepGeom.svg
│  │        │  │  │  ├─ 📄CascodeCircuit.svg
│  │        │  │  │  ├─ 📄CauerLowPassAnalog.svg
│  │        │  │  │  ├─ 📄CauerLowPassOPV.svg
│  │        │  │  │  ├─ 📄CauerLowPassSC.svg
│  │        │  │  │  ├─ 📄CCC.svg
│  │        │  │  │  ├─ 📄CCCVcharger.svg
│  │        │  │  │  ├─ 📄CCCVcharging.svg
│  │        │  │  │  ├─ 📄CCCV_Cell.svg
│  │        │  │  │  ├─ 📄CCCV_CellRC.svg
│  │        │  │  │  ├─ 📄CCCV_Stack.svg
│  │        │  │  │  ├─ 📄CCCV_StackRC.svg
│  │        │  │  │  ├─ 📄CCV.svg
│  │        │  │  │  ├─ 📄Cell.svg
│  │        │  │  │  ├─ 📄CellBus.svg
│  │        │  │  │  ├─ 📄CellData.svg
│  │        │  │  │  ├─ 📄CellRC.svg
│  │        │  │  │  ├─ 📄CellRCStack.svg
│  │        │  │  │  ├─ 📄CellStack.svg
│  │        │  │  │  ├─ 📄CharacteristicIdealDiodes.svg
│  │        │  │  │  ├─ 📄CharacteristicThyristors.svg
│  │        │  │  │  ├─ 📄ChopperStepDown.svg
│  │        │  │  │  ├─ 📄ChopperStepDown_R.svg
│  │        │  │  │  ├─ 📄ChopperStepDown_RL.svg
│  │        │  │  │  ├─ 📄ChopperStepUp.svg
│  │        │  │  │  ├─ 📄ChopperStepUp_R.svg
│  │        │  │  │  ├─ 📄ChuaCircuit.svg
│  │        │  │  │  ├─ 📄CloserWithArc.svg
│  │        │  │  │  ├─ 📄Comparator.svg
│  │        │  │  │  ├─ 📄CompareTransformers.svg
│  │        │  │  │  ├─ 📄Components.svg
│  │        │  │  │  ├─ 📄CompoundDCExcitation.svg
│  │        │  │  │  ├─ 📄Concept.svg
│  │        │  │  │  ├─ 📄ConditionalHeatPort.svg
│  │        │  │  │  ├─ 📄ConditionalSubstrate.svg
│  │        │  │  │  ├─ 📄Conductor.svg
│  │        │  │  │  ├─ 📄ConstantCurrent.svg
│  │        │  │  │  ├─ 📄Constants.svg
│  │        │  │  │  ├─ 📄ConstantVoltage.svg
│  │        │  │  │  ├─ 📄Contact.svg
│  │        │  │  │  ├─ 📄Control.svg
│  │        │  │  │  ├─ 📄ControlCircuit.svg
│  │        │  │  │  ├─ 📄ControlledCloserWithArc.svg
│  │        │  │  │  ├─ 📄ControlledDCDrives.svg
│  │        │  │  │  ├─ 📄ControlledIdealClosingSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealOpeningSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.svg
│  │        │  │  │  ├─ 📄ControlledOpenerWithArc.svg
│  │        │  │  │  ├─ 📄ControlledSwitchWithArc.svg
│  │        │  │  │  ├─ 📄convertAlpha.svg
│  │        │  │  │  ├─ 📄Converter.svg
│  │        │  │  │  ├─ 📄Converters.svg
│  │        │  │  │  ├─ 📄convertResistance.svg
│  │        │  │  │  ├─ 📄Core.svg
│  │        │  │  │  ├─ 📄CoreParameters.svg
│  │        │  │  │  ├─ 📄CosineCurrent.svg
│  │        │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄CosineVoltage.svg
│  │        │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄Counter.svg
│  │        │  │  │  ├─ 📄Counter3.svg
│  │        │  │  │  ├─ 📄CoupledInductors.svg
│  │        │  │  │  ├─ 📄Csemiconductor.svg
│  │        │  │  │  ├─ 📄CurrentControlledDCPM.svg
│  │        │  │  │  ├─ 📄CurrentQuasiRMSSensor.svg
│  │        │  │  │  ├─ 📄CurrentsCapacitances.svg
│  │        │  │  │  ├─ 📄CurrentSensor.svg
│  │        │  │  │  ├─ 📄CurrentSource.svg
│  │        │  │  │  ├─ 📄CurrrentsCapacitances.svg
│  │        │  │  │  ├─ 📄C_Capacitor.svg
│  │        │  │  │  ├─ 📄C_SEMI.svg
│  │        │  │  │  ├─ 📄DamperCage.svg
│  │        │  │  │  ├─ 📄DA_Converter.svg
│  │        │  │  │  ├─ 📄DCAC.svg
│  │        │  │  │  ├─ 📄DCACConcept.svg
│  │        │  │  │  ├─ 📄DcBrakeSettings.svg
│  │        │  │  │  ├─ 📄DCDC.svg
│  │        │  │  │  ├─ 📄DCDCConcept.svg
│  │        │  │  │  ├─ 📄DcdcInverter.svg
│  │        │  │  │  ├─ 📄DCEE_Start.svg
│  │        │  │  │  ├─ 📄DcElectricalExcitedData.svg
│  │        │  │  │  ├─ 📄DCMachines.svg
│  │        │  │  │  ├─ 📄DcPermanentMagnetData.svg
│  │        │  │  │  ├─ 📄DCpin.svg
│  │        │  │  │  ├─ 📄DCPM_Cooling.svg
│  │        │  │  │  ├─ 📄DCPM_CurrentControlled.svg
│  │        │  │  │  ├─ 📄DCPM_QuasiStatic.svg
│  │        │  │  │  ├─ 📄DCPM_Start.svg
│  │        │  │  │  ├─ 📄DCPM_Temperature.svg
│  │        │  │  │  ├─ 📄DCPM_withLosses.svg
│  │        │  │  │  ├─ 📄DcSeriesExcitedData.svg
│  │        │  │  │  ├─ 📄DCSE_SinglePhase.svg
│  │        │  │  │  ├─ 📄DCSE_Start.svg
│  │        │  │  │  ├─ 📄DCtwoPin.svg
│  │        │  │  │  ├─ 📄DCtwoPin1.svg
│  │        │  │  │  ├─ 📄DCtwoPin2.svg
│  │        │  │  │  ├─ 📄DC_CompareCharacteristics.svg
│  │        │  │  │  ├─ 📄DC_ElectricalExcited.svg
│  │        │  │  │  ├─ 📄DC_PermanentMagnet.svg
│  │        │  │  │  ├─ 📄DC_SeriesExcited.svg
│  │        │  │  │  ├─ 📄Dd.svg
│  │        │  │  │  ├─ 📄Dd00.svg
│  │        │  │  │  ├─ 📄Dd02.svg
│  │        │  │  │  ├─ 📄Dd04.svg
│  │        │  │  │  ├─ 📄Dd06.svg
│  │        │  │  │  ├─ 📄Dd08.svg
│  │        │  │  │  ├─ 📄Dd10.svg
│  │        │  │  │  ├─ 📄Delay.svg
│  │        │  │  │  ├─ 📄DelayParams.svg
│  │        │  │  │  ├─ 📄Delta.svg
│  │        │  │  │  ├─ 📄Der.svg
│  │        │  │  │  ├─ 📄Derivative.svg
│  │        │  │  │  ├─ 📄DEVqmeyer.svg
│  │        │  │  │  ├─ 📄DFF.svg
│  │        │  │  │  ├─ 📄DFFR.svg
│  │        │  │  │  ├─ 📄DFFREG.svg
│  │        │  │  │  ├─ 📄DFFREGL.svg
│  │        │  │  │  ├─ 📄DFFREGSRH.svg
│  │        │  │  │  ├─ 📄DFFREGSRL.svg
│  │        │  │  │  ├─ 📄DFFSR.svg
│  │        │  │  │  ├─ 📄DifferenceAmplifier.svg
│  │        │  │  │  ├─ 📄DifferentialAmplifier.svg
│  │        │  │  │  ├─ 📄DifferentialAmplifierData.svg
│  │        │  │  │  ├─ 📄Differentiator.svg
│  │        │  │  │  ├─ 📄Digital.svg
│  │        │  │  │  ├─ 📄DigitalClock.svg
│  │        │  │  │  ├─ 📄DigitalInput.svg
│  │        │  │  │  ├─ 📄DigitalOutput.svg
│  │        │  │  │  ├─ 📄DigitalSignal.svg
│  │        │  │  │  ├─ 📄Dimmer.svg
│  │        │  │  │  ├─ 📄Dimmer_R.svg
│  │        │  │  │  ├─ 📄Dimmer_RL.svg
│  │        │  │  │  ├─ 📄Diode.svg
│  │        │  │  │  ├─ 📄Diode2.svg
│  │        │  │  │  ├─ 📄DiodeBridge2mPulse.svg
│  │        │  │  │  ├─ 📄DiodeBridge2Pulse.svg
│  │        │  │  │  ├─ 📄DiodeCalc.svg
│  │        │  │  │  ├─ 📄diodeCalcAdditionalValues.svg
│  │        │  │  │  ├─ 📄diodeCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄DiodeCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄DiodeCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄DiodeCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄diodeInitEquations.svg
│  │        │  │  │  ├─ 📄diodeModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄DiodeModelLineParams.svg
│  │        │  │  │  ├─ 📄DiodeModelLineVariables.svg
│  │        │  │  │  ├─ 📄diodeNoBypassCode.svg
│  │        │  │  │  ├─ 📄DiodeParams.svg
│  │        │  │  │  ├─ 📄diodeRenameParameters.svg
│  │        │  │  │  ├─ 📄diodeRenameParametersDev.svg
│  │        │  │  │  ├─ 📄diodeRenameParametersDevTemp.svg
│  │        │  │  │  ├─ 📄DiodeVariables.svg
│  │        │  │  │  ├─ 📄DirectCapacitor.svg
│  │        │  │  │  ├─ 📄DirectInductor.svg
│  │        │  │  │  ├─ 📄Discrimination.svg
│  │        │  │  │  ├─ 📄DLATR.svg
│  │        │  │  │  ├─ 📄DLATRAM.svg
│  │        │  │  │  ├─ 📄DLATREG.svg
│  │        │  │  │  ├─ 📄DLATREGL.svg
│  │        │  │  │  ├─ 📄DLATREGSRH.svg
│  │        │  │  │  ├─ 📄DLATREGSRL.svg
│  │        │  │  │  ├─ 📄DLATROM.svg
│  │        │  │  │  ├─ 📄DLATSR.svg
│  │        │  │  │  ├─ 📄DQCurrentController.svg
│  │        │  │  │  ├─ 📄DQToThreePhase.svg
│  │        │  │  │  ├─ 📄drainCur.svg
│  │        │  │  │  ├─ 📄drainCurRevised.svg
│  │        │  │  │  ├─ 📄Drive.svg
│  │        │  │  │  ├─ 📄DriveDataDCPM.svg
│  │        │  │  │  ├─ 📄Dy.svg
│  │        │  │  │  ├─ 📄Dy01.svg
│  │        │  │  │  ├─ 📄Dy03.svg
│  │        │  │  │  ├─ 📄Dy05.svg
│  │        │  │  │  ├─ 📄Dy07.svg
│  │        │  │  │  ├─ 📄Dy09.svg
│  │        │  │  │  ├─ 📄Dy11.svg
│  │        │  │  │  ├─ 📄Dz.svg
│  │        │  │  │  ├─ 📄Dz00.svg
│  │        │  │  │  ├─ 📄Dz02.svg
│  │        │  │  │  ├─ 📄Dz04.svg
│  │        │  │  │  ├─ 📄Dz06.svg
│  │        │  │  │  ├─ 📄Dz08.svg
│  │        │  │  │  ├─ 📄Dz10.svg
│  │        │  │  │  ├─ 📄D_DIODE.svg
│  │        │  │  │  ├─ 📄Electrical.svg
│  │        │  │  │  ├─ 📄ElectricalExcitation.svg
│  │        │  │  │  ├─ 📄ElectricalPowerSensor.svg
│  │        │  │  │  ├─ 📄ElectricFieldStrength_cm.svg
│  │        │  │  │  ├─ 📄Enable.svg
│  │        │  │  │  ├─ 📄Enable1.svg
│  │        │  │  │  ├─ 📄Enable1m.svg
│  │        │  │  │  ├─ 📄Enable2.svg
│  │        │  │  │  ├─ 📄Enable2m.svg
│  │        │  │  │  ├─ 📄EnableLogic.svg
│  │        │  │  │  ├─ 📄energyGapDepTemp.svg
│  │        │  │  │  ├─ 📄energyGapDepTemp_old.svg
│  │        │  │  │  ├─ 📄equalityConstraint.svg
│  │        │  │  │  ├─ 📄ExampleData.svg
│  │        │  │  │  ├─ 📄Examples.svg
│  │        │  │  │  ├─ 📄ExampleTemplate.svg
│  │        │  │  │  ├─ 📄ExampleTemplates.svg
│  │        │  │  │  ├─ 📄ExponentialsCurrent.svg
│  │        │  │  │  ├─ 📄ExponentialsVoltage.svg
│  │        │  │  │  ├─ 📄ExpSineCurrent.svg
│  │        │  │  │  ├─ 📄ExpSineVoltage.svg
│  │        │  │  │  ├─ 📄E_VCV.svg
│  │        │  │  │  ├─ 📄E_VCV_POLY.svg
│  │        │  │  │  ├─ 📄factorY2D.svg
│  │        │  │  │  ├─ 📄factorY2DC.svg
│  │        │  │  │  ├─ 📄FCNiout_limit.svg
│  │        │  │  │  ├─ 📄FCNq_sum_limit.svg
│  │        │  │  │  ├─ 📄Feedback.svg
│  │        │  │  │  ├─ 📄Fet.svg
│  │        │  │  │  ├─ 📄FetModelLine.svg
│  │        │  │  │  ├─ 📄fetRenameParametersDev.svg
│  │        │  │  │  ├─ 📄Filter.svg
│  │        │  │  │  ├─ 📄FirstOrder.svg
│  │        │  │  │  ├─ 📄FlangeSupport.svg
│  │        │  │  │  ├─ 📄FlipFlop.svg
│  │        │  │  │  ├─ 📄FOURBIT.svg
│  │        │  │  │  ├─ 📄FourInverters.svg
│  │        │  │  │  ├─ 📄FourPin.svg
│  │        │  │  │  ├─ 📄FourPlug.svg
│  │        │  │  │  ├─ 📄FrequencySensor.svg
│  │        │  │  │  ├─ 📄FrequencySweepCurrentSource.svg
│  │        │  │  │  ├─ 📄FrequencySweepVoltageSource.svg
│  │        │  │  │  ├─ 📄Friction.svg
│  │        │  │  │  ├─ 📄FrictionParameters.svg
│  │        │  │  │  ├─ 📄FromDQ.svg
│  │        │  │  │  ├─ 📄FromPolar.svg
│  │        │  │  │  ├─ 📄FromSpacePhasor.svg
│  │        │  │  │  ├─ 📄FromSymmetricalComponents.svg
│  │        │  │  │  ├─ 📄FullAdder.svg
│  │        │  │  │  ├─ 📄Functions.svg
│  │        │  │  │  ├─ 📄FundamentalWaveMachine.svg
│  │        │  │  │  ├─ 📄F_CCC.svg
│  │        │  │  │  ├─ 📄F_CCC_POLY.svg
│  │        │  │  │  ├─ 📄Gain.svg
│  │        │  │  │  ├─ 📄GapEnergyPerEnergy.svg
│  │        │  │  │  ├─ 📄GapEnergyPerTemperature.svg
│  │        │  │  │  ├─ 📄Gates.svg
│  │        │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.svg
│  │        │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.svg
│  │        │  │  │  ├─ 📄GenerationOfFMUs.svg
│  │        │  │  │  ├─ 📄getMemory.svg
│  │        │  │  │  ├─ 📄getNumberOfElectricalPins.svg
│  │        │  │  │  ├─ 📄Glossar.svg
│  │        │  │  │  ├─ 📄Graetz.svg
│  │        │  │  │  ├─ 📄GraetzRectifier.svg
│  │        │  │  │  ├─ 📄Ground.svg
│  │        │  │  │  ├─ 📄Gyrator.svg
│  │        │  │  │  ├─ 📄G_VCC.svg
│  │        │  │  │  ├─ 📄G_VCC_POLY.svg
│  │        │  │  │  ├─ 📄HalfAdder.svg
│  │        │  │  │  ├─ 📄HalfControlledBridge2mPulse.svg
│  │        │  │  │  ├─ 📄HalfControlledBridge2Pulse.svg
│  │        │  │  │  ├─ 📄HallSensor.svg
│  │        │  │  │  ├─ 📄HBridge.svg
│  │        │  │  │  ├─ 📄HBridge_DC_Drive.svg
│  │        │  │  │  ├─ 📄HBridge_R.svg
│  │        │  │  │  ├─ 📄HBridge_RL.svg
│  │        │  │  │  ├─ 📄HeatingMOSInverter.svg
│  │        │  │  │  ├─ 📄HeatingNPN_NORGate.svg
│  │        │  │  │  ├─ 📄HeatingPNP_NORGate.svg
│  │        │  │  │  ├─ 📄HeatingRectifier.svg
│  │        │  │  │  ├─ 📄HighPass.svg
│  │        │  │  │  ├─ 📄H_CCV.svg
│  │        │  │  │  ├─ 📄H_CCV_POLY.svg
│  │        │  │  │  ├─ 📄Icons.svg
│  │        │  │  │  ├─ 📄Ideal.svg
│  │        │  │  │  ├─ 📄IdealACDCConverter.svg
│  │        │  │  │  ├─ 📄IdealClosingSwitch.svg
│  │        │  │  │  ├─ 📄IdealCommutingSwitch.svg
│  │        │  │  │  ├─ 📄IdealCore.svg
│  │        │  │  │  ├─ 📄IdealDcDc.svg
│  │        │  │  │  ├─ 📄IdealDiode.svg
│  │        │  │  │  ├─ 📄IdealGTOThyristor.svg
│  │        │  │  │  ├─ 📄IdealIntermediateSwitch.svg
│  │        │  │  │  ├─ 📄IdealizedOpAmpLimited.svg
│  │        │  │  │  ├─ 📄IdealOpAmp.svg
│  │        │  │  │  ├─ 📄IdealOpAmp3Pin.svg
│  │        │  │  │  ├─ 📄IdealOpAmpLimited.svg
│  │        │  │  │  ├─ 📄IdealOpeningSwitch.svg
│  │        │  │  │  ├─ 📄IdealSemiconductor.svg
│  │        │  │  │  ├─ 📄IdealSwitch.svg
│  │        │  │  │  ├─ 📄IdealSwitchWithArc.svg
│  │        │  │  │  ├─ 📄IdealThyristor.svg
│  │        │  │  │  ├─ 📄IdealTransformer.svg
│  │        │  │  │  ├─ 📄IdealTriac.svg
│  │        │  │  │  ├─ 📄IdealTriacCircuit.svg
│  │        │  │  │  ├─ 📄IdealTwoWaySwitch.svg
│  │        │  │  │  ├─ 📄Idle.svg
│  │        │  │  │  ├─ 📄IMC_Conveyor.svg
│  │        │  │  │  ├─ 📄IMC_DCBraking.svg
│  │        │  │  │  ├─ 📄IMC_DOL.svg
│  │        │  │  │  ├─ 📄IMC_Initialize.svg
│  │        │  │  │  ├─ 📄IMC_Inverter.svg
│  │        │  │  │  ├─ 📄IMC_InverterDrive.svg
│  │        │  │  │  ├─ 📄IMC_Steinmetz.svg
│  │        │  │  │  ├─ 📄IMC_Transformer.svg
│  │        │  │  │  ├─ 📄IMC_withLosses.svg
│  │        │  │  │  ├─ 📄IMC_YD.svg
│  │        │  │  │  ├─ 📄IMC_YDarc.svg
│  │        │  │  │  ├─ 📄Impedance.svg
│  │        │  │  │  ├─ 📄IMS_Start.svg
│  │        │  │  │  ├─ 📄IM_SlipRing.svg
│  │        │  │  │  ├─ 📄IM_SlipRingData.svg
│  │        │  │  │  ├─ 📄IM_SquirrelCage.svg
│  │        │  │  │  ├─ 📄IM_SquirrelCageData.svg
│  │        │  │  │  ├─ 📄index.html
│  │        │  │  │  ├─ 📄indexNonPositiveSequence.svg
│  │        │  │  │  ├─ 📄indexPositiveSequence.svg
│  │        │  │  │  ├─ 📄InductionMachineData.svg
│  │        │  │  │  ├─ 📄InductionMachines.svg
│  │        │  │  │  ├─ 📄InductiveCouplePinIn.svg
│  │        │  │  │  ├─ 📄InductiveCouplePinOut.svg
│  │        │  │  │  ├─ 📄Inductor.svg
│  │        │  │  │  ├─ 📄InductorDC.svg
│  │        │  │  │  ├─ 📄InertialDelay.svg
│  │        │  │  │  ├─ 📄InertialDelaySensitive.svg
│  │        │  │  │  ├─ 📄InertialDelaySensitiveVector.svg
│  │        │  │  │  ├─ 📄initJunctionVoltagesRevised.svg
│  │        │  │  │  ├─ 📄Integrator.svg
│  │        │  │  │  ├─ 📄Interfaces.svg
│  │        │  │  │  ├─ 📄Internal.svg
│  │        │  │  │  ├─ 📄IntersectivePWM.svg
│  │        │  │  │  ├─ 📄Introduction.svg
│  │        │  │  │  ├─ 📄INV3S.svg
│  │        │  │  │  ├─ 📄INV3SL.svg
│  │        │  │  │  ├─ 📄InverseCapacitor.svg
│  │        │  │  │  ├─ 📄InverseElectricCurrent.svg
│  │        │  │  │  ├─ 📄InverseInductor.svg
│  │        │  │  │  ├─ 📄Inverter.svg
│  │        │  │  │  ├─ 📄InvertersApartRecord.svg
│  │        │  │  │  ├─ 📄InvertersExtendedModel.svg
│  │        │  │  │  ├─ 📄InvertingAmp.svg
│  │        │  │  │  ├─ 📄InvertingAmplifier.svg
│  │        │  │  │  ├─ 📄InvertingSchmittTrigger.svg
│  │        │  │  │  ├─ 📄InvGate.svg
│  │        │  │  │  ├─ 📄I_constant.svg
│  │        │  │  │  ├─ 📄I_exp.svg
│  │        │  │  │  ├─ 📄I_pulse.svg
│  │        │  │  │  ├─ 📄I_pwl.svg
│  │        │  │  │  ├─ 📄I_sffm.svg
│  │        │  │  │  ├─ 📄I_sin.svg
│  │        │  │  │  ├─ 📄JFET.svg
│  │        │  │  │  ├─ 📄jfetCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄jfetInitEquations.svg
│  │        │  │  │  ├─ 📄JfetModelLine.svg
│  │        │  │  │  ├─ 📄jfetModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄jfetNoBypassCode.svg
│  │        │  │  │  ├─ 📄jfetRenameParameters.svg
│  │        │  │  │  ├─ 📄JKFF.svg
│  │        │  │  │  ├─ 📄junction2.svg
│  │        │  │  │  ├─ 📄junction2SPICE3BJT.svg
│  │        │  │  │  ├─ 📄junction2SPICE3MOSFETRevised.svg
│  │        │  │  │  ├─ 📄junction3.svg
│  │        │  │  │  ├─ 📄junctionCapCoeffs.svg
│  │        │  │  │  ├─ 📄junctionCapRevised.svg
│  │        │  │  │  ├─ 📄junctionCapTransTime.svg
│  │        │  │  │  ├─ 📄junctionParamDepTempSPICE3.svg
│  │        │  │  │  ├─ 📄junctionPotDepTemp.svg
│  │        │  │  │  ├─ 📄junctionVCrit.svg
│  │        │  │  │  ├─ 📄junctionVoltage23SPICE3.svg
│  │        │  │  │  ├─ 📄J_NJFJFET.svg
│  │        │  │  │  ├─ 📄J_PJFJFET.svg
│  │        │  │  │  ├─ 📄K_CoupledInductors.svg
│  │        │  │  │  ├─ 📄LCOscillator.svg
│  │        │  │  │  ├─ 📄LessThreshold.svg
│  │        │  │  │  ├─ 📄LimitedPI.svg
│  │        │  │  │  ├─ 📄limitJunctionVoltageRevised.svg
│  │        │  │  │  ├─ 📄LinearTemperatureCoefficient20.svg
│  │        │  │  │  ├─ 📄linearTemperatureDependency.svg
│  │        │  │  │  ├─ 📄Lines.svg
│  │        │  │  │  ├─ 📄Literature.svg
│  │        │  │  │  ├─ 📄Logic.svg
│  │        │  │  │  ├─ 📄LogicToBoolean.svg
│  │        │  │  │  ├─ 📄LogicToReal.svg
│  │        │  │  │  ├─ 📄LogicToUX01.svg
│  │        │  │  │  ├─ 📄LogicToX01.svg
│  │        │  │  │  ├─ 📄LogicToX01Z.svg
│  │        │  │  │  ├─ 📄Losses.svg
│  │        │  │  │  ├─ 📄LowPass.svg
│  │        │  │  │  ├─ 📄L_Inductor.svg
│  │        │  │  │  ├─ 📄Machine.svg
│  │        │  │  │  ├─ 📄Machines.svg
│  │        │  │  │  ├─ 📄MaterialParameters.svg
│  │        │  │  │  ├─ 📄MechanicalPowerSensor.svg
│  │        │  │  │  ├─ 📄Memories.svg
│  │        │  │  │  ├─ 📄MemoryBase.svg
│  │        │  │  │  ├─ 📄MIMO.svg
│  │        │  │  │  ├─ 📄MISO.svg
│  │        │  │  │  ├─ 📄MNmos.svg
│  │        │  │  │  ├─ 📄Model.svg
│  │        │  │  │  ├─ 📄ModelcardBJT.svg
│  │        │  │  │  ├─ 📄ModelcardBJT2.svg
│  │        │  │  │  ├─ 📄ModelcardC.svg
│  │        │  │  │  ├─ 📄ModelcardCAPACITOR.svg
│  │        │  │  │  ├─ 📄ModelcardDIODE.svg
│  │        │  │  │  ├─ 📄ModelcardJFET.svg
│  │        │  │  │  ├─ 📄ModelcardMOS.svg
│  │        │  │  │  ├─ 📄ModelcardMOS2.svg
│  │        │  │  │  ├─ 📄ModelcardR.svg
│  │        │  │  │  ├─ 📄ModelcardRESISTOR.svg
│  │        │  │  │  ├─ 📄MOS.svg
│  │        │  │  │  ├─ 📄Mos1.svg
│  │        │  │  │  ├─ 📄Mos1Calc.svg
│  │        │  │  │  ├─ 📄Mos1ModelLineParams.svg
│  │        │  │  │  ├─ 📄mos1ModelLineParamsInitEquations.svg
│  │        │  │  │  ├─ 📄mos1RenameParameters.svg
│  │        │  │  │  ├─ 📄mos1RenameParametersDev.svg
│  │        │  │  │  ├─ 📄MOS2.svg
│  │        │  │  │  ├─ 📄Mos2Calc.svg
│  │        │  │  │  ├─ 📄mos2CalcCalcTempDependenciesRevised.svg
│  │        │  │  │  ├─ 📄mos2CalcInitEquationsRevised.svg
│  │        │  │  │  ├─ 📄mos2CalcNoBypassCodeRevised.svg
│  │        │  │  │  ├─ 📄Mos2ModelLineParams.svg
│  │        │  │  │  ├─ 📄mos2ModelLineParamsInitEquationsRevised.svg
│  │        │  │  │  ├─ 📄Mos2ModelLineVariables.svg
│  │        │  │  │  ├─ 📄mos2RenameParametersDev.svg
│  │        │  │  │  ├─ 📄mos2RenameParametersRevised.svg
│  │        │  │  │  ├─ 📄MosCalc.svg
│  │        │  │  │  ├─ 📄mosCalcCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄mosCalcDEVqmeyer.svg
│  │        │  │  │  ├─ 📄mosCalcInitEquations.svg
│  │        │  │  │  ├─ 📄mosCalcNoBypassCode.svg
│  │        │  │  │  ├─ 📄Mosfet.svg
│  │        │  │  │  ├─ 📄MosfetCalc.svg
│  │        │  │  │  ├─ 📄mosfetInitEquations.svg
│  │        │  │  │  ├─ 📄MosfetModelLine.svg
│  │        │  │  │  ├─ 📄mosfetModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄MosfetModelLineParams.svg
│  │        │  │  │  ├─ 📄mosfetRenameParametersDev.svg
│  │        │  │  │  ├─ 📄MosModelLineParams.svg
│  │        │  │  │  ├─ 📄MosModelLineVariables.svg
│  │        │  │  │  ├─ 📄MPmos.svg
│  │        │  │  │  ├─ 📄MultiDelta.svg
│  │        │  │  │  ├─ 📄Multiplexer.svg
│  │        │  │  │  ├─ 📄Multiplexers.svg
│  │        │  │  │  ├─ 📄MultiSensor.svg
│  │        │  │  │  ├─ 📄MultiStar.svg
│  │        │  │  │  ├─ 📄MultiStarResistance.svg
│  │        │  │  │  ├─ 📄MultiTerminalBox.svg
│  │        │  │  │  ├─ 📄Multivibrator.svg
│  │        │  │  │  ├─ 📄MutualInductor.svg
│  │        │  │  │  ├─ 📄MUX2x1.svg
│  │        │  │  │  ├─ 📄MUX4.svg
│  │        │  │  │  ├─ 📄M_NMOS.svg
│  │        │  │  │  ├─ 📄M_NMOS2.svg
│  │        │  │  │  ├─ 📄M_OLine.svg
│  │        │  │  │  ├─ 📄M_PMOS.svg
│  │        │  │  │  ├─ 📄M_PMOS2.svg
│  │        │  │  │  ├─ 📄M_Transformer.svg
│  │        │  │  │  ├─ 📄NamingPrinciple.svg
│  │        │  │  │  ├─ 📄Nand.svg
│  │        │  │  │  ├─ 📄NandGate.svg
│  │        │  │  │  ├─ 📄NegativePin.svg
│  │        │  │  │  ├─ 📄NegativePlug.svg
│  │        │  │  │  ├─ 📄NMOS.svg
│  │        │  │  │  ├─ 📄NonInvertingAmplifier.svg
│  │        │  │  │  ├─ 📄NonlinearResistor.svg
│  │        │  │  │  ├─ 📄Nor.svg
│  │        │  │  │  ├─ 📄NorGate.svg
│  │        │  │  │  ├─ 📄Not.svg
│  │        │  │  │  ├─ 📄NPN.svg
│  │        │  │  │  ├─ 📄NRXFER.svg
│  │        │  │  │  ├─ 📄NRXFERGATE.svg
│  │        │  │  │  ├─ 📄numberOfSymmetricBaseSystems.svg
│  │        │  │  │  ├─ 📄NXFER.svg
│  │        │  │  │  ├─ 📄NXFERGATE.svg
│  │        │  │  │  ├─ 📄OLine.svg
│  │        │  │  │  ├─ 📄ONEBIT.svg
│  │        │  │  │  ├─ 📄OnePort.svg
│  │        │  │  │  ├─ 📄OpAmp.svg
│  │        │  │  │  ├─ 📄OpAmpCircuits.svg
│  │        │  │  │  ├─ 📄OpAmpDetailed.svg
│  │        │  │  │  ├─ 📄OpAmps.svg
│  │        │  │  │  ├─ 📄OpenerWithArc.svg
│  │        │  │  │  ├─ 📄Or.svg
│  │        │  │  │  ├─ 📄OrGate.svg
│  │        │  │  │  ├─ 📄Oscillator.svg
│  │        │  │  │  ├─ 📄Overview.svg
│  │        │  │  │  ├─ 📄OvervoltageProtection.svg
│  │        │  │  │  ├─ 📄ParallelResonance.svg
│  │        │  │  │  ├─ 📄ParameterHandling.svg
│  │        │  │  │  ├─ 📄Parameterization.svg
│  │        │  │  │  ├─ 📄ParameterRecords.svg
│  │        │  │  │  ├─ 📄PartialAirGap.svg
│  │        │  │  │  ├─ 📄PartialAirGapDC.svg
│  │        │  │  │  ├─ 📄PartialBasicDCMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicInductionMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicTransformer.svg
│  │        │  │  │  ├─ 📄PartialConditionalHeatPort.svg
│  │        │  │  │  ├─ 📄PartialControlledDCPM.svg
│  │        │  │  │  ├─ 📄PartialCore.svg
│  │        │  │  │  ├─ 📄PartialOpAmp.svg
│  │        │  │  │  ├─ 📄PartialPowerBalanceDCMachines.svg
│  │        │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalAmbientDCMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalPortDCMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalPortInductionMachines.svg
│  │        │  │  │  ├─ 📄PermanentMagnet.svg
│  │        │  │  │  ├─ 📄PermanentMagnetLosses.svg
│  │        │  │  │  ├─ 📄PermanentMagnetLossParameters.svg
│  │        │  │  │  ├─ 📄PermanentMagnetWithLosses.svg
│  │        │  │  │  ├─ 📄PerVolume.svg
│  │        │  │  │  ├─ 📄PhaseOrientation.svg
│  │        │  │  │  ├─ 📄PI.svg
│  │        │  │  │  ├─ 📄Pin.svg
│  │        │  │  │  ├─ 📄Plug.svg
│  │        │  │  │  ├─ 📄PlugToPins_n.svg
│  │        │  │  │  ├─ 📄PlugToPins_p.svg
│  │        │  │  │  ├─ 📄PlugToPin_n.svg
│  │        │  │  │  ├─ 📄PlugToPin_p.svg
│  │        │  │  │  ├─ 📄PMOS.svg
│  │        │  │  │  ├─ 📄PNP.svg
│  │        │  │  │  ├─ 📄poly.svg
│  │        │  │  │  ├─ 📄Polyphase.svg
│  │        │  │  │  ├─ 📄Polyphase2Level.svg
│  │        │  │  │  ├─ 📄PolyphaseRectifier.svg
│  │        │  │  │  ├─ 📄PolyphaseRectifierData.svg
│  │        │  │  │  ├─ 📄PolyphaseTriac.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel_R.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel_RL.svg
│  │        │  │  │  ├─ 📄PositionControlledDCPM.svg
│  │        │  │  │  ├─ 📄PositivePin.svg
│  │        │  │  │  ├─ 📄PositivePlug.svg
│  │        │  │  │  ├─ 📄PotentialSensor.svg
│  │        │  │  │  ├─ 📄Potentiometer.svg
│  │        │  │  │  ├─ 📄Power.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCCE.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCEE.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCPM.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCSE.svg
│  │        │  │  │  ├─ 📄PowerBalanceIMC.svg
│  │        │  │  │  ├─ 📄PowerBalanceIMS.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMEE.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMPM.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMR.svg
│  │        │  │  │  ├─ 📄PowerBalanceTransformer.svg
│  │        │  │  │  ├─ 📄PowerConverters.svg
│  │        │  │  │  ├─ 📄PowerSensor.svg
│  │        │  │  │  ├─ 📄PRXFERGATE.svg
│  │        │  │  │  ├─ 📄Pulse.svg
│  │        │  │  │  ├─ 📄PulseCurrent.svg
│  │        │  │  │  ├─ 📄PulseSeries.svg
│  │        │  │  │  ├─ 📄PulseVoltage.svg
│  │        │  │  │  ├─ 📄PWM.svg
│  │        │  │  │  ├─ 📄PWMType.svg
│  │        │  │  │  ├─ 📄PXFERGATE.svg
│  │        │  │  │  ├─ 📄QuasiRMS.svg
│  │        │  │  │  ├─ 📄QuasiStatic.svg
│  │        │  │  │  ├─ 📄QuasiStaticDCMachines.svg
│  │        │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.svg
│  │        │  │  │  ├─ 📄QuasiStaticMachine.svg
│  │        │  │  │  ├─ 📄QuasiStaticTransformer.svg
│  │        │  │  │  ├─ 📄Q_NPNBJT.svg
│  │        │  │  │  ├─ 📄Q_PNPBJT.svg
│  │        │  │  │  ├─ 📄RAM.svg
│  │        │  │  │  ├─ 📄RampCurrent.svg
│  │        │  │  │  ├─ 📄RampedRheostat.svg
│  │        │  │  │  ├─ 📄RampVoltage.svg
│  │        │  │  │  ├─ 📄RCData.svg
│  │        │  │  │  ├─ 📄ReactivePowerSensor.svg
│  │        │  │  │  ├─ 📄RealSwitch.svg
│  │        │  │  │  ├─ 📄RealToLogic.svg
│  │        │  │  │  ├─ 📄Rectifier.svg
│  │        │  │  │  ├─ 📄Rectifier12pulse.svg
│  │        │  │  │  ├─ 📄Rectifier1Pulse.svg
│  │        │  │  │  ├─ 📄Rectifier6pulse.svg
│  │        │  │  │  ├─ 📄RectifierBridge2mPulse.svg
│  │        │  │  │  ├─ 📄RectifierBridge2Pulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄Reference.svg
│  │        │  │  │  ├─ 📄ReferenceCurrentSource.svg
│  │        │  │  │  ├─ 📄References.svg
│  │        │  │  │  ├─ 📄ReferenceSensor.svg
│  │        │  │  │  ├─ 📄ReferenceSource.svg
│  │        │  │  │  ├─ 📄ReferenceSystem.svg
│  │        │  │  │  ├─ 📄ReferenceType.svg
│  │        │  │  │  ├─ 📄ReferenceVoltageSource.svg
│  │        │  │  │  ├─ 📄Registers.svg
│  │        │  │  │  ├─ 📄RelativeSensor.svg
│  │        │  │  │  ├─ 📄RelativeSensorElementary.svg
│  │        │  │  │  ├─ 📄ReleaseNotes.svg
│  │        │  │  │  ├─ 📄resDepGeom.svg
│  │        │  │  │  ├─ 📄resDepTemp.svg
│  │        │  │  │  ├─ 📄Resistor.svg
│  │        │  │  │  ├─ 📄resistorInitEquations.svg
│  │        │  │  │  ├─ 📄ResistorModelLineParams.svg
│  │        │  │  │  ├─ 📄ResistorParams.svg
│  │        │  │  │  ├─ 📄resistorRenameParameters.svg
│  │        │  │  │  ├─ 📄resistorRenameParametersDev.svg
│  │        │  │  │  ├─ 📄ResistorVariables.svg
│  │        │  │  │  ├─ 📄ResonanceCircuits.svg
│  │        │  │  │  ├─ 📄RotationalEMF.svg
│  │        │  │  │  ├─ 📄Rotator.svg
│  │        │  │  │  ├─ 📄RotorDisplacementAngle.svg
│  │        │  │  │  ├─ 📄RS.svg
│  │        │  │  │  ├─ 📄Rsemiconductor.svg
│  │        │  │  │  ├─ 📄RSFF.svg
│  │        │  │  │  ├─ 📄R_Resistor.svg
│  │        │  │  │  ├─ 📄R_SEMI.svg
│  │        │  │  │  ├─ 📄SaturatingInductor.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3JFET.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3MOSFET.svg
│  │        │  │  │  ├─ 📄SawToothCurrent.svg
│  │        │  │  │  ├─ 📄SawToothVoltage.svg
│  │        │  │  │  ├─ 📄SchmittTrigger.svg
│  │        │  │  │  ├─ 📄segment.svg
│  │        │  │  │  ├─ 📄segment_last.svg
│  │        │  │  │  ├─ 📄Semiconductors.svg
│  │        │  │  │  ├─ 📄Sensors.svg
│  │        │  │  │  ├─ 📄SeriesBode.svg
│  │        │  │  │  ├─ 📄SeriesResonance.svg
│  │        │  │  │  ├─ 📄Set.svg
│  │        │  │  │  ├─ 📄Short.svg
│  │        │  │  │  ├─ 📄ShowImpedance.svg
│  │        │  │  │  ├─ 📄ShowSaturatingInductor.svg
│  │        │  │  │  ├─ 📄ShowVariableResistor.svg
│  │        │  │  │  ├─ 📄Signal2mPulse.svg
│  │        │  │  │  ├─ 📄SignalCurrent.svg
│  │        │  │  │  ├─ 📄SignalGenerator.svg
│  │        │  │  │  ├─ 📄SignalPWM.svg
│  │        │  │  │  ├─ 📄SignalVoltage.svg
│  │        │  │  │  ├─ 📄SimpleTriac.svg
│  │        │  │  │  ├─ 📄SimpleTriacCircuit.svg
│  │        │  │  │  ├─ 📄SinCosEvaluation.svg
│  │        │  │  │  ├─ 📄SinCosResolver.svg
│  │        │  │  │  ├─ 📄SineCurrent.svg
│  │        │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄SineVoltage.svg
│  │        │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄SinglePhase.svg
│  │        │  │  │  ├─ 📄SinglePhase2Level.svg
│  │        │  │  │  ├─ 📄SinglePhaseTriac.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel_R.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel_RL.svg
│  │        │  │  │  ├─ 📄SingleToPolyphase.svg
│  │        │  │  │  ├─ 📄SISO.svg
│  │        │  │  │  ├─ 📄SMEE_DOL.svg
│  │        │  │  │  ├─ 📄SMEE_Generator.svg
│  │        │  │  │  ├─ 📄SMEE_LoadDump.svg
│  │        │  │  │  ├─ 📄SMEE_Rectifier.svg
│  │        │  │  │  ├─ 📄SMPM_Braking.svg
│  │        │  │  │  ├─ 📄SMPM_CurrentSource.svg
│  │        │  │  │  ├─ 📄SMPM_Inverter.svg
│  │        │  │  │  ├─ 📄SMPM_NoLoad.svg
│  │        │  │  │  ├─ 📄SMPM_ResistiveBraking.svg
│  │        │  │  │  ├─ 📄SMPM_VoltageSource.svg
│  │        │  │  │  ├─ 📄SMR_DOL.svg
│  │        │  │  │  ├─ 📄SMR_Inverter.svg
│  │        │  │  │  ├─ 📄SM_ElectricalExcited.svg
│  │        │  │  │  ├─ 📄SM_ElectricalExcitedData.svg
│  │        │  │  │  ├─ 📄SM_PermanentMagnet.svg
│  │        │  │  │  ├─ 📄SM_PermanentMagnetData.svg
│  │        │  │  │  ├─ 📄SM_ReluctanceRotor.svg
│  │        │  │  │  ├─ 📄SM_ReluctanceRotorData.svg
│  │        │  │  │  ├─ 📄SoftStartControl.svg
│  │        │  │  │  ├─ 📄SoftStarter.svg
│  │        │  │  │  ├─ 📄SoftStarterModeOfOperation.svg
│  │        │  │  │  ├─ 📄Source.svg
│  │        │  │  │  ├─ 📄Sources.svg
│  │        │  │  │  ├─ 📄SpacePhasor.svg
│  │        │  │  │  ├─ 📄SpacePhasors.svg
│  │        │  │  │  ├─ 📄SpeedControlledDCPM.svg
│  │        │  │  │  ├─ 📄Spice3.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkDifferentialPair.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkFourBitBinaryAdder.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkMosfetCharacterization.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkRtlInverter.svg
│  │        │  │  │  ├─ 📄SpiceConstants.svg
│  │        │  │  │  ├─ 📄Spicenetlist.svg
│  │        │  │  │  ├─ 📄SpiceRoot.svg
│  │        │  │  │  ├─ 📄SplitToSubsystems.svg
│  │        │  │  │  ├─ 📄SquirrelCage.svg
│  │        │  │  │  ├─ 📄Stack.svg
│  │        │  │  │  ├─ 📄StackBus.svg
│  │        │  │  │  ├─ 📄StackBusArrays.svg
│  │        │  │  │  ├─ 📄StackData.svg
│  │        │  │  │  ├─ 📄StackRC.svg
│  │        │  │  │  ├─ 📄Star.svg
│  │        │  │  │  ├─ 📄Step.svg
│  │        │  │  │  ├─ 📄StepCurrent.svg
│  │        │  │  │  ├─ 📄StepVoltage.svg
│  │        │  │  │  ├─ 📄StrayLoad.svg
│  │        │  │  │  ├─ 📄StrayLoadParameters.svg
│  │        │  │  │  ├─ 📄Strength.svg
│  │        │  │  │  ├─ 📄Subtracter.svg
│  │        │  │  │  ├─ 📄SuperCap.svg
│  │        │  │  │  ├─ 📄SuperCapDischargeCharge.svg
│  │        │  │  │  ├─ 📄SupplyVoltage.svg
│  │        │  │  │  ├─ 📄SVPWM.svg
│  │        │  │  │  ├─ 📄SwitchedCapacitor.svg
│  │        │  │  │  ├─ 📄SwitchedRheostat.svg
│  │        │  │  │  ├─ 📄SwitchingDcDc.svg
│  │        │  │  │  ├─ 📄SwitchWithArc.svg
│  │        │  │  │  ├─ 📄SwitchYD.svg
│  │        │  │  │  ├─ 📄SwitchYDwithArc.svg
│  │        │  │  │  ├─ 📄SymmetricalComponents.svg
│  │        │  │  │  ├─ 📄symmetricBackTransformationMatrix.svg
│  │        │  │  │  ├─ 📄symmetricOrientation.svg
│  │        │  │  │  ├─ 📄symmetricOrientationMatrix.svg
│  │        │  │  │  ├─ 📄symmetricTransformationMatrix.svg
│  │        │  │  │  ├─ 📄SynchronousMachineData.svg
│  │        │  │  │  ├─ 📄SynchronousMachines.svg
│  │        │  │  │  ├─ 📄Table.svg
│  │        │  │  │  ├─ 📄TableCurrent.svg
│  │        │  │  │  ├─ 📄Tables.svg
│  │        │  │  │  ├─ 📄TableVoltage.svg
│  │        │  │  │  ├─ 📄TerminalBox.svg
│  │        │  │  │  ├─ 📄TestSensors.svg
│  │        │  │  │  ├─ 📄Thermal.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCCE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCEE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCPM.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCSE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientIMC.svg
│  │        │  │  │  ├─ 📄ThermalAmbientIMS.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMEE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMPM.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMR.svg
│  │        │  │  │  ├─ 📄ThermalAmbientTransformer.svg
│  │        │  │  │  ├─ 📄ThermalPortDCCE.svg
│  │        │  │  │  ├─ 📄ThermalPortDCEE.svg
│  │        │  │  │  ├─ 📄ThermalPortDCPM.svg
│  │        │  │  │  ├─ 📄ThermalPortDCSE.svg
│  │        │  │  │  ├─ 📄ThermalPortIMC.svg
│  │        │  │  │  ├─ 📄ThermalPortIMS.svg
│  │        │  │  │  ├─ 📄ThermalPortSMEE.svg
│  │        │  │  │  ├─ 📄ThermalPortSMPM.svg
│  │        │  │  │  ├─ 📄ThermalPortSMR.svg
│  │        │  │  │  ├─ 📄ThermalPortTransformer.svg
│  │        │  │  │  ├─ 📄ThreePhaseTwoLevel_PWM.svg
│  │        │  │  │  ├─ 📄Thyristor.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse_R.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse_R_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorBehaviourTest.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄TLine1.svg
│  │        │  │  │  ├─ 📄TLine2.svg
│  │        │  │  │  ├─ 📄TLine3.svg
│  │        │  │  │  ├─ 📄ToDQ.svg
│  │        │  │  │  ├─ 📄ToPolar.svg
│  │        │  │  │  ├─ 📄ToSpacePhasor.svg
│  │        │  │  │  ├─ 📄Transformer.svg
│  │        │  │  │  ├─ 📄TransformerData.svg
│  │        │  │  │  ├─ 📄Transformers.svg
│  │        │  │  │  ├─ 📄TransformerTestbench.svg
│  │        │  │  │  ├─ 📄TransformerYD.svg
│  │        │  │  │  ├─ 📄TransformerYY.svg
│  │        │  │  │  ├─ 📄TransientCellRecord.svg
│  │        │  │  │  ├─ 📄TransientData.svg
│  │        │  │  │  ├─ 📄TransientMachine.svg
│  │        │  │  │  ├─ 📄TransientModel.svg
│  │        │  │  │  ├─ 📄TransientRecordsPackage.svg
│  │        │  │  │  ├─ 📄TransientStackRecord.svg
│  │        │  │  │  ├─ 📄TransientTransformer.svg
│  │        │  │  │  ├─ 📄Transistor.svg
│  │        │  │  │  ├─ 📄TranslationalEMF.svg
│  │        │  │  │  ├─ 📄TransportDelay.svg
│  │        │  │  │  ├─ 📄TrapezoidCurrent.svg
│  │        │  │  │  ├─ 📄TrapezoidVoltage.svg
│  │        │  │  │  ├─ 📄Tristates.svg
│  │        │  │  │  ├─ 📄TWOBIT.svg
│  │        │  │  │  ├─ 📄TwoPin.svg
│  │        │  │  │  ├─ 📄TwoPinElementary.svg
│  │        │  │  │  ├─ 📄TwoPlug.svg
│  │        │  │  │  ├─ 📄TwoPlugElementary.svg
│  │        │  │  │  ├─ 📄TwoPort.svg
│  │        │  │  │  ├─ 📄TwoPortControlledSources.svg
│  │        │  │  │  ├─ 📄Types.svg
│  │        │  │  │  ├─ 📄ULine.svg
│  │        │  │  │  ├─ 📄UnsymmetricalLoad.svg
│  │        │  │  │  ├─ 📄useInitialConditions.svg
│  │        │  │  │  ├─ 📄Useofsemiconductors.svg
│  │        │  │  │  ├─ 📄UsersGuide.svg
│  │        │  │  │  ├─ 📄Utilities.svg
│  │        │  │  │  ├─ 📄UX01.svg
│  │        │  │  │  ├─ 📄VariableAdmittance.svg
│  │        │  │  │  ├─ 📄VariableCapacitor.svg
│  │        │  │  │  ├─ 📄VariableConductor.svg
│  │        │  │  │  ├─ 📄VariableCurrentSource.svg
│  │        │  │  │  ├─ 📄VariableImpedance.svg
│  │        │  │  │  ├─ 📄VariableInductor.svg
│  │        │  │  │  ├─ 📄VariableResistor.svg
│  │        │  │  │  ├─ 📄VariableVoltageSource.svg
│  │        │  │  │  ├─ 📄VCC.svg
│  │        │  │  │  ├─ 📄VCV.svg
│  │        │  │  │  ├─ 📄VectorDelay.svg
│  │        │  │  │  ├─ 📄VfController.svg
│  │        │  │  │  ├─ 📄Voltage2AngleType.svg
│  │        │  │  │  ├─ 📄Voltage2DutyCycle.svg
│  │        │  │  │  ├─ 📄VoltageBridge2mPulse.svg
│  │        │  │  │  ├─ 📄VoltageBridge2Pulse.svg
│  │        │  │  │  ├─ 📄VoltageCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄VoltageFollower.svg
│  │        │  │  │  ├─ 📄VoltageQuasiRMSSensor.svg
│  │        │  │  │  ├─ 📄VoltageSensor.svg
│  │        │  │  │  ├─ 📄VoltageSource.svg
│  │        │  │  │  ├─ 📄VoltageSquare.svg
│  │        │  │  │  ├─ 📄VoltageToAngle.svg
│  │        │  │  │  ├─ 📄V_constant.svg
│  │        │  │  │  ├─ 📄V_exp.svg
│  │        │  │  │  ├─ 📄V_pulse.svg
│  │        │  │  │  ├─ 📄V_pwl.svg
│  │        │  │  │  ├─ 📄V_sffm.svg
│  │        │  │  │  ├─ 📄V_sin.svg
│  │        │  │  │  ├─ 📄WiredX.svg
│  │        │  │  │  ├─ 📄Xnor.svg
│  │        │  │  │  ├─ 📄XnorGate.svg
│  │        │  │  │  ├─ 📄Xor.svg
│  │        │  │  │  ├─ 📄XorGate.svg
│  │        │  │  │  ├─ 📄Yd.svg
│  │        │  │  │  ├─ 📄Yd01.svg
│  │        │  │  │  ├─ 📄Yd03.svg
│  │        │  │  │  ├─ 📄Yd05.svg
│  │        │  │  │  ├─ 📄Yd07.svg
│  │        │  │  │  ├─ 📄Yd09.svg
│  │        │  │  │  ├─ 📄Yd11.svg
│  │        │  │  │  ├─ 📄Yy.svg
│  │        │  │  │  ├─ 📄Yy00.svg
│  │        │  │  │  ├─ 📄Yy02.svg
│  │        │  │  │  ├─ 📄Yy04.svg
│  │        │  │  │  ├─ 📄Yy06.svg
│  │        │  │  │  ├─ 📄Yy08.svg
│  │        │  │  │  ├─ 📄Yy10.svg
│  │        │  │  │  ├─ 📄Yz.svg
│  │        │  │  │  ├─ 📄Yz01.svg
│  │        │  │  │  ├─ 📄Yz03.svg
│  │        │  │  │  ├─ 📄Yz05.svg
│  │        │  │  │  ├─ 📄Yz07.svg
│  │        │  │  │  ├─ 📄Yz09.svg
│  │        │  │  │  ├─ 📄Yz11.svg
│  │        │  │  │  ├─ 📄ZDiode.svg
│  │        │  │  │  └─ 📄ZeroInductor.svg
│  │        │  │  └─ 📄.gitkeep
│  │        │  └─ 📁component_source
│  │        │     ├─ 📁Blocks
│  │        │     │  ├─ 📄Continuous.mo
│  │        │     │  ├─ 📄Discrete.mo
│  │        │     │  ├─ 📄Icons.mo
│  │        │     │  ├─ 📄Interaction.mo
│  │        │     │  ├─ 📄Interfaces.mo
│  │        │     │  ├─ 📄Logical.mo
│  │        │     │  ├─ 📄Math.mo
│  │        │     │  ├─ 📄MathBoolean.mo
│  │        │     │  ├─ 📄MathInteger.mo
│  │        │     │  ├─ 📄Noise.mo
│  │        │     │  ├─ 📄Nonlinear.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  ├─ 📄Routing.mo
│  │        │     │  ├─ 📄Sources.mo
│  │        │     │  ├─ 📄Tables.mo
│  │        │     │  └─ 📄Types.mo
│  │        │     ├─ 📁Electrical
│  │        │     │  ├─ 📁Analog
│  │        │     │  │  ├─ 📁Basic
│  │        │     │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  ├─ 📄CCC.mo
│  │        │     │  │  │  ├─ 📄CCV.mo
│  │        │     │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.mo
│  │        │     │  │  │  ├─ 📄Ground.mo
│  │        │     │  │  │  ├─ 📄Gyrator.mo
│  │        │     │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  ├─ 📄M_Transformer.mo
│  │        │     │  │  │  ├─ 📄OpAmp.mo
│  │        │     │  │  │  ├─ 📄OpAmpDetailed.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Potentiometer.mo
│  │        │     │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  ├─ 📄RotationalEMF.mo
│  │        │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │        │     │  │  │  ├─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📄TranslationalEMF.mo
│  │        │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  ├─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📄VCC.mo
│  │        │     │  │  │  └─ 📄VCV.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  ├─ 📁Ideal
│  │        │     │  │  │  ├─ 📄AD_Converter.mo
│  │        │     │  │  │  ├─ 📄CloserWithArc.mo
│  │        │     │  │  │  ├─ 📄ControlledCloserWithArc.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledOpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄DA_Converter.mo
│  │        │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealDiode.mo
│  │        │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealizedOpAmpLimited.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmp.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmp3Pin.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmpLimited.mo
│  │        │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  ├─ 📄IdealTriac.mo
│  │        │     │  │  │  ├─ 📄IdealTwoWaySwitch.mo
│  │        │     │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Short.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  ├─ 📄FourPin.mo
│  │        │     │  │  │  ├─ 📄IdealSemiconductor.mo
│  │        │     │  │  │  ├─ 📄IdealSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealSwitchWithArc.mo
│  │        │     │  │  │  ├─ 📄NegativePin.mo
│  │        │     │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄Pin.mo
│  │        │     │  │  │  ├─ 📄PositivePin.mo
│  │        │     │  │  │  ├─ 📄RelativeSensor.mo
│  │        │     │  │  │  ├─ 📄TwoPin.mo
│  │        │     │  │  │  ├─ 📄TwoPort.mo
│  │        │     │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  ├─ 📁Lines
│  │        │     │  │  │  ├─ 📄M_OLine.mo
│  │        │     │  │  │  ├─ 📄OLine.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄TLine1.mo
│  │        │     │  │  │  ├─ 📄TLine2.mo
│  │        │     │  │  │  ├─ 📄TLine3.mo
│  │        │     │  │  │  └─ 📄ULine.mo
│  │        │     │  │  ├─ 📁Semiconductors
│  │        │     │  │  │  ├─ 📄Diode.mo
│  │        │     │  │  │  ├─ 📄Diode2.mo
│  │        │     │  │  │  ├─ 📄NMOS.mo
│  │        │     │  │  │  ├─ 📄NPN.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PMOS.mo
│  │        │     │  │  │  ├─ 📄PNP.mo
│  │        │     │  │  │  ├─ 📄SimpleTriac.mo
│  │        │     │  │  │  ├─ 📄Thyristor.mo
│  │        │     │  │  │  └─ 📄ZDiode.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │        │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineCurrent.mo
│  │        │     │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄CosineVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄ExponentialsCurrent.mo
│  │        │     │  │  │  ├─ 📄ExponentialsVoltage.mo
│  │        │     │  │  │  ├─ 📄ExpSineCurrent.mo
│  │        │     │  │  │  ├─ 📄ExpSineVoltage.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PulseCurrent.mo
│  │        │     │  │  │  ├─ 📄PulseVoltage.mo
│  │        │     │  │  │  ├─ 📄RampCurrent.mo
│  │        │     │  │  │  ├─ 📄RampVoltage.mo
│  │        │     │  │  │  ├─ 📄SawToothCurrent.mo
│  │        │     │  │  │  ├─ 📄SawToothVoltage.mo
│  │        │     │  │  │  ├─ 📄SignalCurrent.mo
│  │        │     │  │  │  ├─ 📄SignalVoltage.mo
│  │        │     │  │  │  ├─ 📄SineCurrent.mo
│  │        │     │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄SineVoltage.mo
│  │        │     │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄StepCurrent.mo
│  │        │     │  │  │  ├─ 📄StepVoltage.mo
│  │        │     │  │  │  ├─ 📄SupplyVoltage.mo
│  │        │     │  │  │  ├─ 📄TableCurrent.mo
│  │        │     │  │  │  ├─ 📄TableVoltage.mo
│  │        │     │  │  │  ├─ 📄TrapezoidCurrent.mo
│  │        │     │  │  │  └─ 📄TrapezoidVoltage.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Batteries
│  │        │     │  │  ├─ 📁BaseClasses
│  │        │     │  │  │  ├─ 📄BaseCellStack.mo
│  │        │     │  │  │  ├─ 📄BaseCellWithSensors.mo
│  │        │     │  │  │  ├─ 📄BaseStackData.mo
│  │        │     │  │  │  ├─ 📄BaseStackWithSensors.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁BatteryStacks
│  │        │     │  │  │  ├─ 📄CellRCStack.mo
│  │        │     │  │  │  ├─ 📄CellStack.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄SuperCap.mo
│  │        │     │  │  ├─ 📁BatteryStacksWithSensors
│  │        │     │  │  │  ├─ 📄Cell.mo
│  │        │     │  │  │  ├─ 📄CellRC.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Stack.mo
│  │        │     │  │  │  └─ 📄StackRC.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄BaseCellRecord.mo
│  │        │     │  │  │  ├─ 📄BaseStackRecord.mo
│  │        │     │  │  │  ├─ 📄BatteryIcon.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄TransientCellRecord.mo
│  │        │     │  │  │  ├─ 📄TransientModel.mo
│  │        │     │  │  │  ├─ 📄TransientRecordsPackage.mo
│  │        │     │  │  │  └─ 📄TransientStackRecord.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄CellBus.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄StackBus.mo
│  │        │     │  │  │  └─ 📄StackBusArrays.mo
│  │        │     │  │  ├─ 📁ParameterRecords
│  │        │     │  │  │  ├─ 📁TransientData
│  │        │     │  │  │  │  ├─ 📄CellData.mo
│  │        │     │  │  │  │  ├─ 📄ExampleData.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄RCData.mo
│  │        │     │  │  │  │  └─ 📄StackData.mo
│  │        │     │  │  │  ├─ 📄CellData.mo
│  │        │     │  │  │  ├─ 📄ExampleData.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄StackData.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Concept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Parameterization.mo
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📁Utilities
│  │        │     │  │  │  ├─ 📄BusTranscription.mo
│  │        │     │  │  │  ├─ 📄CCCVcharger.mo
│  │        │     │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄PulseSeries.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Machines
│  │        │     │  │  ├─ 📁BasicMachines
│  │        │     │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  ├─ 📄AirGapDC.mo
│  │        │     │  │  │  │  ├─ 📄AirGapR.mo
│  │        │     │  │  │  │  ├─ 📄AirGapS.mo
│  │        │     │  │  │  │  ├─ 📄CompoundDCExcitation.mo
│  │        │     │  │  │  │  ├─ 📄DamperCage.mo
│  │        │     │  │  │  │  ├─ 📄ElectricalExcitation.mo
│  │        │     │  │  │  │  ├─ 📄IdealCore.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄InductorDC.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialAirGap.mo
│  │        │     │  │  │  │  ├─ 📄PartialAirGapDC.mo
│  │        │     │  │  │  │  ├─ 📄PartialCore.mo
│  │        │     │  │  │  │  ├─ 📄PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄PermanentMagnetWithLosses.mo
│  │        │     │  │  │  │  └─ 📄SquirrelCage.mo
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄IM_SlipRing.mo
│  │        │     │  │  │  │  ├─ 📄IM_SquirrelCage.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁QuasiStaticDCMachines
│  │        │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SM_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄SM_PermanentMagnet.mo
│  │        │     │  │  │  │  └─ 📄SM_ReluctanceRotor.mo
│  │        │     │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  ├─ 📁Dd
│  │        │     │  │  │  │  │  ├─ 📄Dd00.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd02.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd04.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd06.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd08.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd10.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Dy
│  │        │     │  │  │  │  │  ├─ 📄Dy01.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy03.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy05.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy07.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy09.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy11.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Dz
│  │        │     │  │  │  │  │  ├─ 📄Dz00.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz02.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz04.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz06.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz08.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz10.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Yd
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yd01.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd03.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd05.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd07.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd09.mo
│  │        │     │  │  │  │  │  └─ 📄Yd11.mo
│  │        │     │  │  │  │  ├─ 📁Yy
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yy00.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy02.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy04.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy06.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy08.mo
│  │        │     │  │  │  │  │  └─ 📄Yy10.mo
│  │        │     │  │  │  │  ├─ 📁Yz
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yz01.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz03.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz05.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz07.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz09.mo
│  │        │     │  │  │  │  │  └─ 📄Yz11.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁ControlledDCDrives
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄Battery.mo
│  │        │     │  │  │  │  │  ├─ 📄DcdcInverter.mo
│  │        │     │  │  │  │  │  ├─ 📄DriveDataDCPM.mo
│  │        │     │  │  │  │  │  ├─ 📄IdealDcDc.mo
│  │        │     │  │  │  │  │  ├─ 📄LimitedPI.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄PartialControlledDCPM.mo
│  │        │     │  │  │  │  │  └─ 📄SwitchingDcDc.mo
│  │        │     │  │  │  │  ├─ 📄CurrentControlledDCPM.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PositionControlledDCPM.mo
│  │        │     │  │  │  │  └─ 📄SpeedControlledDCPM.mo
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄DCEE_Start.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Cooling.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_CurrentControlled.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_QuasiStatic.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Start.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Temperature.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_withLosses.mo
│  │        │     │  │  │  │  ├─ 📄DCSE_SinglePhase.mo
│  │        │     │  │  │  │  ├─ 📄DCSE_Start.mo
│  │        │     │  │  │  │  ├─ 📄DC_CompareCharacteristics.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄IMC_Conveyor.mo
│  │        │     │  │  │  │  ├─ 📄IMC_DCBraking.mo
│  │        │     │  │  │  │  ├─ 📄IMC_DOL.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Initialize.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Inverter.mo
│  │        │     │  │  │  │  ├─ 📄IMC_InverterDrive.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Steinmetz.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │        │     │  │  │  │  ├─ 📄IMC_withLosses.mo
│  │        │     │  │  │  │  ├─ 📄IMC_YD.mo
│  │        │     │  │  │  │  ├─ 📄IMC_YDarc.mo
│  │        │     │  │  │  │  ├─ 📄IMS_Start.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SMEE_DOL.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_Generator.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_LoadDump.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_Rectifier.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_Braking.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_Inverter.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_NoLoad.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_ResistiveBraking.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_VoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄SMR_DOL.mo
│  │        │     │  │  │  │  └─ 📄SMR_Inverter.mo
│  │        │     │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  ├─ 📄AsymmetricalLoad.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Rectifier12pulse.mo
│  │        │     │  │  │  │  ├─ 📄Rectifier6pulse.mo
│  │        │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Drive.mo
│  │        │     │  │  │  ├─ 📄FundamentalWaveMachine.mo
│  │        │     │  │  │  ├─ 📄Machine.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.mo
│  │        │     │  │  │  ├─ 📄QuasiStaticMachine.mo
│  │        │     │  │  │  ├─ 📄QuasiStaticTransformer.mo
│  │        │     │  │  │  ├─ 📄TransientMachine.mo
│  │        │     │  │  │  └─ 📄TransientTransformer.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalPortDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCCE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCEE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCPM.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCSE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCCE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalPortDCSE.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceIMC.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceIMS.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMEE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMPM.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMR.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortIMC.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortIMS.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortSMEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortSMPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalPortSMR.mo
│  │        │     │  │  │  ├─ 📄FlangeSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialBasicDCMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicInductionMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicTransformer.mo
│  │        │     │  │  │  ├─ 📄PowerBalanceTransformer.mo
│  │        │     │  │  │  ├─ 📄SpacePhasor.mo
│  │        │     │  │  │  └─ 📄ThermalPortTransformer.mo
│  │        │     │  │  ├─ 📁Losses
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄Brush.mo
│  │        │     │  │  │  │  ├─ 📄brushVoltageDrop.mo
│  │        │     │  │  │  │  ├─ 📄Core.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄StrayLoad.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄Brush.mo
│  │        │     │  │  │  │  ├─ 📄Core.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PermanentMagnetLosses.mo
│  │        │     │  │  │  │  └─ 📄StrayLoad.mo
│  │        │     │  │  │  ├─ 📄BrushParameters.mo
│  │        │     │  │  │  ├─ 📄CoreParameters.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄FrictionParameters.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PermanentMagnetLossParameters.mo
│  │        │     │  │  │  └─ 📄StrayLoadParameters.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  ├─ 📄ElectricalPowerSensor.mo
│  │        │     │  │  │  ├─ 📄HallSensor.mo
│  │        │     │  │  │  ├─ 📄MechanicalPowerSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RotorDisplacementAngle.mo
│  │        │     │  │  │  ├─ 📄SinCosResolver.mo
│  │        │     │  │  │  └─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  ├─ 📁SpacePhasors
│  │        │     │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  ├─ 📄FromPolar.mo
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄LessThreshold.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  ├─ 📄ToPolar.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  └─ 📄SpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Functions
│  │        │     │  │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  │  ├─ 📄FromPolar.mo
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄quasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  ├─ 📄ToPolar.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Thermal
│  │        │     │  │  │  ├─ 📁Constants
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCCE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientDCSE.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientIMC.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientIMS.mo
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientSMEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientSMPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientSMR.mo
│  │        │     │  │  │  ├─ 📄convertAlpha.mo
│  │        │     │  │  │  ├─ 📄convertResistance.mo
│  │        │     │  │  │  ├─ 📄LinearTemperatureCoefficient20.mo
│  │        │     │  │  │  ├─ 📄linearTemperatureDependency.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄ThermalAmbientTransformer.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Concept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Discrimination.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📁Utilities
│  │        │     │  │  │  ├─ 📁ParameterRecords
│  │        │     │  │  │  │  ├─ 📄DcElectricalExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄DcPermanentMagnetData.mo
│  │        │     │  │  │  │  ├─ 📄DcSeriesExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄IM_SlipRingData.mo
│  │        │     │  │  │  │  ├─ 📄IM_SquirrelCageData.mo
│  │        │     │  │  │  │  ├─ 📄InductionMachineData.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SM_ElectricalExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄SM_PermanentMagnetData.mo
│  │        │     │  │  │  │  ├─ 📄SM_ReluctanceRotorData.mo
│  │        │     │  │  │  │  └─ 📄TransformerData.mo
│  │        │     │  │  │  ├─ 📄DcBrakeSettings.mo
│  │        │     │  │  │  ├─ 📄DQCurrentController.mo
│  │        │     │  │  │  ├─ 📄DQToThreePhase.mo
│  │        │     │  │  │  ├─ 📄FromDQ.mo
│  │        │     │  │  │  ├─ 📄MultiTerminalBox.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RampedRheostat.mo
│  │        │     │  │  │  ├─ 📄SinCosEvaluation.mo
│  │        │     │  │  │  ├─ 📄SwitchedRheostat.mo
│  │        │     │  │  │  ├─ 📄SwitchYD.mo
│  │        │     │  │  │  ├─ 📄SwitchYDwithArc.mo
│  │        │     │  │  │  ├─ 📄SynchronousMachineData.mo
│  │        │     │  │  │  ├─ 📄TerminalBox.mo
│  │        │     │  │  │  ├─ 📄ToDQ.mo
│  │        │     │  │  │  ├─ 📄TransformerData.mo
│  │        │     │  │  │  └─ 📄VfController.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Polyphase
│  │        │     │  │  ├─ 📁Basic
│  │        │     │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  ├─ 📄Delta.mo
│  │        │     │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  ├─ 📄MultiDelta.mo
│  │        │     │  │  │  ├─ 📄MultiStar.mo
│  │        │     │  │  │  ├─ 📄MultiStarResistance.mo
│  │        │     │  │  │  ├─ 📄MutualInductor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PlugToPins_n.mo
│  │        │     │  │  │  ├─ 📄PlugToPins_p.mo
│  │        │     │  │  │  ├─ 📄PlugToPin_n.mo
│  │        │     │  │  │  ├─ 📄PlugToPin_p.mo
│  │        │     │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │        │     │  │  │  ├─ 📄SplitToSubsystems.mo
│  │        │     │  │  │  ├─ 📄Star.mo
│  │        │     │  │  │  ├─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  ├─ 📄VariableResistor.mo
│  │        │     │  │  │  └─ 📄ZeroInductor.mo
│  │        │     │  │  ├─ 📁Blocks
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄QuasiRMS.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄AnalysatorAC.mo
│  │        │     │  │  │  │  ├─ 📄AnalysatorDC.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄PolyphaseRectifierData.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PolyphaseRectifier.mo
│  │        │     │  │  │  ├─ 📄Rectifier.mo
│  │        │     │  │  │  ├─ 📄TestSensors.mo
│  │        │     │  │  │  ├─ 📄TransformerYD.mo
│  │        │     │  │  │  └─ 📄TransformerYY.mo
│  │        │     │  │  ├─ 📁Functions
│  │        │     │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  ├─ 📄factorY2D.mo
│  │        │     │  │  │  ├─ 📄factorY2DC.mo
│  │        │     │  │  │  ├─ 📄indexNonPositiveSequence.mo
│  │        │     │  │  │  ├─ 📄indexPositiveSequence.mo
│  │        │     │  │  │  ├─ 📄numberOfSymmetricBaseSystems.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄quasiRMS.mo
│  │        │     │  │  │  ├─ 📄symmetricBackTransformationMatrix.mo
│  │        │     │  │  │  ├─ 📄symmetricOrientation.mo
│  │        │     │  │  │  ├─ 📄symmetricOrientationMatrix.mo
│  │        │     │  │  │  └─ 📄symmetricTransformationMatrix.mo
│  │        │     │  │  ├─ 📁Ideal
│  │        │     │  │  │  ├─ 📄CloserWithArc.mo
│  │        │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealDiode.mo
│  │        │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Short.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄FourPlug.mo
│  │        │     │  │  │  ├─ 📄NegativePlug.mo
│  │        │     │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Plug.mo
│  │        │     │  │  │  ├─ 📄PositivePlug.mo
│  │        │     │  │  │  ├─ 📄TwoPlug.mo
│  │        │     │  │  │  └─ 📄TwoPort.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AronSensor.mo
│  │        │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │        │     │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │        │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineCurrent.mo
│  │        │     │  │  │  ├─ 📄CosineVoltage.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄SignalCurrent.mo
│  │        │     │  │  │  ├─ 📄SignalVoltage.mo
│  │        │     │  │  │  ├─ 📄SineCurrent.mo
│  │        │     │  │  │  └─ 📄SineVoltage.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PhaseOrientation.mo
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁PowerConverters
│  │        │     │  │  ├─ 📁ACAC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SoftStartControl.mo
│  │        │     │  │  │  │  └─ 📄VoltageToAngle.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PolyphaseTriac.mo
│  │        │     │  │  │  └─ 📄SinglePhaseTriac.mo
│  │        │     │  │  ├─ 📁ACDC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄Filter.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Signal2mPulse.mo
│  │        │     │  │  │  │  ├─ 📄VoltageBridge2mPulse.mo
│  │        │     │  │  │  │  ├─ 📄VoltageBridge2Pulse.mo
│  │        │     │  │  │  │  └─ 📄VoltageCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │        │     │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │        │     │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │        │     │  │  ├─ 📁DCAC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄IntersectivePWM.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PWM.mo
│  │        │     │  │  │  │  └─ 📄SVPWM.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Polyphase2Level.mo
│  │        │     │  │  │  └─ 📄SinglePhase2Level.mo
│  │        │     │  │  ├─ 📁DCDC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SignalPWM.mo
│  │        │     │  │  │  │  └─ 📄Voltage2DutyCycle.mo
│  │        │     │  │  │  ├─ 📄ChopperStepDown.mo
│  │        │     │  │  │  ├─ 📄ChopperStepUp.mo
│  │        │     │  │  │  ├─ 📄HBridge.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Enable
│  │        │     │  │  │  ├─ 📄EnableLogic.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁ACAC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄Dimmer.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Dimmer_R.mo
│  │        │     │  │  │  │  ├─ 📄Dimmer_RL.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄SoftStarter.mo
│  │        │     │  │  │  ├─ 📁ACDC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Thyristor1Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │        │     │  │  │  │  ├─ 📁Rectifier1Pulse
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.mo
│  │        │     │  │  │  │  │  └─ 📄Thyristor1Pulse_R_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierBridge2mPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorBridge2mPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierBridge2Pulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorBridge2Pulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTap2mPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTap2Pulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTapmPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCAC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel.mo
│  │        │     │  │  │  │  ├─ 📁PolyphaseTwoLevel
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.mo
│  │        │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.mo
│  │        │     │  │  │  │  │  └─ 📄ThreePhaseTwoLevel_PWM.mo
│  │        │     │  │  │  │  ├─ 📁SinglePhaseTwoLevel
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.mo
│  │        │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel_RL.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCDC
│  │        │     │  │  │  │  ├─ 📁ChopperStepDown
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁ChopperStepUp
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepUp_R.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown.mo
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepUp.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁HBridge
│  │        │     │  │  │  │  │  ├─ 📄HBridge_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge_R.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Control.mo
│  │        │     │  │  │  ├─ 📄Converter.mo
│  │        │     │  │  │  ├─ 📄ExampleTemplate.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📁ACDC
│  │        │     │  │  │  │  ├─ 📄ACplug.mo
│  │        │     │  │  │  │  ├─ 📄ACtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄ACtwoPlug.mo
│  │        │     │  │  │  │  ├─ 📄DCpin.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCAC
│  │        │     │  │  │  │  ├─ 📄ACpin.mo
│  │        │     │  │  │  │  ├─ 📄ACplug.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCDC
│  │        │     │  │  │  │  ├─ 📄DCtwoPin1.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin2.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Enable
│  │        │     │  │  │  │  ├─ 📄Enable.mo
│  │        │     │  │  │  │  ├─ 📄Enable1.mo
│  │        │     │  │  │  │  ├─ 📄Enable1m.mo
│  │        │     │  │  │  │  ├─ 📄Enable2.mo
│  │        │     │  │  │  │  ├─ 📄Enable2m.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PWMType.mo
│  │        │     │  │  │  ├─ 📄ReferenceType.mo
│  │        │     │  │  │  ├─ 📄SoftStarterModeOfOperation.mo
│  │        │     │  │  │  └─ 📄Voltage2AngleType.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄ACACConcept.mo
│  │        │     │  │  │  ├─ 📄ACDCConcept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄DCACConcept.mo
│  │        │     │  │  │  ├─ 📄DCDCConcept.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁QuasiStatic
│  │        │     │  │  ├─ 📁Machines
│  │        │     │  │  │  ├─ 📁BasicMachines
│  │        │     │  │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  │  ├─ 📄IdealCore.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄PartialCore.mo
│  │        │     │  │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  │  ├─ 📁Dd
│  │        │     │  │  │  │  │  │  ├─ 📄Dd00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd08.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd10.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Dy
│  │        │     │  │  │  │  │  │  ├─ 📄Dy01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy09.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy11.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Dz
│  │        │     │  │  │  │  │  │  ├─ 📄Dz00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz08.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz10.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Yd
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yd01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd09.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yd11.mo
│  │        │     │  │  │  │  │  ├─ 📁Yy
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yy00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy08.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yy10.mo
│  │        │     │  │  │  │  │  ├─ 📁Yz
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yz01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz09.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yz11.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄PartialBasicTransformer.mo
│  │        │     │  │  │  ├─ 📁SpacePhasors
│  │        │     │  │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Polyphase
│  │        │     │  │  │  ├─ 📁Basic
│  │        │     │  │  │  │  ├─ 📄Admittance.mo
│  │        │     │  │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  │  ├─ 📄Delta.mo
│  │        │     │  │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄MultiDelta.mo
│  │        │     │  │  │  │  ├─ 📄MultiStar.mo
│  │        │     │  │  │  │  ├─ 📄MultiStarResistance.mo
│  │        │     │  │  │  │  ├─ 📄MutualInductor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PlugToPins_n.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPins_p.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPin_n.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPin_p.mo
│  │        │     │  │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  │  ├─ 📄Star.mo
│  │        │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │        │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │        │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  │  └─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄FromSymmetricalComponents.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄SingleToPolyphase.mo
│  │        │     │  │  │  │  ├─ 📄SymmetricalComponents.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄BalancingDelta.mo
│  │        │     │  │  │  │  ├─ 📄BalancingStar.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄TestSensors.mo
│  │        │     │  │  │  │  └─ 📄UnsymmetricalLoad.mo
│  │        │     │  │  │  ├─ 📁Functions
│  │        │     │  │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄quasiRMS.mo
│  │        │     │  │  │  ├─ 📁Ideal
│  │        │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄Short.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄NegativePlug.mo
│  │        │     │  │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Plug.mo
│  │        │     │  │  │  │  ├─ 📄PositivePlug.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSource.mo
│  │        │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │        │     │  │  │  │  ├─ 📄Source.mo
│  │        │     │  │  │  │  ├─ 📄TwoPlug.mo
│  │        │     │  │  │  │  └─ 📄TwoPlugElementary.mo
│  │        │     │  │  │  ├─ 📁Sensors
│  │        │     │  │  │  │  ├─ 📄AronSensor.mo
│  │        │     │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │        │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │        │     │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  │  ├─ 📁Sources
│  │        │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ReferenceCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │        │     │  │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁SinglePhase
│  │        │     │  │  │  ├─ 📁Basic
│  │        │     │  │  │  │  ├─ 📄Admittance.mo
│  │        │     │  │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  │  ├─ 📄Ground.mo
│  │        │     │  │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │        │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │        │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  │  └─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ParallelResonance.mo
│  │        │     │  │  │  │  ├─ 📄Rectifier.mo
│  │        │     │  │  │  │  ├─ 📄SeriesBode.mo
│  │        │     │  │  │  │  ├─ 📄SeriesResonance.mo
│  │        │     │  │  │  │  └─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📁Ideal
│  │        │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄Short.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄NegativePin.mo
│  │        │     │  │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Pin.mo
│  │        │     │  │  │  │  ├─ 📄PositivePin.mo
│  │        │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │        │     │  │  │  │  ├─ 📄Source.mo
│  │        │     │  │  │  │  ├─ 📄TwoPin.mo
│  │        │     │  │  │  │  └─ 📄TwoPinElementary.mo
│  │        │     │  │  │  ├─ 📁Sensors
│  │        │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │        │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │        │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  │  ├─ 📁Sources
│  │        │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │        │     │  │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄GraetzRectifier.mo
│  │        │     │  │  │  │  ├─ 📄IdealACDCConverter.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Reference.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📁Overview
│  │        │     │  │  │  │  ├─ 📄ACCircuit.mo
│  │        │     │  │  │  │  ├─ 📄Introduction.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Power.mo
│  │        │     │  │  │  │  └─ 📄ReferenceSystem.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Glossar.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📄Digital.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  └─ 📄Spice3.mo
│  │        │     ├─ 📁Math
│  │        │     │  ├─ 📄BooleanVectors.mo
│  │        │     │  ├─ 📄Distributions.mo
│  │        │     │  ├─ 📄FastFourierTransform.mo
│  │        │     │  ├─ 📄isPowerOf2.mo
│  │        │     │  ├─ 📄Nonlinear.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  ├─ 📄Polynomials.mo
│  │        │     │  ├─ 📄Random.mo
│  │        │     │  ├─ 📄Special.mo
│  │        │     │  └─ 📄wrapAngle.mo
│  │        │     ├─ 📁Mechanics
│  │        │     │  ├─ 📁MultiBody
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Constraints
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PrismaticConstraint.mo
│  │        │     │  │  │  │  ├─ 📄RevoluteConstraint.mo
│  │        │     │  │  │  │  ├─ 📄SphericalConstraint.mo
│  │        │     │  │  │  │  └─ 📄UniversalConstraint.mo
│  │        │     │  │  │  ├─ 📁Elementary
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄sineSurface.mo
│  │        │     │  │  │  │  │  └─ 📄theoreticalNormalGravityWGS84.mo
│  │        │     │  │  │  │  ├─ 📄DoublePendulum.mo
│  │        │     │  │  │  │  ├─ 📄DoublePendulumInitTip.mo
│  │        │     │  │  │  │  ├─ 📄ForceAndTorque.mo
│  │        │     │  │  │  │  ├─ 📄FreeBody.mo
│  │        │     │  │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  │  ├─ 📄InitSpringConstant.mo
│  │        │     │  │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Pendulum.mo
│  │        │     │  │  │  │  ├─ 📄PendulumWithSpringDamper.mo
│  │        │     │  │  │  │  ├─ 📄PointGravity.mo
│  │        │     │  │  │  │  ├─ 📄PointGravityWithPointMasses.mo
│  │        │     │  │  │  │  ├─ 📄PointGravityWithPointMasses2.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheelSetDriving.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheelSetPulling.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamperSystem.mo
│  │        │     │  │  │  │  ├─ 📄SpringMassSystem.mo
│  │        │     │  │  │  │  ├─ 📄SpringWithMass.mo
│  │        │     │  │  │  │  ├─ 📄Surfaces.mo
│  │        │     │  │  │  │  ├─ 📄ThreeSprings.mo
│  │        │     │  │  │  │  └─ 📄UserDefinedGravityField.mo
│  │        │     │  │  │  ├─ 📁Loops
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄Cylinder.mo
│  │        │     │  │  │  │  │  ├─ 📄CylinderBase.mo
│  │        │     │  │  │  │  │  ├─ 📄Cylinder_analytic_CAD.mo
│  │        │     │  │  │  │  │  ├─ 📄Engine1Base.mo
│  │        │     │  │  │  │  │  ├─ 📄Engine1bBase.mo
│  │        │     │  │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │        │     │  │  │  │  │  ├─ 📄GasForce2.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Engine1a.mo
│  │        │     │  │  │  │  ├─ 📄Engine1b.mo
│  │        │     │  │  │  │  ├─ 📄Engine1b_analytic.mo
│  │        │     │  │  │  │  ├─ 📄EngineV6.mo
│  │        │     │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar1.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar2.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar_analytic.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PlanarFourbar.mo
│  │        │     │  │  │  │  └─ 📄PlanarLoops_analytic.mo
│  │        │     │  │  │  ├─ 📁Rotational3DEffects
│  │        │     │  │  │  │  ├─ 📄ActuatedDrive.mo
│  │        │     │  │  │  │  ├─ 📄BevelGear1D.mo
│  │        │     │  │  │  │  ├─ 📄GearConstraint.mo
│  │        │     │  │  │  │  ├─ 📄GyroscopicEffects.mo
│  │        │     │  │  │  │  ├─ 📄MovingActuatedDrive.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Systems
│  │        │     │  │  │  │  ├─ 📁RobotR3
│  │        │     │  │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  │  ├─ 📄AxisControlBus.mo
│  │        │     │  │  │  │  │  │  ├─ 📄AxisType1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄AxisType2.mo
│  │        │     │  │  │  │  │  │  ├─ 📄ControlBus.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Controller.mo
│  │        │     │  │  │  │  │  │  ├─ 📄GearType1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄GearType2.mo
│  │        │     │  │  │  │  │  │  ├─ 📄MechanicalStructure.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Motor.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄PathPlanning1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄PathPlanning6.mo
│  │        │     │  │  │  │  │  │  └─ 📄PathToAxisControlBus.mo
│  │        │     │  │  │  │  │  ├─ 📄FullRobot.mo
│  │        │     │  │  │  │  │  ├─ 📄OneAxis.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Forces
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄BasicForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicTorque.mo
│  │        │     │  │  │  │  ├─ 📄BasicWorldForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicWorldTorque.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄standardGravityAcceleration.mo
│  │        │     │  │  │  │  └─ 📄ZeroForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄Force.mo
│  │        │     │  │  │  ├─ 📄ForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄LineForceWithMass.mo
│  │        │     │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamperParallel.mo
│  │        │     │  │  │  ├─ 📄SpringDamperSeries.mo
│  │        │     │  │  │  ├─ 📄Torque.mo
│  │        │     │  │  │  ├─ 📄WorldForce.mo
│  │        │     │  │  │  ├─ 📄WorldForceAndTorque.mo
│  │        │     │  │  │  └─ 📄WorldTorque.mo
│  │        │     │  │  ├─ 📁Frames
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent.mo
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent_d.mo
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent_dd.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuaternionBase.mo
│  │        │     │  │  │  │  ├─ 📄resolve1_der.mo
│  │        │     │  │  │  │  ├─ 📄resolve2_der.mo
│  │        │     │  │  │  │  ├─ 📄resolveRelative_der.mo
│  │        │     │  │  │  │  └─ 📄TransformationMatrix.mo
│  │        │     │  │  │  ├─ 📁Quaternions
│  │        │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │        │     │  │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │        │     │  │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  │  └─ 📄to_T_inv.mo
│  │        │     │  │  │  ├─ 📁TransformationMatrices
│  │        │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  │  ├─ 📄axesRotations.mo
│  │        │     │  │  │  │  ├─ 📄axesRotationsAngles.mo
│  │        │     │  │  │  │  ├─ 📄axisRotation.mo
│  │        │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │        │     │  │  │  │  ├─ 📄from_nxy.mo
│  │        │     │  │  │  │  ├─ 📄from_nxz.mo
│  │        │     │  │  │  │  ├─ 📄from_Q.mo
│  │        │     │  │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │        │     │  │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  │  ├─ 📄planarRotationAngle.mo
│  │        │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  │  ├─ 📄resolveDyade1.mo
│  │        │     │  │  │  │  ├─ 📄resolveDyade2.mo
│  │        │     │  │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  │  ├─ 📄to_exy.mo
│  │        │     │  │  │  │  ├─ 📄to_Q.mo
│  │        │     │  │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  │  ├─ 📄to_T_inv.mo
│  │        │     │  │  │  │  └─ 📄to_vector.mo
│  │        │     │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  ├─ 📄axesRotations.mo
│  │        │     │  │  │  ├─ 📄axesRotationsAngles.mo
│  │        │     │  │  │  ├─ 📄axis.mo
│  │        │     │  │  │  ├─ 📄axisRotation.mo
│  │        │     │  │  │  ├─ 📄from_nxy.mo
│  │        │     │  │  │  ├─ 📄from_nxz.mo
│  │        │     │  │  │  ├─ 📄from_Q.mo
│  │        │     │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  ├─ 📄from_T2.mo
│  │        │     │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  ├─ 📄planarRotationAngle.mo
│  │        │     │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  ├─ 📄resolveDyade1.mo
│  │        │     │  │  │  ├─ 📄resolveDyade2.mo
│  │        │     │  │  │  ├─ 📄resolveRelative.mo
│  │        │     │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  ├─ 📄to_exy.mo
│  │        │     │  │  │  ├─ 📄to_Q.mo
│  │        │     │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  ├─ 📄to_T_inv.mo
│  │        │     │  │  │  └─ 📄to_vector.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Surface.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄FlangeWithBearing.mo
│  │        │     │  │  │  ├─ 📄FlangeWithBearingAdaptor.mo
│  │        │     │  │  │  ├─ 📄Frame.mo
│  │        │     │  │  │  ├─ 📄Frame_a.mo
│  │        │     │  │  │  ├─ 📄Frame_b.mo
│  │        │     │  │  │  ├─ 📄Frame_resolve.mo
│  │        │     │  │  │  ├─ 📄LineForceBase.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄partialColorMap.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryJoint.mo
│  │        │     │  │  │  ├─ 📄PartialForce.mo
│  │        │     │  │  │  ├─ 📄partialGravityAcceleration.mo
│  │        │     │  │  │  ├─ 📄PartialLineForce.mo
│  │        │     │  │  │  ├─ 📄PartialOneFrame_a.mo
│  │        │     │  │  │  ├─ 📄PartialOneFrame_b.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄partialSurfaceCharacteristic.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFrames.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFramesDoubleSize.mo
│  │        │     │  │  │  ├─ 📄PartialVisualizer.mo
│  │        │     │  │  │  └─ 📄ZeroPosition.mo
│  │        │     │  │  ├─ 📁Joints
│  │        │     │  │  │  ├─ 📁Assemblies
│  │        │     │  │  │  │  ├─ 📄JointRRP.mo
│  │        │     │  │  │  │  ├─ 📄JointRRR.mo
│  │        │     │  │  │  │  ├─ 📄JointSSP.mo
│  │        │     │  │  │  │  ├─ 📄JointSSR.mo
│  │        │     │  │  │  │  ├─ 📄JointUPS.mo
│  │        │     │  │  │  │  ├─ 📄JointUSP.mo
│  │        │     │  │  │  │  ├─ 📄JointUSR.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Constraints
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Prismatic.mo
│  │        │     │  │  │  │  ├─ 📄Revolute.mo
│  │        │     │  │  │  │  ├─ 📄Spherical.mo
│  │        │     │  │  │  │  └─ 📄Universal.mo
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄InitAngle.mo
│  │        │     │  │  │  │  ├─ 📄InitAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄InitPosition.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PrismaticWithLengthConstraint.mo
│  │        │     │  │  │  │  ├─ 📄RevoluteWithLengthConstraint.mo
│  │        │     │  │  │  │  └─ 📄RollingConstraintVerticalWheel.mo
│  │        │     │  │  │  ├─ 📄Cylindrical.mo
│  │        │     │  │  │  ├─ 📄FreeMotion.mo
│  │        │     │  │  │  ├─ 📄FreeMotionScalarInit.mo
│  │        │     │  │  │  ├─ 📄GearConstraint.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Planar.mo
│  │        │     │  │  │  ├─ 📄Prismatic.mo
│  │        │     │  │  │  ├─ 📄Revolute.mo
│  │        │     │  │  │  ├─ 📄RevolutePlanarLoopConstraint.mo
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │        │     │  │  │  ├─ 📄Spherical.mo
│  │        │     │  │  │  ├─ 📄SphericalSpherical.mo
│  │        │     │  │  │  ├─ 📄Universal.mo
│  │        │     │  │  │  └─ 📄UniversalSpherical.mo
│  │        │     │  │  ├─ 📁Parts
│  │        │     │  │  │  ├─ 📄BevelGear1D.mo
│  │        │     │  │  │  ├─ 📄Body.mo
│  │        │     │  │  │  ├─ 📄BodyBox.mo
│  │        │     │  │  │  ├─ 📄BodyCylinder.mo
│  │        │     │  │  │  ├─ 📄BodyShape.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄FixedRotation.mo
│  │        │     │  │  │  ├─ 📄FixedTranslation.mo
│  │        │     │  │  │  ├─ 📄Mounting1D.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PointMass.mo
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │        │     │  │  │  └─ 📄Rotor1D.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄BasicAbsoluteAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄BasicAbsolutePosition.mo
│  │        │     │  │  │  │  ├─ 📄BasicCutForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicCutTorque.mo
│  │        │     │  │  │  │  ├─ 📄BasicRelativeAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄BasicRelativePosition.mo
│  │        │     │  │  │  │  ├─ 📄BasicTransformAbsoluteVector.mo
│  │        │     │  │  │  │  ├─ 📄BasicTransformRelativeVector.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialAbsoluteBaseSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialCutForceBaseSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialCutForceSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialRelativeBaseSensor.mo
│  │        │     │  │  │  │  └─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄AbsoluteAngles.mo
│  │        │     │  │  │  ├─ 📄AbsoluteAngularVelocity.mo
│  │        │     │  │  │  ├─ 📄AbsolutePosition.mo
│  │        │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄AbsoluteVelocity.mo
│  │        │     │  │  │  ├─ 📄CutForce.mo
│  │        │     │  │  │  ├─ 📄CutForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄CutTorque.mo
│  │        │     │  │  │  ├─ 📄Distance.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Power.mo
│  │        │     │  │  │  ├─ 📄RelativeAngles.mo
│  │        │     │  │  │  ├─ 📄RelativeAngularVelocity.mo
│  │        │     │  │  │  ├─ 📄RelativePosition.mo
│  │        │     │  │  │  ├─ 📄RelativeSensor.mo
│  │        │     │  │  │  ├─ 📄RelativeVelocity.mo
│  │        │     │  │  │  ├─ 📄TransformAbsoluteVector.mo
│  │        │     │  │  │  └─ 📄TransformRelativeVector.mo
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📁Defaults
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄Axis.mo
│  │        │     │  │  │  ├─ 📄AxisLabel.mo
│  │        │     │  │  │  ├─ 📄Color.mo
│  │        │     │  │  │  ├─ 📄GravityTypes.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RealColor.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameA.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameAB.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameB.mo
│  │        │     │  │  │  ├─ 📄RotationSequence.mo
│  │        │     │  │  │  ├─ 📄RotationTypes.mo
│  │        │     │  │  │  ├─ 📄ShapeExtra.mo
│  │        │     │  │  │  ├─ 📄ShapeType.mo
│  │        │     │  │  │  ├─ 📄SpecularCoefficient.mo
│  │        │     │  │  │  └─ 📄VectorQuantity.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📁Tutorial
│  │        │     │  │  │  │  ├─ 📁LoopStructures
│  │        │     │  │  │  │  │  ├─ 📄AnalyticLoopHandling.mo
│  │        │     │  │  │  │  │  ├─ 📄Introduction.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄PlanarLoops.mo
│  │        │     │  │  │  │  ├─ 📄ConnectionOfLineForces.mo
│  │        │     │  │  │  │  ├─ 📄FirstExample.mo
│  │        │     │  │  │  │  ├─ 📄OverView.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Literature.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Visualizers
│  │        │     │  │  │  ├─ 📁Advanced
│  │        │     │  │  │  │  ├─ 📁SurfaceCharacteristics
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄pipeWithScalarField.mo
│  │        │     │  │  │  │  │  ├─ 📄rectangle.mo
│  │        │     │  │  │  │  │  └─ 📄torus.mo
│  │        │     │  │  │  │  ├─ 📄Arrow.mo
│  │        │     │  │  │  │  ├─ 📄DoubleArrow.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PipeWithScalarField.mo
│  │        │     │  │  │  │  ├─ 📄Shape.mo
│  │        │     │  │  │  │  ├─ 📄Surface.mo
│  │        │     │  │  │  │  └─ 📄Vector.mo
│  │        │     │  │  │  ├─ 📁Colors
│  │        │     │  │  │  │  ├─ 📁ColorMaps
│  │        │     │  │  │  │  │  ├─ 📄autumn.mo
│  │        │     │  │  │  │  │  ├─ 📄gray.mo
│  │        │     │  │  │  │  │  ├─ 📄hot.mo
│  │        │     │  │  │  │  │  ├─ 📄jet.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄spring.mo
│  │        │     │  │  │  │  │  ├─ 📄summer.mo
│  │        │     │  │  │  │  │  └─ 📄winter.mo
│  │        │     │  │  │  │  ├─ 📄colorMapToSvg.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄scalarToColor.mo
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄FixedLines.mo
│  │        │     │  │  │  │  ├─ 📄Lines.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄FixedArrow.mo
│  │        │     │  │  │  ├─ 📄FixedFrame.mo
│  │        │     │  │  │  ├─ 📄FixedShape.mo
│  │        │     │  │  │  ├─ 📄FixedShape2.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PipeWithScalarField.mo
│  │        │     │  │  │  ├─ 📄Rectangle.mo
│  │        │     │  │  │  ├─ 📄SignalArrow.mo
│  │        │     │  │  │  ├─ 📄Torus.mo
│  │        │     │  │  │  └─ 📄VoluminousWheel.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Rotational
│  │        │     │  │  ├─ 📁Components
│  │        │     │  │  │  ├─ 📄AngleToTorqueAdaptor.mo
│  │        │     │  │  │  ├─ 📄BearingFriction.mo
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄Clutch.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄Disc.mo
│  │        │     │  │  │  ├─ 📄ElastoBacklash.mo
│  │        │     │  │  │  ├─ 📄ElastoBacklash2.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄Gearbox.mo
│  │        │     │  │  │  ├─ 📄GeneralAngleToTorqueAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralTorqueToAngleAdaptor.mo
│  │        │     │  │  │  ├─ 📄IdealGear.mo
│  │        │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │        │     │  │  │  ├─ 📄IdealPlanetary.mo
│  │        │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │        │     │  │  │  ├─ 📄Inertia.mo
│  │        │     │  │  │  ├─ 📄InitializeFlange.mo
│  │        │     │  │  │  ├─ 📄LossyGear.mo
│  │        │     │  │  │  ├─ 📄OneWayClutch.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RelativeStates.mo
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  └─ 📄TorqueToAngleAdaptor.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄DirectInertia.mo
│  │        │     │  │  │  │  ├─ 📄InverseInertia.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │        │     │  │  │  ├─ 📄Backlash.mo
│  │        │     │  │  │  ├─ 📄CompareBrakingTorque.mo
│  │        │     │  │  │  ├─ 📄CoupledClutches.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │        │     │  │  │  ├─ 📄ElasticBearing.mo
│  │        │     │  │  │  ├─ 📄First.mo
│  │        │     │  │  │  ├─ 📄FirstGrounded.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │        │     │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo1.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo2.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo3.mo
│  │        │     │  │  │  ├─ 📄OneWayClutch.mo
│  │        │     │  │  │  ├─ 📄OneWayClutchDisengaged.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  └─ 📄SimpleGearShift.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Clutch.mo
│  │        │     │  │  │  ├─ 📄Gear.mo
│  │        │     │  │  │  ├─ 📄Gearbox.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄Flange.mo
│  │        │     │  │  │  ├─ 📄Flange_a.mo
│  │        │     │  │  │  ├─ 📄Flange_b.mo
│  │        │     │  │  │  ├─ 📄InternalSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄PartialCompliant.mo
│  │        │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialFriction.mo
│  │        │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄PartialTorque.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │        │     │  │  │  └─ 📄Support.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AccSensor.mo
│  │        │     │  │  │  ├─ 📄AngleSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄RelAccSensor.mo
│  │        │     │  │  │  ├─ 📄RelAngleSensor.mo
│  │        │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │        │     │  │  │  ├─ 📄SpeedSensor.mo
│  │        │     │  │  │  └─ 📄TorqueSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │        │     │  │  │  ├─ 📄ConstantTorque.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentTorque.mo
│  │        │     │  │  │  ├─ 📄InverseSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄LinearSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄Move.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Position.mo
│  │        │     │  │  │  ├─ 📄QuadraticSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄SignTorque.mo
│  │        │     │  │  │  ├─ 📄Speed.mo
│  │        │     │  │  │  ├─ 📄Torque.mo
│  │        │     │  │  │  ├─ 📄Torque2.mo
│  │        │     │  │  │  └─ 📄TorqueStep.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │        │     │  │  │  ├─ 📄ModelingOfFriction.mo
│  │        │     │  │  │  ├─ 📄Overview.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  ├─ 📄RequirementsForSimulationTool.mo
│  │        │     │  │  │  ├─ 📄SignConventions.mo
│  │        │     │  │  │  ├─ 📄StateSelection.mo
│  │        │     │  │  │  ├─ 📄SupportTorques.mo
│  │        │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Translational
│  │        │     │  │  ├─ 📁Components
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄ElastoGap.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄GeneralForceToPositionAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralPositionToForceAdaptor.mo
│  │        │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │        │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │        │     │  │  │  ├─ 📄InitializeFlange.mo
│  │        │     │  │  │  ├─ 📄Mass.mo
│  │        │     │  │  │  ├─ 📄MassWithStopAndFriction.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RelativeStates.mo
│  │        │     │  │  │  ├─ 📄Rod.mo
│  │        │     │  │  │  ├─ 📄RollingResistance.mo
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  ├─ 📄SupportFriction.mo
│  │        │     │  │  │  └─ 📄Vehicle.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄DirectMass.mo
│  │        │     │  │  │  │  ├─ 📄GenerateStribeckFrictionTable.mo
│  │        │     │  │  │  │  ├─ 📄InverseMass.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄CompareBrakingForce.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │        │     │  │  │  ├─ 📄ElastoGap.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │        │     │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  ├─ 📄InitialConditions.mo
│  │        │     │  │  │  ├─ 📄Oscillator.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PreLoad.mo
│  │        │     │  │  │  ├─ 📄Sensors.mo
│  │        │     │  │  │  ├─ 📄SignConvention.mo
│  │        │     │  │  │  ├─ 📄Vehicle.mo
│  │        │     │  │  │  └─ 📄WhyArrows.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄Flange.mo
│  │        │     │  │  │  ├─ 📄Flange_a.mo
│  │        │     │  │  │  ├─ 📄Flange_b.mo
│  │        │     │  │  │  ├─ 📄InternalSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄PartialCompliant.mo
│  │        │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialForce.mo
│  │        │     │  │  │  ├─ 📄PartialFriction.mo
│  │        │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄PartialRigid.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │        │     │  │  │  └─ 📄Support.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AccSensor.mo
│  │        │     │  │  │  ├─ 📄ForceSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PositionSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄RelAccSensor.mo
│  │        │     │  │  │  ├─ 📄RelPositionSensor.mo
│  │        │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │        │     │  │  │  └─ 📄SpeedSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄ConstantForce.mo
│  │        │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentForce.mo
│  │        │     │  │  │  ├─ 📄Force.mo
│  │        │     │  │  │  ├─ 📄Force2.mo
│  │        │     │  │  │  ├─ 📄ForceStep.mo
│  │        │     │  │  │  ├─ 📄InverseSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄LinearSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄Move.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Position.mo
│  │        │     │  │  │  ├─ 📄QuadraticSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄SignForce.mo
│  │        │     │  │  │  └─ 📄Speed.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │        │     │  │  │  ├─ 📄Overview.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄SignConventions.mo
│  │        │     │  │  │  ├─ 📄StateSelection.mo
│  │        │     │  │  │  ├─ 📄SupportForces.mo
│  │        │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📄package.mo
│  │        │     │  └─ 📄package.order
│  │        │     ├─ 📄.gitkeep
│  │        │     └─ 📄Untitled
│  │        ├─ 📄application-dev.yml
│  │        ├─ 📄application-prod.yml
│  │        └─ 📄application.yml
│  ├─ 📁target
│  │  ├─ 📁classes
│  │  │  ├─ 📁com
│  │  │  │  └─ 📁modelcloud
│  │  │  │     ├─ 📁common
│  │  │  │     │  ├─ 📁config
│  │  │  │     │  │  ├─ 📄AsyncConfig.class
│  │  │  │     │  │  ├─ 📄GiteaConfig.class
│  │  │  │     │  │  ├─ 📄MybatisConfig.class
│  │  │  │     │  │  ├─ 📄SecurityConfig.class
│  │  │  │     │  │  ├─ 📄SecurityUtilsConfig.class
│  │  │  │     │  │  └─ 📄WebConfig.class
│  │  │  │     │  ├─ 📁constant
│  │  │  │     │  │  └─ 📄CommonConstant.class
│  │  │  │     │  ├─ 📁exception
│  │  │  │     │  │  ├─ 📄BusinessException.class
│  │  │  │     │  │  └─ 📄GlobalExceptionHandler.class
│  │  │  │     │  ├─ 📁security
│  │  │  │     │  │  └─ 📄JwtAuthenticationFilter.class
│  │  │  │     │  ├─ 📁tools
│  │  │  │     │  │  ├─ 📄JwtUtil.class
│  │  │  │     │  │  ├─ 📄PasswordUtil.class
│  │  │  │     │  │  └─ 📄SecurityUtils.class
│  │  │  │     │  └─ 📁web
│  │  │  │     │     └─ 📁domain
│  │  │  │     │        ├─ 📁request
│  │  │  │     │        │  └─ 📄PageRequest.class
│  │  │  │     │        └─ 📁response
│  │  │  │     │           ├─ 📄Result.class
│  │  │  │     │           └─ 📄ResultCode.class
│  │  │  │     ├─ 📁modules
│  │  │  │     │  ├─ 📁auth
│  │  │  │     │  │  ├─ 📁controller
│  │  │  │     │  │  │  └─ 📄AuthController.class
│  │  │  │     │  │  ├─ 📁model
│  │  │  │     │  │  │  └─ 📁dto
│  │  │  │     │  │  │     ├─ 📄CaptchaResponse.class
│  │  │  │     │  │  │     ├─ 📄LoginRequest.class
│  │  │  │     │  │  │     ├─ 📄LoginResponse$UserInfo.class
│  │  │  │     │  │  │     ├─ 📄LoginResponse.class
│  │  │  │     │  │  │     └─ 📄RegisterRequest.class
│  │  │  │     │  │  └─ 📁service
│  │  │  │     │  │     ├─ 📁impl
│  │  │  │     │  │     │  ├─ 📄AuthServiceImpl.class
│  │  │  │     │  │     │  └─ 📄CaptchaServiceImpl.class
│  │  │  │     │  │     ├─ 📄AuthService.class
│  │  │  │     │  │     └─ 📄CaptchaService.class
│  │  │  │     │  ├─ 📁business
│  │  │  │     │  │  ├─ 📁controller
│  │  │  │     │  │  │  ├─ 📄BsModelCollectController.class
│  │  │  │     │  │  │  ├─ 📄BsModelController.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelController.class
│  │  │  │     │  │  │  ├─ 📄ModelDeployController.class
│  │  │  │     │  │  │  └─ 📄SseController.class
│  │  │  │     │  │  ├─ 📁event
│  │  │  │     │  │  │  └─ 📄VisitCountEvent.class
│  │  │  │     │  │  ├─ 📁mapper
│  │  │  │     │  │  │  ├─ 📄BsComponentMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelCollectMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelingProjectMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelMapper.class
│  │  │  │     │  │  │  ├─ 📄BsSimulationTaskMapper.class
│  │  │  │     │  │  │  └─ 📄ModelLabelCategoryMapper.class
│  │  │  │     │  │  ├─ 📁model
│  │  │  │     │  │  │  ├─ 📁domain
│  │  │  │     │  │  │  │  ├─ 📁table
│  │  │  │     │  │  │  │  │  ├─ 📄BsComponentTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelCollectTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelingProjectTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelLabelTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsSimulationTaskTableDef.class
│  │  │  │     │  │  │  │  │  └─ 📄ModelLabelCategoryTableDef.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponent.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta$ConnectorMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta$ParamMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc$ConnectorMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc$ParamMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc.class
│  │  │  │     │  │  │  │  ├─ 📄BsModel.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelCollect.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelingProject.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelLabel.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelParams.class
│  │  │  │     │  │  │  │  ├─ 📄BsSimulationTask.class
│  │  │  │     │  │  │  │  └─ 📄ModelLabelCategory.class
│  │  │  │     │  │  │  ├─ 📁dto
│  │  │  │     │  │  │  │  └─ 📄ComponentVO.class
│  │  │  │     │  │  │  └─ 📁request
│  │  │  │     │  │  │     ├─ 📄ComponentUploadRequest.class
│  │  │  │     │  │  │     ├─ 📄ModelingProjectRequest.class
│  │  │  │     │  │  │     ├─ 📄ModelUploadRequest.class
│  │  │  │     │  │  │     ├─ 📄SimulationRequest$SimulationParams.class
│  │  │  │     │  │  │     └─ 📄SimulationRequest.class
│  │  │  │     │  │  ├─ 📁repository
│  │  │  │     │  │  │  ├─ 📄BsComponentParseMetaOmcRepository.class
│  │  │  │     │  │  │  └─ 📄BsComponentParseMetaRepository.class
│  │  │  │     │  │  ├─ 📁service
│  │  │  │     │  │  │  ├─ 📁impl
│  │  │  │     │  │  │  │  ├─ 📄BsModelCollectServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelLabelServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄ModelDeployServiceImpl.class
│  │  │  │     │  │  │  │  └─ 📄ModelLabelCategoryServiceImpl.class
│  │  │  │     │  │  │  ├─ 📄BsModelCollectService.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelService.class
│  │  │  │     │  │  │  ├─ 📄BsModelService.class
│  │  │  │     │  │  │  ├─ 📄GiteaService.class
│  │  │  │     │  │  │  ├─ 📄ModelDeployService.class
│  │  │  │     │  │  │  └─ 📄ModelLabelCategoryService.class
│  │  │  │     │  │  └─ 📁utils
│  │  │  │     │  │     ├─ 📄ModelicaIconSvgRenderer.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ConnectorInfo.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ModelicaComponentInfo.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ParameterInfo.class
│  │  │  │     │  │     └─ 📄ModelicaParser.class
│  │  │  │     │  └─ 📁sys
│  │  │  │     │     ├─ 📁controller
│  │  │  │     │     │  └─ 📄SysUserController.class
│  │  │  │     │     ├─ 📁mapper
│  │  │  │     │     │  ├─ 📄SysRoleMapper.class
│  │  │  │     │     │  ├─ 📄SysSiteStatMapper.class
│  │  │  │     │     │  ├─ 📄SysUserMapper.class
│  │  │  │     │     │  └─ 📄SysUserRoleMapper.class
│  │  │  │     │     ├─ 📁model
│  │  │  │     │     │  ├─ 📁domain
│  │  │  │     │     │  │  ├─ 📁table
│  │  │  │     │     │  │  │  ├─ 📄SysFileTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysPowerTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysRoleTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysSiteStatTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysUserRoleTableDef.class
│  │  │  │     │     │  │  │  └─ 📄SysUserTableDef.class
│  │  │  │     │     │  │  ├─ 📄SysFile.class
│  │  │  │     │     │  │  ├─ 📄SysPower.class
│  │  │  │     │     │  │  ├─ 📄SysRole.class
│  │  │  │     │     │  │  ├─ 📄SysSiteStat.class
│  │  │  │     │     │  │  ├─ 📄SysUser.class
│  │  │  │     │     │  │  └─ 📄SysUserRole.class
│  │  │  │     │     │  └─ 📁dto
│  │  │  │     │     │     ├─ 📄ChangePasswordRequest.class
│  │  │  │     │     │     ├─ 📄ResetPasswordRequest.class
│  │  │  │     │     │     ├─ 📄RoleVO.class
│  │  │  │     │     │     ├─ 📄UserCreateRequest.class
│  │  │  │     │     │     ├─ 📄UserProfileUpdateRequest.class
│  │  │  │     │     │     ├─ 📄UserQueryRequest.class
│  │  │  │     │     │     ├─ 📄UserUpdateRequest.class
│  │  │  │     │     │     └─ 📄UserVO.class
│  │  │  │     │     └─ 📁service
│  │  │  │     │        ├─ 📁impl
│  │  │  │     │        │  ├─ 📄SiteStatServiceImpl.class
│  │  │  │     │        │  ├─ 📄SysRoleServiceImpl.class
│  │  │  │     │        │  └─ 📄SysUserServiceImpl.class
│  │  │  │     │        ├─ 📄SiteStatService.class
│  │  │  │     │        ├─ 📄SysRoleService.class
│  │  │  │     │        └─ 📄SysUserService.class
│  │  │  │     └─ 📄ModelCloudApplication.class
│  │  │  ├─ 📁mapper
│  │  │  │  └─ 📁business
│  │  │  │     └─ 📄BsModelMapper.xml
│  │  │  ├─ 📁static
│  │  │  │  ├─ 📁component_icon
│  │  │  │  │  ├─ 📁Electrical
│  │  │  │  │  │  ├─ 📄AbsoluteSensor.svg
│  │  │  │  │  │  ├─ 📄ACAC.svg
│  │  │  │  │  │  ├─ 📄ACACConcept.svg
│  │  │  │  │  │  ├─ 📄ACCircuit.svg
│  │  │  │  │  │  ├─ 📄ACDC.svg
│  │  │  │  │  │  ├─ 📄ACDCConcept.svg
│  │  │  │  │  │  ├─ 📄ACpin.svg
│  │  │  │  │  │  ├─ 📄ACplug.svg
│  │  │  │  │  │  ├─ 📄activePower.svg
│  │  │  │  │  │  ├─ 📄ACtwoPin.svg
│  │  │  │  │  │  ├─ 📄ACtwoPlug.svg
│  │  │  │  │  │  ├─ 📄Add.svg
│  │  │  │  │  │  ├─ 📄Adder.svg
│  │  │  │  │  │  ├─ 📄Adder4.svg
│  │  │  │  │  │  ├─ 📄Additionals.svg
│  │  │  │  │  │  ├─ 📄Admittance.svg
│  │  │  │  │  │  ├─ 📄AD_Converter.svg
│  │  │  │  │  │  ├─ 📄AD_DA_conversion.svg
│  │  │  │  │  │  ├─ 📄AirGapDC.svg
│  │  │  │  │  │  ├─ 📄AirGapR.svg
│  │  │  │  │  │  ├─ 📄AirGapS.svg
│  │  │  │  │  │  ├─ 📄AmplifierWithOpAmpDetailed.svg
│  │  │  │  │  │  ├─ 📄Analog.svg
│  │  │  │  │  │  ├─ 📄AnalysatorAC.svg
│  │  │  │  │  │  ├─ 📄AnalysatorDC.svg
│  │  │  │  │  │  ├─ 📄And.svg
│  │  │  │  │  │  ├─ 📄AndGate.svg
│  │  │  │  │  │  ├─ 📄AronSensor.svg
│  │  │  │  │  │  ├─ 📄AsymmetricalLoad.svg
│  │  │  │  │  │  ├─ 📄BalancingDelta.svg
│  │  │  │  │  │  ├─ 📄BalancingStar.svg
│  │  │  │  │  │  ├─ 📄BaseCellRecord.svg
│  │  │  │  │  │  ├─ 📄BaseCellStack.svg
│  │  │  │  │  │  ├─ 📄BaseCellWithSensors.svg
│  │  │  │  │  │  ├─ 📄BaseClasses.svg
│  │  │  │  │  │  ├─ 📄BaseStackData.svg
│  │  │  │  │  │  ├─ 📄BaseStackRecord.svg
│  │  │  │  │  │  ├─ 📄BaseStackWithSensors.svg
│  │  │  │  │  │  ├─ 📄Basic.svg
│  │  │  │  │  │  ├─ 📄BasicMachines.svg
│  │  │  │  │  │  ├─ 📄Batteries.svg
│  │  │  │  │  │  ├─ 📄Battery.svg
│  │  │  │  │  │  ├─ 📄BatteryDischargeCharge.svg
│  │  │  │  │  │  ├─ 📄BatteryIcon.svg
│  │  │  │  │  │  ├─ 📄BatteryStacks.svg
│  │  │  │  │  │  ├─ 📄BatteryStacksWithSensors.svg
│  │  │  │  │  │  ├─ 📄Bjt.svg
│  │  │  │  │  │  ├─ 📄BJT2.svg
│  │  │  │  │  │  ├─ 📄BjtCalc.svg
│  │  │  │  │  │  ├─ 📄bjtCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄bjtInitEquations.svg
│  │  │  │  │  │  ├─ 📄bjtModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄BjtModelLineParams.svg
│  │  │  │  │  │  ├─ 📄bjtNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄bjtRenameParameters.svg
│  │  │  │  │  │  ├─ 📄bjtRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄Blocks.svg
│  │  │  │  │  │  ├─ 📄BooleanToLogic.svg
│  │  │  │  │  │  ├─ 📄Brush.svg
│  │  │  │  │  │  ├─ 📄BrushParameters.svg
│  │  │  │  │  │  ├─ 📄brushVoltageDrop.svg
│  │  │  │  │  │  ├─ 📄BUF3S.svg
│  │  │  │  │  │  ├─ 📄BUF3SL.svg
│  │  │  │  │  │  ├─ 📄Buffer.svg
│  │  │  │  │  │  ├─ 📄BufGate.svg
│  │  │  │  │  │  ├─ 📄BusTranscription.svg
│  │  │  │  │  │  ├─ 📄calculateGateCap.svg
│  │  │  │  │  │  ├─ 📄Capacitance.svg
│  │  │  │  │  │  ├─ 📄Capacitor.svg
│  │  │  │  │  │  ├─ 📄capacitorInitEquations.svg
│  │  │  │  │  │  ├─ 📄CapacitorModelLineParams.svg
│  │  │  │  │  │  ├─ 📄capacitorRenameParameters.svg
│  │  │  │  │  │  ├─ 📄capacitorRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄capDepGeom.svg
│  │  │  │  │  │  ├─ 📄CascodeCircuit.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassAnalog.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassOPV.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassSC.svg
│  │  │  │  │  │  ├─ 📄CCC.svg
│  │  │  │  │  │  ├─ 📄CCCVcharger.svg
│  │  │  │  │  │  ├─ 📄CCCVcharging.svg
│  │  │  │  │  │  ├─ 📄CCCV_Cell.svg
│  │  │  │  │  │  ├─ 📄CCCV_CellRC.svg
│  │  │  │  │  │  ├─ 📄CCCV_Stack.svg
│  │  │  │  │  │  ├─ 📄CCCV_StackRC.svg
│  │  │  │  │  │  ├─ 📄CCV.svg
│  │  │  │  │  │  ├─ 📄Cell.svg
│  │  │  │  │  │  ├─ 📄CellBus.svg
│  │  │  │  │  │  ├─ 📄CellData.svg
│  │  │  │  │  │  ├─ 📄CellRC.svg
│  │  │  │  │  │  ├─ 📄CellRCStack.svg
│  │  │  │  │  │  ├─ 📄CellStack.svg
│  │  │  │  │  │  ├─ 📄CharacteristicIdealDiodes.svg
│  │  │  │  │  │  ├─ 📄CharacteristicThyristors.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown_R.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown_RL.svg
│  │  │  │  │  │  ├─ 📄ChopperStepUp.svg
│  │  │  │  │  │  ├─ 📄ChopperStepUp_R.svg
│  │  │  │  │  │  ├─ 📄ChuaCircuit.svg
│  │  │  │  │  │  ├─ 📄CloserWithArc.svg
│  │  │  │  │  │  ├─ 📄Comparator.svg
│  │  │  │  │  │  ├─ 📄CompareTransformers.svg
│  │  │  │  │  │  ├─ 📄Components.svg
│  │  │  │  │  │  ├─ 📄CompoundDCExcitation.svg
│  │  │  │  │  │  ├─ 📄Concept.svg
│  │  │  │  │  │  ├─ 📄ConditionalHeatPort.svg
│  │  │  │  │  │  ├─ 📄ConditionalSubstrate.svg
│  │  │  │  │  │  ├─ 📄Conductor.svg
│  │  │  │  │  │  ├─ 📄ConstantCurrent.svg
│  │  │  │  │  │  ├─ 📄Constants.svg
│  │  │  │  │  │  ├─ 📄ConstantVoltage.svg
│  │  │  │  │  │  ├─ 📄Contact.svg
│  │  │  │  │  │  ├─ 📄Control.svg
│  │  │  │  │  │  ├─ 📄ControlCircuit.svg
│  │  │  │  │  │  ├─ 📄ControlledCloserWithArc.svg
│  │  │  │  │  │  ├─ 📄ControlledDCDrives.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealClosingSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealOpeningSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledOpenerWithArc.svg
│  │  │  │  │  │  ├─ 📄ControlledSwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄convertAlpha.svg
│  │  │  │  │  │  ├─ 📄Converter.svg
│  │  │  │  │  │  ├─ 📄Converters.svg
│  │  │  │  │  │  ├─ 📄convertResistance.svg
│  │  │  │  │  │  ├─ 📄Core.svg
│  │  │  │  │  │  ├─ 📄CoreParameters.svg
│  │  │  │  │  │  ├─ 📄CosineCurrent.svg
│  │  │  │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄CosineVoltage.svg
│  │  │  │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄Counter.svg
│  │  │  │  │  │  ├─ 📄Counter3.svg
│  │  │  │  │  │  ├─ 📄CoupledInductors.svg
│  │  │  │  │  │  ├─ 📄Csemiconductor.svg
│  │  │  │  │  │  ├─ 📄CurrentControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.svg
│  │  │  │  │  │  ├─ 📄CurrentsCapacitances.svg
│  │  │  │  │  │  ├─ 📄CurrentSensor.svg
│  │  │  │  │  │  ├─ 📄CurrentSource.svg
│  │  │  │  │  │  ├─ 📄CurrrentsCapacitances.svg
│  │  │  │  │  │  ├─ 📄C_Capacitor.svg
│  │  │  │  │  │  ├─ 📄C_SEMI.svg
│  │  │  │  │  │  ├─ 📄DamperCage.svg
│  │  │  │  │  │  ├─ 📄DA_Converter.svg
│  │  │  │  │  │  ├─ 📄DCAC.svg
│  │  │  │  │  │  ├─ 📄DCACConcept.svg
│  │  │  │  │  │  ├─ 📄DcBrakeSettings.svg
│  │  │  │  │  │  ├─ 📄DCDC.svg
│  │  │  │  │  │  ├─ 📄DCDCConcept.svg
│  │  │  │  │  │  ├─ 📄DcdcInverter.svg
│  │  │  │  │  │  ├─ 📄DCEE_Start.svg
│  │  │  │  │  │  ├─ 📄DcElectricalExcitedData.svg
│  │  │  │  │  │  ├─ 📄DCMachines.svg
│  │  │  │  │  │  ├─ 📄DcPermanentMagnetData.svg
│  │  │  │  │  │  ├─ 📄DCpin.svg
│  │  │  │  │  │  ├─ 📄DCPM_Cooling.svg
│  │  │  │  │  │  ├─ 📄DCPM_CurrentControlled.svg
│  │  │  │  │  │  ├─ 📄DCPM_QuasiStatic.svg
│  │  │  │  │  │  ├─ 📄DCPM_Start.svg
│  │  │  │  │  │  ├─ 📄DCPM_Temperature.svg
│  │  │  │  │  │  ├─ 📄DCPM_withLosses.svg
│  │  │  │  │  │  ├─ 📄DcSeriesExcitedData.svg
│  │  │  │  │  │  ├─ 📄DCSE_SinglePhase.svg
│  │  │  │  │  │  ├─ 📄DCSE_Start.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin1.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin2.svg
│  │  │  │  │  │  ├─ 📄DC_CompareCharacteristics.svg
│  │  │  │  │  │  ├─ 📄DC_ElectricalExcited.svg
│  │  │  │  │  │  ├─ 📄DC_PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄DC_SeriesExcited.svg
│  │  │  │  │  │  ├─ 📄Dd.svg
│  │  │  │  │  │  ├─ 📄Dd00.svg
│  │  │  │  │  │  ├─ 📄Dd02.svg
│  │  │  │  │  │  ├─ 📄Dd04.svg
│  │  │  │  │  │  ├─ 📄Dd06.svg
│  │  │  │  │  │  ├─ 📄Dd08.svg
│  │  │  │  │  │  ├─ 📄Dd10.svg
│  │  │  │  │  │  ├─ 📄Delay.svg
│  │  │  │  │  │  ├─ 📄DelayParams.svg
│  │  │  │  │  │  ├─ 📄Delta.svg
│  │  │  │  │  │  ├─ 📄Der.svg
│  │  │  │  │  │  ├─ 📄Derivative.svg
│  │  │  │  │  │  ├─ 📄DEVqmeyer.svg
│  │  │  │  │  │  ├─ 📄DFF.svg
│  │  │  │  │  │  ├─ 📄DFFR.svg
│  │  │  │  │  │  ├─ 📄DFFREG.svg
│  │  │  │  │  │  ├─ 📄DFFREGL.svg
│  │  │  │  │  │  ├─ 📄DFFREGSRH.svg
│  │  │  │  │  │  ├─ 📄DFFREGSRL.svg
│  │  │  │  │  │  ├─ 📄DFFSR.svg
│  │  │  │  │  │  ├─ 📄DifferenceAmplifier.svg
│  │  │  │  │  │  ├─ 📄DifferentialAmplifier.svg
│  │  │  │  │  │  ├─ 📄DifferentialAmplifierData.svg
│  │  │  │  │  │  ├─ 📄Differentiator.svg
│  │  │  │  │  │  ├─ 📄Digital.svg
│  │  │  │  │  │  ├─ 📄DigitalClock.svg
│  │  │  │  │  │  ├─ 📄DigitalInput.svg
│  │  │  │  │  │  ├─ 📄DigitalOutput.svg
│  │  │  │  │  │  ├─ 📄DigitalSignal.svg
│  │  │  │  │  │  ├─ 📄Dimmer.svg
│  │  │  │  │  │  ├─ 📄Dimmer_R.svg
│  │  │  │  │  │  ├─ 📄Dimmer_RL.svg
│  │  │  │  │  │  ├─ 📄Diode.svg
│  │  │  │  │  │  ├─ 📄Diode2.svg
│  │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCalc.svg
│  │  │  │  │  │  ├─ 📄diodeCalcAdditionalValues.svg
│  │  │  │  │  │  ├─ 📄diodeCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄diodeInitEquations.svg
│  │  │  │  │  │  ├─ 📄diodeModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄DiodeModelLineParams.svg
│  │  │  │  │  │  ├─ 📄DiodeModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄diodeNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄DiodeParams.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParameters.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParametersDevTemp.svg
│  │  │  │  │  │  ├─ 📄DiodeVariables.svg
│  │  │  │  │  │  ├─ 📄DirectCapacitor.svg
│  │  │  │  │  │  ├─ 📄DirectInductor.svg
│  │  │  │  │  │  ├─ 📄Discrimination.svg
│  │  │  │  │  │  ├─ 📄DLATR.svg
│  │  │  │  │  │  ├─ 📄DLATRAM.svg
│  │  │  │  │  │  ├─ 📄DLATREG.svg
│  │  │  │  │  │  ├─ 📄DLATREGL.svg
│  │  │  │  │  │  ├─ 📄DLATREGSRH.svg
│  │  │  │  │  │  ├─ 📄DLATREGSRL.svg
│  │  │  │  │  │  ├─ 📄DLATROM.svg
│  │  │  │  │  │  ├─ 📄DLATSR.svg
│  │  │  │  │  │  ├─ 📄DQCurrentController.svg
│  │  │  │  │  │  ├─ 📄DQToThreePhase.svg
│  │  │  │  │  │  ├─ 📄drainCur.svg
│  │  │  │  │  │  ├─ 📄drainCurRevised.svg
│  │  │  │  │  │  ├─ 📄Drive.svg
│  │  │  │  │  │  ├─ 📄DriveDataDCPM.svg
│  │  │  │  │  │  ├─ 📄Dy.svg
│  │  │  │  │  │  ├─ 📄Dy01.svg
│  │  │  │  │  │  ├─ 📄Dy03.svg
│  │  │  │  │  │  ├─ 📄Dy05.svg
│  │  │  │  │  │  ├─ 📄Dy07.svg
│  │  │  │  │  │  ├─ 📄Dy09.svg
│  │  │  │  │  │  ├─ 📄Dy11.svg
│  │  │  │  │  │  ├─ 📄Dz.svg
│  │  │  │  │  │  ├─ 📄Dz00.svg
│  │  │  │  │  │  ├─ 📄Dz02.svg
│  │  │  │  │  │  ├─ 📄Dz04.svg
│  │  │  │  │  │  ├─ 📄Dz06.svg
│  │  │  │  │  │  ├─ 📄Dz08.svg
│  │  │  │  │  │  ├─ 📄Dz10.svg
│  │  │  │  │  │  ├─ 📄D_DIODE.svg
│  │  │  │  │  │  ├─ 📄Electrical.svg
│  │  │  │  │  │  ├─ 📄ElectricalExcitation.svg
│  │  │  │  │  │  ├─ 📄ElectricalPowerSensor.svg
│  │  │  │  │  │  ├─ 📄ElectricFieldStrength_cm.svg
│  │  │  │  │  │  ├─ 📄Enable.svg
│  │  │  │  │  │  ├─ 📄Enable1.svg
│  │  │  │  │  │  ├─ 📄Enable1m.svg
│  │  │  │  │  │  ├─ 📄Enable2.svg
│  │  │  │  │  │  ├─ 📄Enable2m.svg
│  │  │  │  │  │  ├─ 📄EnableLogic.svg
│  │  │  │  │  │  ├─ 📄energyGapDepTemp.svg
│  │  │  │  │  │  ├─ 📄energyGapDepTemp_old.svg
│  │  │  │  │  │  ├─ 📄equalityConstraint.svg
│  │  │  │  │  │  ├─ 📄ExampleData.svg
│  │  │  │  │  │  ├─ 📄Examples.svg
│  │  │  │  │  │  ├─ 📄ExampleTemplate.svg
│  │  │  │  │  │  ├─ 📄ExampleTemplates.svg
│  │  │  │  │  │  ├─ 📄ExponentialsCurrent.svg
│  │  │  │  │  │  ├─ 📄ExponentialsVoltage.svg
│  │  │  │  │  │  ├─ 📄ExpSineCurrent.svg
│  │  │  │  │  │  ├─ 📄ExpSineVoltage.svg
│  │  │  │  │  │  ├─ 📄E_VCV.svg
│  │  │  │  │  │  ├─ 📄E_VCV_POLY.svg
│  │  │  │  │  │  ├─ 📄factorY2D.svg
│  │  │  │  │  │  ├─ 📄factorY2DC.svg
│  │  │  │  │  │  ├─ 📄FCNiout_limit.svg
│  │  │  │  │  │  ├─ 📄FCNq_sum_limit.svg
│  │  │  │  │  │  ├─ 📄Feedback.svg
│  │  │  │  │  │  ├─ 📄Fet.svg
│  │  │  │  │  │  ├─ 📄FetModelLine.svg
│  │  │  │  │  │  ├─ 📄fetRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄Filter.svg
│  │  │  │  │  │  ├─ 📄FirstOrder.svg
│  │  │  │  │  │  ├─ 📄FlangeSupport.svg
│  │  │  │  │  │  ├─ 📄FlipFlop.svg
│  │  │  │  │  │  ├─ 📄FOURBIT.svg
│  │  │  │  │  │  ├─ 📄FourInverters.svg
│  │  │  │  │  │  ├─ 📄FourPin.svg
│  │  │  │  │  │  ├─ 📄FourPlug.svg
│  │  │  │  │  │  ├─ 📄FrequencySensor.svg
│  │  │  │  │  │  ├─ 📄FrequencySweepCurrentSource.svg
│  │  │  │  │  │  ├─ 📄FrequencySweepVoltageSource.svg
│  │  │  │  │  │  ├─ 📄Friction.svg
│  │  │  │  │  │  ├─ 📄FrictionParameters.svg
│  │  │  │  │  │  ├─ 📄FromDQ.svg
│  │  │  │  │  │  ├─ 📄FromPolar.svg
│  │  │  │  │  │  ├─ 📄FromSpacePhasor.svg
│  │  │  │  │  │  ├─ 📄FromSymmetricalComponents.svg
│  │  │  │  │  │  ├─ 📄FullAdder.svg
│  │  │  │  │  │  ├─ 📄Functions.svg
│  │  │  │  │  │  ├─ 📄FundamentalWaveMachine.svg
│  │  │  │  │  │  ├─ 📄F_CCC.svg
│  │  │  │  │  │  ├─ 📄F_CCC_POLY.svg
│  │  │  │  │  │  ├─ 📄Gain.svg
│  │  │  │  │  │  ├─ 📄GapEnergyPerEnergy.svg
│  │  │  │  │  │  ├─ 📄GapEnergyPerTemperature.svg
│  │  │  │  │  │  ├─ 📄Gates.svg
│  │  │  │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.svg
│  │  │  │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.svg
│  │  │  │  │  │  ├─ 📄GenerationOfFMUs.svg
│  │  │  │  │  │  ├─ 📄getMemory.svg
│  │  │  │  │  │  ├─ 📄getNumberOfElectricalPins.svg
│  │  │  │  │  │  ├─ 📄Glossar.svg
│  │  │  │  │  │  ├─ 📄Graetz.svg
│  │  │  │  │  │  ├─ 📄GraetzRectifier.svg
│  │  │  │  │  │  ├─ 📄Ground.svg
│  │  │  │  │  │  ├─ 📄Gyrator.svg
│  │  │  │  │  │  ├─ 📄G_VCC.svg
│  │  │  │  │  │  ├─ 📄G_VCC_POLY.svg
│  │  │  │  │  │  ├─ 📄HalfAdder.svg
│  │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄HallSensor.svg
│  │  │  │  │  │  ├─ 📄HBridge.svg
│  │  │  │  │  │  ├─ 📄HBridge_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄HBridge_R.svg
│  │  │  │  │  │  ├─ 📄HBridge_RL.svg
│  │  │  │  │  │  ├─ 📄HeatingMOSInverter.svg
│  │  │  │  │  │  ├─ 📄HeatingNPN_NORGate.svg
│  │  │  │  │  │  ├─ 📄HeatingPNP_NORGate.svg
│  │  │  │  │  │  ├─ 📄HeatingRectifier.svg
│  │  │  │  │  │  ├─ 📄HighPass.svg
│  │  │  │  │  │  ├─ 📄H_CCV.svg
│  │  │  │  │  │  ├─ 📄H_CCV_POLY.svg
│  │  │  │  │  │  ├─ 📄Icons.svg
│  │  │  │  │  │  ├─ 📄Ideal.svg
│  │  │  │  │  │  ├─ 📄IdealACDCConverter.svg
│  │  │  │  │  │  ├─ 📄IdealClosingSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealCommutingSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealCore.svg
│  │  │  │  │  │  ├─ 📄IdealDcDc.svg
│  │  │  │  │  │  ├─ 📄IdealDiode.svg
│  │  │  │  │  │  ├─ 📄IdealGTOThyristor.svg
│  │  │  │  │  │  ├─ 📄IdealIntermediateSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealizedOpAmpLimited.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmp.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmp3Pin.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmpLimited.svg
│  │  │  │  │  │  ├─ 📄IdealOpeningSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealSemiconductor.svg
│  │  │  │  │  │  ├─ 📄IdealSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealSwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄IdealThyristor.svg
│  │  │  │  │  │  ├─ 📄IdealTransformer.svg
│  │  │  │  │  │  ├─ 📄IdealTriac.svg
│  │  │  │  │  │  ├─ 📄IdealTriacCircuit.svg
│  │  │  │  │  │  ├─ 📄IdealTwoWaySwitch.svg
│  │  │  │  │  │  ├─ 📄Idle.svg
│  │  │  │  │  │  ├─ 📄IMC_Conveyor.svg
│  │  │  │  │  │  ├─ 📄IMC_DCBraking.svg
│  │  │  │  │  │  ├─ 📄IMC_DOL.svg
│  │  │  │  │  │  ├─ 📄IMC_Initialize.svg
│  │  │  │  │  │  ├─ 📄IMC_Inverter.svg
│  │  │  │  │  │  ├─ 📄IMC_InverterDrive.svg
│  │  │  │  │  │  ├─ 📄IMC_Steinmetz.svg
│  │  │  │  │  │  ├─ 📄IMC_Transformer.svg
│  │  │  │  │  │  ├─ 📄IMC_withLosses.svg
│  │  │  │  │  │  ├─ 📄IMC_YD.svg
│  │  │  │  │  │  ├─ 📄IMC_YDarc.svg
│  │  │  │  │  │  ├─ 📄Impedance.svg
│  │  │  │  │  │  ├─ 📄IMS_Start.svg
│  │  │  │  │  │  ├─ 📄IM_SlipRing.svg
│  │  │  │  │  │  ├─ 📄IM_SlipRingData.svg
│  │  │  │  │  │  ├─ 📄IM_SquirrelCage.svg
│  │  │  │  │  │  ├─ 📄IM_SquirrelCageData.svg
│  │  │  │  │  │  ├─ 📄index.html
│  │  │  │  │  │  ├─ 📄indexNonPositiveSequence.svg
│  │  │  │  │  │  ├─ 📄indexPositiveSequence.svg
│  │  │  │  │  │  ├─ 📄InductionMachineData.svg
│  │  │  │  │  │  ├─ 📄InductionMachines.svg
│  │  │  │  │  │  ├─ 📄InductiveCouplePinIn.svg
│  │  │  │  │  │  ├─ 📄InductiveCouplePinOut.svg
│  │  │  │  │  │  ├─ 📄Inductor.svg
│  │  │  │  │  │  ├─ 📄InductorDC.svg
│  │  │  │  │  │  ├─ 📄InertialDelay.svg
│  │  │  │  │  │  ├─ 📄InertialDelaySensitive.svg
│  │  │  │  │  │  ├─ 📄InertialDelaySensitiveVector.svg
│  │  │  │  │  │  ├─ 📄initJunctionVoltagesRevised.svg
│  │  │  │  │  │  ├─ 📄Integrator.svg
│  │  │  │  │  │  ├─ 📄Interfaces.svg
│  │  │  │  │  │  ├─ 📄Internal.svg
│  │  │  │  │  │  ├─ 📄IntersectivePWM.svg
│  │  │  │  │  │  ├─ 📄Introduction.svg
│  │  │  │  │  │  ├─ 📄INV3S.svg
│  │  │  │  │  │  ├─ 📄INV3SL.svg
│  │  │  │  │  │  ├─ 📄InverseCapacitor.svg
│  │  │  │  │  │  ├─ 📄InverseElectricCurrent.svg
│  │  │  │  │  │  ├─ 📄InverseInductor.svg
│  │  │  │  │  │  ├─ 📄Inverter.svg
│  │  │  │  │  │  ├─ 📄InvertersApartRecord.svg
│  │  │  │  │  │  ├─ 📄InvertersExtendedModel.svg
│  │  │  │  │  │  ├─ 📄InvertingAmp.svg
│  │  │  │  │  │  ├─ 📄InvertingAmplifier.svg
│  │  │  │  │  │  ├─ 📄InvertingSchmittTrigger.svg
│  │  │  │  │  │  ├─ 📄InvGate.svg
│  │  │  │  │  │  ├─ 📄I_constant.svg
│  │  │  │  │  │  ├─ 📄I_exp.svg
│  │  │  │  │  │  ├─ 📄I_pulse.svg
│  │  │  │  │  │  ├─ 📄I_pwl.svg
│  │  │  │  │  │  ├─ 📄I_sffm.svg
│  │  │  │  │  │  ├─ 📄I_sin.svg
│  │  │  │  │  │  ├─ 📄JFET.svg
│  │  │  │  │  │  ├─ 📄jfetCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄jfetInitEquations.svg
│  │  │  │  │  │  ├─ 📄JfetModelLine.svg
│  │  │  │  │  │  ├─ 📄jfetModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄jfetNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄jfetRenameParameters.svg
│  │  │  │  │  │  ├─ 📄JKFF.svg
│  │  │  │  │  │  ├─ 📄junction2.svg
│  │  │  │  │  │  ├─ 📄junction2SPICE3BJT.svg
│  │  │  │  │  │  ├─ 📄junction2SPICE3MOSFETRevised.svg
│  │  │  │  │  │  ├─ 📄junction3.svg
│  │  │  │  │  │  ├─ 📄junctionCapCoeffs.svg
│  │  │  │  │  │  ├─ 📄junctionCapRevised.svg
│  │  │  │  │  │  ├─ 📄junctionCapTransTime.svg
│  │  │  │  │  │  ├─ 📄junctionParamDepTempSPICE3.svg
│  │  │  │  │  │  ├─ 📄junctionPotDepTemp.svg
│  │  │  │  │  │  ├─ 📄junctionVCrit.svg
│  │  │  │  │  │  ├─ 📄junctionVoltage23SPICE3.svg
│  │  │  │  │  │  ├─ 📄J_NJFJFET.svg
│  │  │  │  │  │  ├─ 📄J_PJFJFET.svg
│  │  │  │  │  │  ├─ 📄K_CoupledInductors.svg
│  │  │  │  │  │  ├─ 📄LCOscillator.svg
│  │  │  │  │  │  ├─ 📄LessThreshold.svg
│  │  │  │  │  │  ├─ 📄LimitedPI.svg
│  │  │  │  │  │  ├─ 📄limitJunctionVoltageRevised.svg
│  │  │  │  │  │  ├─ 📄LinearTemperatureCoefficient20.svg
│  │  │  │  │  │  ├─ 📄linearTemperatureDependency.svg
│  │  │  │  │  │  ├─ 📄Lines.svg
│  │  │  │  │  │  ├─ 📄Literature.svg
│  │  │  │  │  │  ├─ 📄Logic.svg
│  │  │  │  │  │  ├─ 📄LogicToBoolean.svg
│  │  │  │  │  │  ├─ 📄LogicToReal.svg
│  │  │  │  │  │  ├─ 📄LogicToUX01.svg
│  │  │  │  │  │  ├─ 📄LogicToX01.svg
│  │  │  │  │  │  ├─ 📄LogicToX01Z.svg
│  │  │  │  │  │  ├─ 📄Losses.svg
│  │  │  │  │  │  ├─ 📄LowPass.svg
│  │  │  │  │  │  ├─ 📄L_Inductor.svg
│  │  │  │  │  │  ├─ 📄Machine.svg
│  │  │  │  │  │  ├─ 📄Machines.svg
│  │  │  │  │  │  ├─ 📄MaterialParameters.svg
│  │  │  │  │  │  ├─ 📄MechanicalPowerSensor.svg
│  │  │  │  │  │  ├─ 📄Memories.svg
│  │  │  │  │  │  ├─ 📄MemoryBase.svg
│  │  │  │  │  │  ├─ 📄MIMO.svg
│  │  │  │  │  │  ├─ 📄MISO.svg
│  │  │  │  │  │  ├─ 📄MNmos.svg
│  │  │  │  │  │  ├─ 📄Model.svg
│  │  │  │  │  │  ├─ 📄ModelcardBJT.svg
│  │  │  │  │  │  ├─ 📄ModelcardBJT2.svg
│  │  │  │  │  │  ├─ 📄ModelcardC.svg
│  │  │  │  │  │  ├─ 📄ModelcardCAPACITOR.svg
│  │  │  │  │  │  ├─ 📄ModelcardDIODE.svg
│  │  │  │  │  │  ├─ 📄ModelcardJFET.svg
│  │  │  │  │  │  ├─ 📄ModelcardMOS.svg
│  │  │  │  │  │  ├─ 📄ModelcardMOS2.svg
│  │  │  │  │  │  ├─ 📄ModelcardR.svg
│  │  │  │  │  │  ├─ 📄ModelcardRESISTOR.svg
│  │  │  │  │  │  ├─ 📄MOS.svg
│  │  │  │  │  │  ├─ 📄Mos1.svg
│  │  │  │  │  │  ├─ 📄Mos1Calc.svg
│  │  │  │  │  │  ├─ 📄Mos1ModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mos1ModelLineParamsInitEquations.svg
│  │  │  │  │  │  ├─ 📄mos1RenameParameters.svg
│  │  │  │  │  │  ├─ 📄mos1RenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄MOS2.svg
│  │  │  │  │  │  ├─ 📄Mos2Calc.svg
│  │  │  │  │  │  ├─ 📄mos2CalcCalcTempDependenciesRevised.svg
│  │  │  │  │  │  ├─ 📄mos2CalcInitEquationsRevised.svg
│  │  │  │  │  │  ├─ 📄mos2CalcNoBypassCodeRevised.svg
│  │  │  │  │  │  ├─ 📄Mos2ModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mos2ModelLineParamsInitEquationsRevised.svg
│  │  │  │  │  │  ├─ 📄Mos2ModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄mos2RenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄mos2RenameParametersRevised.svg
│  │  │  │  │  │  ├─ 📄MosCalc.svg
│  │  │  │  │  │  ├─ 📄mosCalcCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄mosCalcDEVqmeyer.svg
│  │  │  │  │  │  ├─ 📄mosCalcInitEquations.svg
│  │  │  │  │  │  ├─ 📄mosCalcNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄Mosfet.svg
│  │  │  │  │  │  ├─ 📄MosfetCalc.svg
│  │  │  │  │  │  ├─ 📄mosfetInitEquations.svg
│  │  │  │  │  │  ├─ 📄MosfetModelLine.svg
│  │  │  │  │  │  ├─ 📄mosfetModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄MosfetModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mosfetRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄MosModelLineParams.svg
│  │  │  │  │  │  ├─ 📄MosModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄MPmos.svg
│  │  │  │  │  │  ├─ 📄MultiDelta.svg
│  │  │  │  │  │  ├─ 📄Multiplexer.svg
│  │  │  │  │  │  ├─ 📄Multiplexers.svg
│  │  │  │  │  │  ├─ 📄MultiSensor.svg
│  │  │  │  │  │  ├─ 📄MultiStar.svg
│  │  │  │  │  │  ├─ 📄MultiStarResistance.svg
│  │  │  │  │  │  ├─ 📄MultiTerminalBox.svg
│  │  │  │  │  │  ├─ 📄Multivibrator.svg
│  │  │  │  │  │  ├─ 📄MutualInductor.svg
│  │  │  │  │  │  ├─ 📄MUX2x1.svg
│  │  │  │  │  │  ├─ 📄MUX4.svg
│  │  │  │  │  │  ├─ 📄M_NMOS.svg
│  │  │  │  │  │  ├─ 📄M_NMOS2.svg
│  │  │  │  │  │  ├─ 📄M_OLine.svg
│  │  │  │  │  │  ├─ 📄M_PMOS.svg
│  │  │  │  │  │  ├─ 📄M_PMOS2.svg
│  │  │  │  │  │  ├─ 📄M_Transformer.svg
│  │  │  │  │  │  ├─ 📄NamingPrinciple.svg
│  │  │  │  │  │  ├─ 📄Nand.svg
│  │  │  │  │  │  ├─ 📄NandGate.svg
│  │  │  │  │  │  ├─ 📄NegativePin.svg
│  │  │  │  │  │  ├─ 📄NegativePlug.svg
│  │  │  │  │  │  ├─ 📄NMOS.svg
│  │  │  │  │  │  ├─ 📄NonInvertingAmplifier.svg
│  │  │  │  │  │  ├─ 📄NonlinearResistor.svg
│  │  │  │  │  │  ├─ 📄Nor.svg
│  │  │  │  │  │  ├─ 📄NorGate.svg
│  │  │  │  │  │  ├─ 📄Not.svg
│  │  │  │  │  │  ├─ 📄NPN.svg
│  │  │  │  │  │  ├─ 📄NRXFER.svg
│  │  │  │  │  │  ├─ 📄NRXFERGATE.svg
│  │  │  │  │  │  ├─ 📄numberOfSymmetricBaseSystems.svg
│  │  │  │  │  │  ├─ 📄NXFER.svg
│  │  │  │  │  │  ├─ 📄NXFERGATE.svg
│  │  │  │  │  │  ├─ 📄OLine.svg
│  │  │  │  │  │  ├─ 📄ONEBIT.svg
│  │  │  │  │  │  ├─ 📄OnePort.svg
│  │  │  │  │  │  ├─ 📄OpAmp.svg
│  │  │  │  │  │  ├─ 📄OpAmpCircuits.svg
│  │  │  │  │  │  ├─ 📄OpAmpDetailed.svg
│  │  │  │  │  │  ├─ 📄OpAmps.svg
│  │  │  │  │  │  ├─ 📄OpenerWithArc.svg
│  │  │  │  │  │  ├─ 📄Or.svg
│  │  │  │  │  │  ├─ 📄OrGate.svg
│  │  │  │  │  │  ├─ 📄Oscillator.svg
│  │  │  │  │  │  ├─ 📄Overview.svg
│  │  │  │  │  │  ├─ 📄OvervoltageProtection.svg
│  │  │  │  │  │  ├─ 📄ParallelResonance.svg
│  │  │  │  │  │  ├─ 📄ParameterHandling.svg
│  │  │  │  │  │  ├─ 📄Parameterization.svg
│  │  │  │  │  │  ├─ 📄ParameterRecords.svg
│  │  │  │  │  │  ├─ 📄PartialAirGap.svg
│  │  │  │  │  │  ├─ 📄PartialAirGapDC.svg
│  │  │  │  │  │  ├─ 📄PartialBasicDCMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicInductionMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicTransformer.svg
│  │  │  │  │  │  ├─ 📄PartialConditionalHeatPort.svg
│  │  │  │  │  │  ├─ 📄PartialControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄PartialCore.svg
│  │  │  │  │  │  ├─ 📄PartialOpAmp.svg
│  │  │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalPortDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetLosses.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetLossParameters.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetWithLosses.svg
│  │  │  │  │  │  ├─ 📄PerVolume.svg
│  │  │  │  │  │  ├─ 📄PhaseOrientation.svg
│  │  │  │  │  │  ├─ 📄PI.svg
│  │  │  │  │  │  ├─ 📄Pin.svg
│  │  │  │  │  │  ├─ 📄Plug.svg
│  │  │  │  │  │  ├─ 📄PlugToPins_n.svg
│  │  │  │  │  │  ├─ 📄PlugToPins_p.svg
│  │  │  │  │  │  ├─ 📄PlugToPin_n.svg
│  │  │  │  │  │  ├─ 📄PlugToPin_p.svg
│  │  │  │  │  │  ├─ 📄PMOS.svg
│  │  │  │  │  │  ├─ 📄PNP.svg
│  │  │  │  │  │  ├─ 📄poly.svg
│  │  │  │  │  │  ├─ 📄Polyphase.svg
│  │  │  │  │  │  ├─ 📄Polyphase2Level.svg
│  │  │  │  │  │  ├─ 📄PolyphaseRectifier.svg
│  │  │  │  │  │  ├─ 📄PolyphaseRectifierData.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTriac.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.svg
│  │  │  │  │  │  ├─ 📄PositionControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄PositivePin.svg
│  │  │  │  │  │  ├─ 📄PositivePlug.svg
│  │  │  │  │  │  ├─ 📄PotentialSensor.svg
│  │  │  │  │  │  ├─ 📄Potentiometer.svg
│  │  │  │  │  │  ├─ 📄Power.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCCE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCEE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCPM.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCSE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceIMC.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceIMS.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMEE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMPM.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMR.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceTransformer.svg
│  │  │  │  │  │  ├─ 📄PowerConverters.svg
│  │  │  │  │  │  ├─ 📄PowerSensor.svg
│  │  │  │  │  │  ├─ 📄PRXFERGATE.svg
│  │  │  │  │  │  ├─ 📄Pulse.svg
│  │  │  │  │  │  ├─ 📄PulseCurrent.svg
│  │  │  │  │  │  ├─ 📄PulseSeries.svg
│  │  │  │  │  │  ├─ 📄PulseVoltage.svg
│  │  │  │  │  │  ├─ 📄PWM.svg
│  │  │  │  │  │  ├─ 📄PWMType.svg
│  │  │  │  │  │  ├─ 📄PXFERGATE.svg
│  │  │  │  │  │  ├─ 📄QuasiRMS.svg
│  │  │  │  │  │  ├─ 📄QuasiStatic.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticDCMachines.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticMachine.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticTransformer.svg
│  │  │  │  │  │  ├─ 📄Q_NPNBJT.svg
│  │  │  │  │  │  ├─ 📄Q_PNPBJT.svg
│  │  │  │  │  │  ├─ 📄RAM.svg
│  │  │  │  │  │  ├─ 📄RampCurrent.svg
│  │  │  │  │  │  ├─ 📄RampedRheostat.svg
│  │  │  │  │  │  ├─ 📄RampVoltage.svg
│  │  │  │  │  │  ├─ 📄RCData.svg
│  │  │  │  │  │  ├─ 📄ReactivePowerSensor.svg
│  │  │  │  │  │  ├─ 📄RealSwitch.svg
│  │  │  │  │  │  ├─ 📄RealToLogic.svg
│  │  │  │  │  │  ├─ 📄Rectifier.svg
│  │  │  │  │  │  ├─ 📄Rectifier12pulse.svg
│  │  │  │  │  │  ├─ 📄Rectifier1Pulse.svg
│  │  │  │  │  │  ├─ 📄Rectifier6pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄RectifierBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄Reference.svg
│  │  │  │  │  │  ├─ 📄ReferenceCurrentSource.svg
│  │  │  │  │  │  ├─ 📄References.svg
│  │  │  │  │  │  ├─ 📄ReferenceSensor.svg
│  │  │  │  │  │  ├─ 📄ReferenceSource.svg
│  │  │  │  │  │  ├─ 📄ReferenceSystem.svg
│  │  │  │  │  │  ├─ 📄ReferenceType.svg
│  │  │  │  │  │  ├─ 📄ReferenceVoltageSource.svg
│  │  │  │  │  │  ├─ 📄Registers.svg
│  │  │  │  │  │  ├─ 📄RelativeSensor.svg
│  │  │  │  │  │  ├─ 📄RelativeSensorElementary.svg
│  │  │  │  │  │  ├─ 📄ReleaseNotes.svg
│  │  │  │  │  │  ├─ 📄resDepGeom.svg
│  │  │  │  │  │  ├─ 📄resDepTemp.svg
│  │  │  │  │  │  ├─ 📄Resistor.svg
│  │  │  │  │  │  ├─ 📄resistorInitEquations.svg
│  │  │  │  │  │  ├─ 📄ResistorModelLineParams.svg
│  │  │  │  │  │  ├─ 📄ResistorParams.svg
│  │  │  │  │  │  ├─ 📄resistorRenameParameters.svg
│  │  │  │  │  │  ├─ 📄resistorRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄ResistorVariables.svg
│  │  │  │  │  │  ├─ 📄ResonanceCircuits.svg
│  │  │  │  │  │  ├─ 📄RotationalEMF.svg
│  │  │  │  │  │  ├─ 📄Rotator.svg
│  │  │  │  │  │  ├─ 📄RotorDisplacementAngle.svg
│  │  │  │  │  │  ├─ 📄RS.svg
│  │  │  │  │  │  ├─ 📄Rsemiconductor.svg
│  │  │  │  │  │  ├─ 📄RSFF.svg
│  │  │  │  │  │  ├─ 📄R_Resistor.svg
│  │  │  │  │  │  ├─ 📄R_SEMI.svg
│  │  │  │  │  │  ├─ 📄SaturatingInductor.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3JFET.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3MOSFET.svg
│  │  │  │  │  │  ├─ 📄SawToothCurrent.svg
│  │  │  │  │  │  ├─ 📄SawToothVoltage.svg
│  │  │  │  │  │  ├─ 📄SchmittTrigger.svg
│  │  │  │  │  │  ├─ 📄segment.svg
│  │  │  │  │  │  ├─ 📄segment_last.svg
│  │  │  │  │  │  ├─ 📄Semiconductors.svg
│  │  │  │  │  │  ├─ 📄Sensors.svg
│  │  │  │  │  │  ├─ 📄SeriesBode.svg
│  │  │  │  │  │  ├─ 📄SeriesResonance.svg
│  │  │  │  │  │  ├─ 📄Set.svg
│  │  │  │  │  │  ├─ 📄Short.svg
│  │  │  │  │  │  ├─ 📄ShowImpedance.svg
│  │  │  │  │  │  ├─ 📄ShowSaturatingInductor.svg
│  │  │  │  │  │  ├─ 📄ShowVariableResistor.svg
│  │  │  │  │  │  ├─ 📄Signal2mPulse.svg
│  │  │  │  │  │  ├─ 📄SignalCurrent.svg
│  │  │  │  │  │  ├─ 📄SignalGenerator.svg
│  │  │  │  │  │  ├─ 📄SignalPWM.svg
│  │  │  │  │  │  ├─ 📄SignalVoltage.svg
│  │  │  │  │  │  ├─ 📄SimpleTriac.svg
│  │  │  │  │  │  ├─ 📄SimpleTriacCircuit.svg
│  │  │  │  │  │  ├─ 📄SinCosEvaluation.svg
│  │  │  │  │  │  ├─ 📄SinCosResolver.svg
│  │  │  │  │  │  ├─ 📄SineCurrent.svg
│  │  │  │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄SineVoltage.svg
│  │  │  │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄SinglePhase.svg
│  │  │  │  │  │  ├─ 📄SinglePhase2Level.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTriac.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_RL.svg
│  │  │  │  │  │  ├─ 📄SingleToPolyphase.svg
│  │  │  │  │  │  ├─ 📄SISO.svg
│  │  │  │  │  │  ├─ 📄SMEE_DOL.svg
│  │  │  │  │  │  ├─ 📄SMEE_Generator.svg
│  │  │  │  │  │  ├─ 📄SMEE_LoadDump.svg
│  │  │  │  │  │  ├─ 📄SMEE_Rectifier.svg
│  │  │  │  │  │  ├─ 📄SMPM_Braking.svg
│  │  │  │  │  │  ├─ 📄SMPM_CurrentSource.svg
│  │  │  │  │  │  ├─ 📄SMPM_Inverter.svg
│  │  │  │  │  │  ├─ 📄SMPM_NoLoad.svg
│  │  │  │  │  │  ├─ 📄SMPM_ResistiveBraking.svg
│  │  │  │  │  │  ├─ 📄SMPM_VoltageSource.svg
│  │  │  │  │  │  ├─ 📄SMR_DOL.svg
│  │  │  │  │  │  ├─ 📄SMR_Inverter.svg
│  │  │  │  │  │  ├─ 📄SM_ElectricalExcited.svg
│  │  │  │  │  │  ├─ 📄SM_ElectricalExcitedData.svg
│  │  │  │  │  │  ├─ 📄SM_PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄SM_PermanentMagnetData.svg
│  │  │  │  │  │  ├─ 📄SM_ReluctanceRotor.svg
│  │  │  │  │  │  ├─ 📄SM_ReluctanceRotorData.svg
│  │  │  │  │  │  ├─ 📄SoftStartControl.svg
│  │  │  │  │  │  ├─ 📄SoftStarter.svg
│  │  │  │  │  │  ├─ 📄SoftStarterModeOfOperation.svg
│  │  │  │  │  │  ├─ 📄Source.svg
│  │  │  │  │  │  ├─ 📄Sources.svg
│  │  │  │  │  │  ├─ 📄SpacePhasor.svg
│  │  │  │  │  │  ├─ 📄SpacePhasors.svg
│  │  │  │  │  │  ├─ 📄SpeedControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄Spice3.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkDifferentialPair.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkFourBitBinaryAdder.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkMosfetCharacterization.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkRtlInverter.svg
│  │  │  │  │  │  ├─ 📄SpiceConstants.svg
│  │  │  │  │  │  ├─ 📄Spicenetlist.svg
│  │  │  │  │  │  ├─ 📄SpiceRoot.svg
│  │  │  │  │  │  ├─ 📄SplitToSubsystems.svg
│  │  │  │  │  │  ├─ 📄SquirrelCage.svg
│  │  │  │  │  │  ├─ 📄Stack.svg
│  │  │  │  │  │  ├─ 📄StackBus.svg
│  │  │  │  │  │  ├─ 📄StackBusArrays.svg
│  │  │  │  │  │  ├─ 📄StackData.svg
│  │  │  │  │  │  ├─ 📄StackRC.svg
│  │  │  │  │  │  ├─ 📄Star.svg
│  │  │  │  │  │  ├─ 📄Step.svg
│  │  │  │  │  │  ├─ 📄StepCurrent.svg
│  │  │  │  │  │  ├─ 📄StepVoltage.svg
│  │  │  │  │  │  ├─ 📄StrayLoad.svg
│  │  │  │  │  │  ├─ 📄StrayLoadParameters.svg
│  │  │  │  │  │  ├─ 📄Strength.svg
│  │  │  │  │  │  ├─ 📄Subtracter.svg
│  │  │  │  │  │  ├─ 📄SuperCap.svg
│  │  │  │  │  │  ├─ 📄SuperCapDischargeCharge.svg
│  │  │  │  │  │  ├─ 📄SupplyVoltage.svg
│  │  │  │  │  │  ├─ 📄SVPWM.svg
│  │  │  │  │  │  ├─ 📄SwitchedCapacitor.svg
│  │  │  │  │  │  ├─ 📄SwitchedRheostat.svg
│  │  │  │  │  │  ├─ 📄SwitchingDcDc.svg
│  │  │  │  │  │  ├─ 📄SwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄SwitchYD.svg
│  │  │  │  │  │  ├─ 📄SwitchYDwithArc.svg
│  │  │  │  │  │  ├─ 📄SymmetricalComponents.svg
│  │  │  │  │  │  ├─ 📄symmetricBackTransformationMatrix.svg
│  │  │  │  │  │  ├─ 📄symmetricOrientation.svg
│  │  │  │  │  │  ├─ 📄symmetricOrientationMatrix.svg
│  │  │  │  │  │  ├─ 📄symmetricTransformationMatrix.svg
│  │  │  │  │  │  ├─ 📄SynchronousMachineData.svg
│  │  │  │  │  │  ├─ 📄SynchronousMachines.svg
│  │  │  │  │  │  ├─ 📄Table.svg
│  │  │  │  │  │  ├─ 📄TableCurrent.svg
│  │  │  │  │  │  ├─ 📄Tables.svg
│  │  │  │  │  │  ├─ 📄TableVoltage.svg
│  │  │  │  │  │  ├─ 📄TerminalBox.svg
│  │  │  │  │  │  ├─ 📄TestSensors.svg
│  │  │  │  │  │  ├─ 📄Thermal.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCCE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCEE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCPM.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCSE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientIMC.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientIMS.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMEE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMPM.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMR.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientTransformer.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCCE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCEE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCPM.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCSE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortIMC.svg
│  │  │  │  │  │  ├─ 📄ThermalPortIMS.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMEE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMPM.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMR.svg
│  │  │  │  │  │  ├─ 📄ThermalPortTransformer.svg
│  │  │  │  │  │  ├─ 📄ThreePhaseTwoLevel_PWM.svg
│  │  │  │  │  │  ├─ 📄Thyristor.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse_R_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorBehaviourTest.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄TLine1.svg
│  │  │  │  │  │  ├─ 📄TLine2.svg
│  │  │  │  │  │  ├─ 📄TLine3.svg
│  │  │  │  │  │  ├─ 📄ToDQ.svg
│  │  │  │  │  │  ├─ 📄ToPolar.svg
│  │  │  │  │  │  ├─ 📄ToSpacePhasor.svg
│  │  │  │  │  │  ├─ 📄Transformer.svg
│  │  │  │  │  │  ├─ 📄TransformerData.svg
│  │  │  │  │  │  ├─ 📄Transformers.svg
│  │  │  │  │  │  ├─ 📄TransformerTestbench.svg
│  │  │  │  │  │  ├─ 📄TransformerYD.svg
│  │  │  │  │  │  ├─ 📄TransformerYY.svg
│  │  │  │  │  │  ├─ 📄TransientCellRecord.svg
│  │  │  │  │  │  ├─ 📄TransientData.svg
│  │  │  │  │  │  ├─ 📄TransientMachine.svg
│  │  │  │  │  │  ├─ 📄TransientModel.svg
│  │  │  │  │  │  ├─ 📄TransientRecordsPackage.svg
│  │  │  │  │  │  ├─ 📄TransientStackRecord.svg
│  │  │  │  │  │  ├─ 📄TransientTransformer.svg
│  │  │  │  │  │  ├─ 📄Transistor.svg
│  │  │  │  │  │  ├─ 📄TranslationalEMF.svg
│  │  │  │  │  │  ├─ 📄TransportDelay.svg
│  │  │  │  │  │  ├─ 📄TrapezoidCurrent.svg
│  │  │  │  │  │  ├─ 📄TrapezoidVoltage.svg
│  │  │  │  │  │  ├─ 📄Tristates.svg
│  │  │  │  │  │  ├─ 📄TWOBIT.svg
│  │  │  │  │  │  ├─ 📄TwoPin.svg
│  │  │  │  │  │  ├─ 📄TwoPinElementary.svg
│  │  │  │  │  │  ├─ 📄TwoPlug.svg
│  │  │  │  │  │  ├─ 📄TwoPlugElementary.svg
│  │  │  │  │  │  ├─ 📄TwoPort.svg
│  │  │  │  │  │  ├─ 📄TwoPortControlledSources.svg
│  │  │  │  │  │  ├─ 📄Types.svg
│  │  │  │  │  │  ├─ 📄ULine.svg
│  │  │  │  │  │  ├─ 📄UnsymmetricalLoad.svg
│  │  │  │  │  │  ├─ 📄useInitialConditions.svg
│  │  │  │  │  │  ├─ 📄Useofsemiconductors.svg
│  │  │  │  │  │  ├─ 📄UsersGuide.svg
│  │  │  │  │  │  ├─ 📄Utilities.svg
│  │  │  │  │  │  ├─ 📄UX01.svg
│  │  │  │  │  │  ├─ 📄VariableAdmittance.svg
│  │  │  │  │  │  ├─ 📄VariableCapacitor.svg
│  │  │  │  │  │  ├─ 📄VariableConductor.svg
│  │  │  │  │  │  ├─ 📄VariableCurrentSource.svg
│  │  │  │  │  │  ├─ 📄VariableImpedance.svg
│  │  │  │  │  │  ├─ 📄VariableInductor.svg
│  │  │  │  │  │  ├─ 📄VariableResistor.svg
│  │  │  │  │  │  ├─ 📄VariableVoltageSource.svg
│  │  │  │  │  │  ├─ 📄VCC.svg
│  │  │  │  │  │  ├─ 📄VCV.svg
│  │  │  │  │  │  ├─ 📄VectorDelay.svg
│  │  │  │  │  │  ├─ 📄VfController.svg
│  │  │  │  │  │  ├─ 📄Voltage2AngleType.svg
│  │  │  │  │  │  ├─ 📄Voltage2DutyCycle.svg
│  │  │  │  │  │  ├─ 📄VoltageBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄VoltageBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄VoltageCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄VoltageFollower.svg
│  │  │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.svg
│  │  │  │  │  │  ├─ 📄VoltageSensor.svg
│  │  │  │  │  │  ├─ 📄VoltageSource.svg
│  │  │  │  │  │  ├─ 📄VoltageSquare.svg
│  │  │  │  │  │  ├─ 📄VoltageToAngle.svg
│  │  │  │  │  │  ├─ 📄V_constant.svg
│  │  │  │  │  │  ├─ 📄V_exp.svg
│  │  │  │  │  │  ├─ 📄V_pulse.svg
│  │  │  │  │  │  ├─ 📄V_pwl.svg
│  │  │  │  │  │  ├─ 📄V_sffm.svg
│  │  │  │  │  │  ├─ 📄V_sin.svg
│  │  │  │  │  │  ├─ 📄WiredX.svg
│  │  │  │  │  │  ├─ 📄Xnor.svg
│  │  │  │  │  │  ├─ 📄XnorGate.svg
│  │  │  │  │  │  ├─ 📄Xor.svg
│  │  │  │  │  │  ├─ 📄XorGate.svg
│  │  │  │  │  │  ├─ 📄Yd.svg
│  │  │  │  │  │  ├─ 📄Yd01.svg
│  │  │  │  │  │  ├─ 📄Yd03.svg
│  │  │  │  │  │  ├─ 📄Yd05.svg
│  │  │  │  │  │  ├─ 📄Yd07.svg
│  │  │  │  │  │  ├─ 📄Yd09.svg
│  │  │  │  │  │  ├─ 📄Yd11.svg
│  │  │  │  │  │  ├─ 📄Yy.svg
│  │  │  │  │  │  ├─ 📄Yy00.svg
│  │  │  │  │  │  ├─ 📄Yy02.svg
│  │  │  │  │  │  ├─ 📄Yy04.svg
│  │  │  │  │  │  ├─ 📄Yy06.svg
│  │  │  │  │  │  ├─ 📄Yy08.svg
│  │  │  │  │  │  ├─ 📄Yy10.svg
│  │  │  │  │  │  ├─ 📄Yz.svg
│  │  │  │  │  │  ├─ 📄Yz01.svg
│  │  │  │  │  │  ├─ 📄Yz03.svg
│  │  │  │  │  │  ├─ 📄Yz05.svg
│  │  │  │  │  │  ├─ 📄Yz07.svg
│  │  │  │  │  │  ├─ 📄Yz09.svg
│  │  │  │  │  │  ├─ 📄Yz11.svg
│  │  │  │  │  │  ├─ 📄ZDiode.svg
│  │  │  │  │  │  └─ 📄ZeroInductor.svg
│  │  │  │  │  └─ 📄.gitkeep
│  │  │  │  └─ 📁component_source
│  │  │  │     ├─ 📁Blocks
│  │  │  │     │  ├─ 📄Continuous.mo
│  │  │  │     │  ├─ 📄Discrete.mo
│  │  │  │     │  ├─ 📄Icons.mo
│  │  │  │     │  ├─ 📄Interaction.mo
│  │  │  │     │  ├─ 📄Interfaces.mo
│  │  │  │     │  ├─ 📄Logical.mo
│  │  │  │     │  ├─ 📄Math.mo
│  │  │  │     │  ├─ 📄MathBoolean.mo
│  │  │  │     │  ├─ 📄MathInteger.mo
│  │  │  │     │  ├─ 📄Noise.mo
│  │  │  │     │  ├─ 📄Nonlinear.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  ├─ 📄Routing.mo
│  │  │  │     │  ├─ 📄Sources.mo
│  │  │  │     │  ├─ 📄Tables.mo
│  │  │  │     │  └─ 📄Types.mo
│  │  │  │     ├─ 📁Electrical
│  │  │  │     │  ├─ 📁Analog
│  │  │  │     │  │  ├─ 📁Basic
│  │  │  │     │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  ├─ 📄CCC.mo
│  │  │  │     │  │  │  ├─ 📄CCV.mo
│  │  │  │     │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄Ground.mo
│  │  │  │     │  │  │  ├─ 📄Gyrator.mo
│  │  │  │     │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  ├─ 📄M_Transformer.mo
│  │  │  │     │  │  │  ├─ 📄OpAmp.mo
│  │  │  │     │  │  │  ├─ 📄OpAmpDetailed.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Potentiometer.mo
│  │  │  │     │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  ├─ 📄RotationalEMF.mo
│  │  │  │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │  │  │     │  │  │  ├─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📄TranslationalEMF.mo
│  │  │  │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📄VCC.mo
│  │  │  │     │  │  │  └─ 📄VCV.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  ├─ 📄AD_Converter.mo
│  │  │  │     │  │  │  ├─ 📄CloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄ControlledCloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledOpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄DA_Converter.mo
│  │  │  │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealDiode.mo
│  │  │  │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealizedOpAmpLimited.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmp.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmp3Pin.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmpLimited.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  ├─ 📄IdealTriac.mo
│  │  │  │     │  │  │  ├─ 📄IdealTwoWaySwitch.mo
│  │  │  │     │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  ├─ 📄FourPin.mo
│  │  │  │     │  │  │  ├─ 📄IdealSemiconductor.mo
│  │  │  │     │  │  │  ├─ 📄IdealSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealSwitchWithArc.mo
│  │  │  │     │  │  │  ├─ 📄NegativePin.mo
│  │  │  │     │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄Pin.mo
│  │  │  │     │  │  │  ├─ 📄PositivePin.mo
│  │  │  │     │  │  │  ├─ 📄RelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄TwoPin.mo
│  │  │  │     │  │  │  ├─ 📄TwoPort.mo
│  │  │  │     │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  ├─ 📁Lines
│  │  │  │     │  │  │  ├─ 📄M_OLine.mo
│  │  │  │     │  │  │  ├─ 📄OLine.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄TLine1.mo
│  │  │  │     │  │  │  ├─ 📄TLine2.mo
│  │  │  │     │  │  │  ├─ 📄TLine3.mo
│  │  │  │     │  │  │  └─ 📄ULine.mo
│  │  │  │     │  │  ├─ 📁Semiconductors
│  │  │  │     │  │  │  ├─ 📄Diode.mo
│  │  │  │     │  │  │  ├─ 📄Diode2.mo
│  │  │  │     │  │  │  ├─ 📄NMOS.mo
│  │  │  │     │  │  │  ├─ 📄NPN.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PMOS.mo
│  │  │  │     │  │  │  ├─ 📄PNP.mo
│  │  │  │     │  │  │  ├─ 📄SimpleTriac.mo
│  │  │  │     │  │  │  ├─ 📄Thyristor.mo
│  │  │  │     │  │  │  └─ 📄ZDiode.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄ExponentialsCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ExponentialsVoltage.mo
│  │  │  │     │  │  │  ├─ 📄ExpSineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ExpSineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PulseCurrent.mo
│  │  │  │     │  │  │  ├─ 📄PulseVoltage.mo
│  │  │  │     │  │  │  ├─ 📄RampCurrent.mo
│  │  │  │     │  │  │  ├─ 📄RampVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SawToothCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SawToothVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SignalCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SignalVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄SineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄StepCurrent.mo
│  │  │  │     │  │  │  ├─ 📄StepVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SupplyVoltage.mo
│  │  │  │     │  │  │  ├─ 📄TableCurrent.mo
│  │  │  │     │  │  │  ├─ 📄TableVoltage.mo
│  │  │  │     │  │  │  ├─ 📄TrapezoidCurrent.mo
│  │  │  │     │  │  │  └─ 📄TrapezoidVoltage.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Batteries
│  │  │  │     │  │  ├─ 📁BaseClasses
│  │  │  │     │  │  │  ├─ 📄BaseCellStack.mo
│  │  │  │     │  │  │  ├─ 📄BaseCellWithSensors.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackData.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackWithSensors.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁BatteryStacks
│  │  │  │     │  │  │  ├─ 📄CellRCStack.mo
│  │  │  │     │  │  │  ├─ 📄CellStack.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄SuperCap.mo
│  │  │  │     │  │  ├─ 📁BatteryStacksWithSensors
│  │  │  │     │  │  │  ├─ 📄Cell.mo
│  │  │  │     │  │  │  ├─ 📄CellRC.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Stack.mo
│  │  │  │     │  │  │  └─ 📄StackRC.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄BaseCellRecord.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackRecord.mo
│  │  │  │     │  │  │  ├─ 📄BatteryIcon.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄TransientCellRecord.mo
│  │  │  │     │  │  │  ├─ 📄TransientModel.mo
│  │  │  │     │  │  │  ├─ 📄TransientRecordsPackage.mo
│  │  │  │     │  │  │  └─ 📄TransientStackRecord.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄CellBus.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄StackBus.mo
│  │  │  │     │  │  │  └─ 📄StackBusArrays.mo
│  │  │  │     │  │  ├─ 📁ParameterRecords
│  │  │  │     │  │  │  ├─ 📁TransientData
│  │  │  │     │  │  │  │  ├─ 📄CellData.mo
│  │  │  │     │  │  │  │  ├─ 📄ExampleData.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄RCData.mo
│  │  │  │     │  │  │  │  └─ 📄StackData.mo
│  │  │  │     │  │  │  ├─ 📄CellData.mo
│  │  │  │     │  │  │  ├─ 📄ExampleData.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄StackData.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Concept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Parameterization.mo
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  ├─ 📄BusTranscription.mo
│  │  │  │     │  │  │  ├─ 📄CCCVcharger.mo
│  │  │  │     │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄PulseSeries.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Machines
│  │  │  │     │  │  ├─ 📁BasicMachines
│  │  │  │     │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  ├─ 📄AirGapDC.mo
│  │  │  │     │  │  │  │  ├─ 📄AirGapR.mo
│  │  │  │     │  │  │  │  ├─ 📄AirGapS.mo
│  │  │  │     │  │  │  │  ├─ 📄CompoundDCExcitation.mo
│  │  │  │     │  │  │  │  ├─ 📄DamperCage.mo
│  │  │  │     │  │  │  │  ├─ 📄ElectricalExcitation.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCore.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄InductorDC.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialAirGap.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialAirGapDC.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCore.mo
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnetWithLosses.mo
│  │  │  │     │  │  │  │  └─ 📄SquirrelCage.mo
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄IM_SlipRing.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SquirrelCage.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁QuasiStaticDCMachines
│  │  │  │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SM_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_PermanentMagnet.mo
│  │  │  │     │  │  │  │  └─ 📄SM_ReluctanceRotor.mo
│  │  │  │     │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  ├─ 📁Dd
│  │  │  │     │  │  │  │  │  ├─ 📄Dd00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd08.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd10.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Dy
│  │  │  │     │  │  │  │  │  ├─ 📄Dy01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy09.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy11.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Dz
│  │  │  │     │  │  │  │  │  ├─ 📄Dz00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz08.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz10.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Yd
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yd01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd09.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yd11.mo
│  │  │  │     │  │  │  │  ├─ 📁Yy
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yy00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy08.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yy10.mo
│  │  │  │     │  │  │  │  ├─ 📁Yz
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yz01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz09.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yz11.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁ControlledDCDrives
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄Battery.mo
│  │  │  │     │  │  │  │  │  ├─ 📄DcdcInverter.mo
│  │  │  │     │  │  │  │  │  ├─ 📄DriveDataDCPM.mo
│  │  │  │     │  │  │  │  │  ├─ 📄IdealDcDc.mo
│  │  │  │     │  │  │  │  │  ├─ 📄LimitedPI.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄PartialControlledDCPM.mo
│  │  │  │     │  │  │  │  │  └─ 📄SwitchingDcDc.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentControlledDCPM.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PositionControlledDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄SpeedControlledDCPM.mo
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄DCEE_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Cooling.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_CurrentControlled.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_QuasiStatic.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Temperature.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_withLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄DCSE_SinglePhase.mo
│  │  │  │     │  │  │  │  ├─ 📄DCSE_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_CompareCharacteristics.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄IMC_Conveyor.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_DCBraking.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_DOL.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Initialize.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Inverter.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_InverterDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Steinmetz.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_withLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_YD.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_YDarc.mo
│  │  │  │     │  │  │  │  ├─ 📄IMS_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SMEE_DOL.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_Generator.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_LoadDump.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_Rectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_Braking.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_Inverter.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_NoLoad.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_ResistiveBraking.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_VoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄SMR_DOL.mo
│  │  │  │     │  │  │  │  └─ 📄SMR_Inverter.mo
│  │  │  │     │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  ├─ 📄AsymmetricalLoad.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Rectifier12pulse.mo
│  │  │  │     │  │  │  │  ├─ 📄Rectifier6pulse.mo
│  │  │  │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Drive.mo
│  │  │  │     │  │  │  ├─ 📄FundamentalWaveMachine.mo
│  │  │  │     │  │  │  ├─ 📄Machine.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.mo
│  │  │  │     │  │  │  ├─ 📄QuasiStaticMachine.mo
│  │  │  │     │  │  │  ├─ 📄QuasiStaticTransformer.mo
│  │  │  │     │  │  │  ├─ 📄TransientMachine.mo
│  │  │  │     │  │  │  └─ 📄TransientTransformer.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalPortDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCPM.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCSE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalPortDCSE.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceIMC.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceIMS.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMPM.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMR.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortIMC.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortIMS.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortSMPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalPortSMR.mo
│  │  │  │     │  │  │  ├─ 📄FlangeSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialBasicDCMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicInductionMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicTransformer.mo
│  │  │  │     │  │  │  ├─ 📄PowerBalanceTransformer.mo
│  │  │  │     │  │  │  ├─ 📄SpacePhasor.mo
│  │  │  │     │  │  │  └─ 📄ThermalPortTransformer.mo
│  │  │  │     │  │  ├─ 📁Losses
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄Brush.mo
│  │  │  │     │  │  │  │  ├─ 📄brushVoltageDrop.mo
│  │  │  │     │  │  │  │  ├─ 📄Core.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄StrayLoad.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄Brush.mo
│  │  │  │     │  │  │  │  ├─ 📄Core.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnetLosses.mo
│  │  │  │     │  │  │  │  └─ 📄StrayLoad.mo
│  │  │  │     │  │  │  ├─ 📄BrushParameters.mo
│  │  │  │     │  │  │  ├─ 📄CoreParameters.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄FrictionParameters.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PermanentMagnetLossParameters.mo
│  │  │  │     │  │  │  └─ 📄StrayLoadParameters.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  ├─ 📄ElectricalPowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄HallSensor.mo
│  │  │  │     │  │  │  ├─ 📄MechanicalPowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RotorDisplacementAngle.mo
│  │  │  │     │  │  │  ├─ 📄SinCosResolver.mo
│  │  │  │     │  │  │  └─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  ├─ 📁SpacePhasors
│  │  │  │     │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  ├─ 📄FromPolar.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄LessThreshold.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  ├─ 📄ToPolar.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  └─ 📄SpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Functions
│  │  │  │     │  │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  │  ├─ 📄FromPolar.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄quasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  ├─ 📄ToPolar.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Thermal
│  │  │  │     │  │  │  ├─ 📁Constants
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientDCSE.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientIMC.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientIMS.mo
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientSMPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientSMR.mo
│  │  │  │     │  │  │  ├─ 📄convertAlpha.mo
│  │  │  │     │  │  │  ├─ 📄convertResistance.mo
│  │  │  │     │  │  │  ├─ 📄LinearTemperatureCoefficient20.mo
│  │  │  │     │  │  │  ├─ 📄linearTemperatureDependency.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄ThermalAmbientTransformer.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Concept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Discrimination.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  ├─ 📁ParameterRecords
│  │  │  │     │  │  │  │  ├─ 📄DcElectricalExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄DcPermanentMagnetData.mo
│  │  │  │     │  │  │  │  ├─ 📄DcSeriesExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SlipRingData.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SquirrelCageData.mo
│  │  │  │     │  │  │  │  ├─ 📄InductionMachineData.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SM_ElectricalExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_PermanentMagnetData.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_ReluctanceRotorData.mo
│  │  │  │     │  │  │  │  └─ 📄TransformerData.mo
│  │  │  │     │  │  │  ├─ 📄DcBrakeSettings.mo
│  │  │  │     │  │  │  ├─ 📄DQCurrentController.mo
│  │  │  │     │  │  │  ├─ 📄DQToThreePhase.mo
│  │  │  │     │  │  │  ├─ 📄FromDQ.mo
│  │  │  │     │  │  │  ├─ 📄MultiTerminalBox.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RampedRheostat.mo
│  │  │  │     │  │  │  ├─ 📄SinCosEvaluation.mo
│  │  │  │     │  │  │  ├─ 📄SwitchedRheostat.mo
│  │  │  │     │  │  │  ├─ 📄SwitchYD.mo
│  │  │  │     │  │  │  ├─ 📄SwitchYDwithArc.mo
│  │  │  │     │  │  │  ├─ 📄SynchronousMachineData.mo
│  │  │  │     │  │  │  ├─ 📄TerminalBox.mo
│  │  │  │     │  │  │  ├─ 📄ToDQ.mo
│  │  │  │     │  │  │  ├─ 📄TransformerData.mo
│  │  │  │     │  │  │  └─ 📄VfController.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Polyphase
│  │  │  │     │  │  ├─ 📁Basic
│  │  │  │     │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  ├─ 📄Delta.mo
│  │  │  │     │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  ├─ 📄MultiDelta.mo
│  │  │  │     │  │  │  ├─ 📄MultiStar.mo
│  │  │  │     │  │  │  ├─ 📄MultiStarResistance.mo
│  │  │  │     │  │  │  ├─ 📄MutualInductor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PlugToPins_n.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPins_p.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPin_n.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPin_p.mo
│  │  │  │     │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │  │  │     │  │  │  ├─ 📄SplitToSubsystems.mo
│  │  │  │     │  │  │  ├─ 📄Star.mo
│  │  │  │     │  │  │  ├─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableResistor.mo
│  │  │  │     │  │  │  └─ 📄ZeroInductor.mo
│  │  │  │     │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄QuasiRMS.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄AnalysatorAC.mo
│  │  │  │     │  │  │  │  ├─ 📄AnalysatorDC.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄PolyphaseRectifierData.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PolyphaseRectifier.mo
│  │  │  │     │  │  │  ├─ 📄Rectifier.mo
│  │  │  │     │  │  │  ├─ 📄TestSensors.mo
│  │  │  │     │  │  │  ├─ 📄TransformerYD.mo
│  │  │  │     │  │  │  └─ 📄TransformerYY.mo
│  │  │  │     │  │  ├─ 📁Functions
│  │  │  │     │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  ├─ 📄factorY2D.mo
│  │  │  │     │  │  │  ├─ 📄factorY2DC.mo
│  │  │  │     │  │  │  ├─ 📄indexNonPositiveSequence.mo
│  │  │  │     │  │  │  ├─ 📄indexPositiveSequence.mo
│  │  │  │     │  │  │  ├─ 📄numberOfSymmetricBaseSystems.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄quasiRMS.mo
│  │  │  │     │  │  │  ├─ 📄symmetricBackTransformationMatrix.mo
│  │  │  │     │  │  │  ├─ 📄symmetricOrientation.mo
│  │  │  │     │  │  │  ├─ 📄symmetricOrientationMatrix.mo
│  │  │  │     │  │  │  └─ 📄symmetricTransformationMatrix.mo
│  │  │  │     │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  ├─ 📄CloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealDiode.mo
│  │  │  │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄FourPlug.mo
│  │  │  │     │  │  │  ├─ 📄NegativePlug.mo
│  │  │  │     │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Plug.mo
│  │  │  │     │  │  │  ├─ 📄PositivePlug.mo
│  │  │  │     │  │  │  ├─ 📄TwoPlug.mo
│  │  │  │     │  │  │  └─ 📄TwoPort.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AronSensor.mo
│  │  │  │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄SignalCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SignalVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrent.mo
│  │  │  │     │  │  │  └─ 📄SineVoltage.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PhaseOrientation.mo
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁PowerConverters
│  │  │  │     │  │  ├─ 📁ACAC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SoftStartControl.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageToAngle.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PolyphaseTriac.mo
│  │  │  │     │  │  │  └─ 📄SinglePhaseTriac.mo
│  │  │  │     │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄Filter.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Signal2mPulse.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageBridge2mPulse.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageBridge2Pulse.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │  │  │     │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │  │  │     │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │  │  │     │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄IntersectivePWM.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PWM.mo
│  │  │  │     │  │  │  │  └─ 📄SVPWM.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Polyphase2Level.mo
│  │  │  │     │  │  │  └─ 📄SinglePhase2Level.mo
│  │  │  │     │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SignalPWM.mo
│  │  │  │     │  │  │  │  └─ 📄Voltage2DutyCycle.mo
│  │  │  │     │  │  │  ├─ 📄ChopperStepDown.mo
│  │  │  │     │  │  │  ├─ 📄ChopperStepUp.mo
│  │  │  │     │  │  │  ├─ 📄HBridge.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Enable
│  │  │  │     │  │  │  ├─ 📄EnableLogic.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁ACAC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄Dimmer.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Dimmer_R.mo
│  │  │  │     │  │  │  │  ├─ 📄Dimmer_RL.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄SoftStarter.mo
│  │  │  │     │  │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Thyristor1Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │  │  │     │  │  │  │  ├─ 📁Rectifier1Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.mo
│  │  │  │     │  │  │  │  │  └─ 📄Thyristor1Pulse_R_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierBridge2mPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorBridge2mPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierBridge2Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorBridge2Pulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTap2mPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTap2Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTapmPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel.mo
│  │  │  │     │  │  │  │  ├─ 📁PolyphaseTwoLevel
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThreePhaseTwoLevel_PWM.mo
│  │  │  │     │  │  │  │  ├─ 📁SinglePhaseTwoLevel
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.mo
│  │  │  │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel_RL.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  │  ├─ 📁ChopperStepDown
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁ChopperStepUp
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepUp_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepUp.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁HBridge
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Control.mo
│  │  │  │     │  │  │  ├─ 📄Converter.mo
│  │  │  │     │  │  │  ├─ 📄ExampleTemplate.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  │  ├─ 📄ACplug.mo
│  │  │  │     │  │  │  │  ├─ 📄ACtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄ACtwoPlug.mo
│  │  │  │     │  │  │  │  ├─ 📄DCpin.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  │  ├─ 📄ACpin.mo
│  │  │  │     │  │  │  │  ├─ 📄ACplug.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin1.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin2.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Enable
│  │  │  │     │  │  │  │  ├─ 📄Enable.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable1.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable1m.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable2.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable2m.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PWMType.mo
│  │  │  │     │  │  │  ├─ 📄ReferenceType.mo
│  │  │  │     │  │  │  ├─ 📄SoftStarterModeOfOperation.mo
│  │  │  │     │  │  │  └─ 📄Voltage2AngleType.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄ACACConcept.mo
│  │  │  │     │  │  │  ├─ 📄ACDCConcept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄DCACConcept.mo
│  │  │  │     │  │  │  ├─ 📄DCDCConcept.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁QuasiStatic
│  │  │  │     │  │  ├─ 📁Machines
│  │  │  │     │  │  │  ├─ 📁BasicMachines
│  │  │  │     │  │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  │  ├─ 📄IdealCore.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄PartialCore.mo
│  │  │  │     │  │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  │  ├─ 📁Dd
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd08.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd10.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Dy
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy09.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy11.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Dz
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz08.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz10.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Yd
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd09.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yd11.mo
│  │  │  │     │  │  │  │  │  ├─ 📁Yy
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy08.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yy10.mo
│  │  │  │     │  │  │  │  │  ├─ 📁Yz
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz09.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yz11.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄PartialBasicTransformer.mo
│  │  │  │     │  │  │  ├─ 📁SpacePhasors
│  │  │  │     │  │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Polyphase
│  │  │  │     │  │  │  ├─ 📁Basic
│  │  │  │     │  │  │  │  ├─ 📄Admittance.mo
│  │  │  │     │  │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  │  ├─ 📄Delta.mo
│  │  │  │     │  │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiDelta.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiStar.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiStarResistance.mo
│  │  │  │     │  │  │  │  ├─ 📄MutualInductor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PlugToPins_n.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPins_p.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPin_n.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPin_p.mo
│  │  │  │     │  │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  │  ├─ 📄Star.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  │  └─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSymmetricalComponents.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄SingleToPolyphase.mo
│  │  │  │     │  │  │  │  ├─ 📄SymmetricalComponents.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄BalancingDelta.mo
│  │  │  │     │  │  │  │  ├─ 📄BalancingStar.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄TestSensors.mo
│  │  │  │     │  │  │  │  └─ 📄UnsymmetricalLoad.mo
│  │  │  │     │  │  │  ├─ 📁Functions
│  │  │  │     │  │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄quasiRMS.mo
│  │  │  │     │  │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄NegativePlug.mo
│  │  │  │     │  │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Plug.mo
│  │  │  │     │  │  │  │  ├─ 📄PositivePlug.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSource.mo
│  │  │  │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │  │  │     │  │  │  │  ├─ 📄Source.mo
│  │  │  │     │  │  │  │  ├─ 📄TwoPlug.mo
│  │  │  │     │  │  │  │  └─ 📄TwoPlugElementary.mo
│  │  │  │     │  │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  │  ├─ 📄AronSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  │  ├─ 📁Sources
│  │  │  │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ReferenceCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁SinglePhase
│  │  │  │     │  │  │  ├─ 📁Basic
│  │  │  │     │  │  │  │  ├─ 📄Admittance.mo
│  │  │  │     │  │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  │  ├─ 📄Ground.mo
│  │  │  │     │  │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  │  └─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ParallelResonance.mo
│  │  │  │     │  │  │  │  ├─ 📄Rectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄SeriesBode.mo
│  │  │  │     │  │  │  │  ├─ 📄SeriesResonance.mo
│  │  │  │     │  │  │  │  └─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄NegativePin.mo
│  │  │  │     │  │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Pin.mo
│  │  │  │     │  │  │  │  ├─ 📄PositivePin.mo
│  │  │  │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │  │  │     │  │  │  │  ├─ 📄Source.mo
│  │  │  │     │  │  │  │  ├─ 📄TwoPin.mo
│  │  │  │     │  │  │  │  └─ 📄TwoPinElementary.mo
│  │  │  │     │  │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  │  ├─ 📁Sources
│  │  │  │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄GraetzRectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealACDCConverter.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Reference.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📁Overview
│  │  │  │     │  │  │  │  ├─ 📄ACCircuit.mo
│  │  │  │     │  │  │  │  ├─ 📄Introduction.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Power.mo
│  │  │  │     │  │  │  │  └─ 📄ReferenceSystem.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Glossar.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📄Digital.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  └─ 📄Spice3.mo
│  │  │  │     ├─ 📁Math
│  │  │  │     │  ├─ 📄BooleanVectors.mo
│  │  │  │     │  ├─ 📄Distributions.mo
│  │  │  │     │  ├─ 📄FastFourierTransform.mo
│  │  │  │     │  ├─ 📄isPowerOf2.mo
│  │  │  │     │  ├─ 📄Nonlinear.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  ├─ 📄Polynomials.mo
│  │  │  │     │  ├─ 📄Random.mo
│  │  │  │     │  ├─ 📄Special.mo
│  │  │  │     │  └─ 📄wrapAngle.mo
│  │  │  │     ├─ 📁Mechanics
│  │  │  │     │  ├─ 📁MultiBody
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Constraints
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PrismaticConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄RevoluteConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄SphericalConstraint.mo
│  │  │  │     │  │  │  │  └─ 📄UniversalConstraint.mo
│  │  │  │     │  │  │  ├─ 📁Elementary
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄sineSurface.mo
│  │  │  │     │  │  │  │  │  └─ 📄theoreticalNormalGravityWGS84.mo
│  │  │  │     │  │  │  │  ├─ 📄DoublePendulum.mo
│  │  │  │     │  │  │  │  ├─ 📄DoublePendulumInitTip.mo
│  │  │  │     │  │  │  │  ├─ 📄ForceAndTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄FreeBody.mo
│  │  │  │     │  │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄InitSpringConstant.mo
│  │  │  │     │  │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Pendulum.mo
│  │  │  │     │  │  │  │  ├─ 📄PendulumWithSpringDamper.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravity.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravityWithPointMasses.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravityWithPointMasses2.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheelSetDriving.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheelSetPulling.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamperSystem.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringMassSystem.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringWithMass.mo
│  │  │  │     │  │  │  │  ├─ 📄Surfaces.mo
│  │  │  │     │  │  │  │  ├─ 📄ThreeSprings.mo
│  │  │  │     │  │  │  │  └─ 📄UserDefinedGravityField.mo
│  │  │  │     │  │  │  ├─ 📁Loops
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄Cylinder.mo
│  │  │  │     │  │  │  │  │  ├─ 📄CylinderBase.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Cylinder_analytic_CAD.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Engine1Base.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Engine1bBase.mo
│  │  │  │     │  │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │  │  │     │  │  │  │  │  ├─ 📄GasForce2.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Engine1a.mo
│  │  │  │     │  │  │  │  ├─ 📄Engine1b.mo
│  │  │  │     │  │  │  │  ├─ 📄Engine1b_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄EngineV6.mo
│  │  │  │     │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar1.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar2.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PlanarFourbar.mo
│  │  │  │     │  │  │  │  └─ 📄PlanarLoops_analytic.mo
│  │  │  │     │  │  │  ├─ 📁Rotational3DEffects
│  │  │  │     │  │  │  │  ├─ 📄ActuatedDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄BevelGear1D.mo
│  │  │  │     │  │  │  │  ├─ 📄GearConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄GyroscopicEffects.mo
│  │  │  │     │  │  │  │  ├─ 📄MovingActuatedDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Systems
│  │  │  │     │  │  │  │  ├─ 📁RobotR3
│  │  │  │     │  │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisControlBus.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisType1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisType2.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄ControlBus.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Controller.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄GearType1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄GearType2.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄MechanicalStructure.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Motor.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄PathPlanning1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄PathPlanning6.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄PathToAxisControlBus.mo
│  │  │  │     │  │  │  │  │  ├─ 📄FullRobot.mo
│  │  │  │     │  │  │  │  │  ├─ 📄OneAxis.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Forces
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄BasicForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicWorldForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicWorldTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄standardGravityAcceleration.mo
│  │  │  │     │  │  │  │  └─ 📄ZeroForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄Force.mo
│  │  │  │     │  │  │  ├─ 📄ForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄LineForceWithMass.mo
│  │  │  │     │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamperParallel.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamperSeries.mo
│  │  │  │     │  │  │  ├─ 📄Torque.mo
│  │  │  │     │  │  │  ├─ 📄WorldForce.mo
│  │  │  │     │  │  │  ├─ 📄WorldForceAndTorque.mo
│  │  │  │     │  │  │  └─ 📄WorldTorque.mo
│  │  │  │     │  │  ├─ 📁Frames
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent.mo
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent_d.mo
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent_dd.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuaternionBase.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1_der.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2_der.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveRelative_der.mo
│  │  │  │     │  │  │  │  └─ 📄TransformationMatrix.mo
│  │  │  │     │  │  │  ├─ 📁Quaternions
│  │  │  │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  │  └─ 📄to_T_inv.mo
│  │  │  │     │  │  │  ├─ 📁TransformationMatrices
│  │  │  │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  │  ├─ 📄axesRotations.mo
│  │  │  │     │  │  │  │  ├─ 📄axesRotationsAngles.mo
│  │  │  │     │  │  │  │  ├─ 📄axisRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄from_nxy.mo
│  │  │  │     │  │  │  │  ├─ 📄from_nxz.mo
│  │  │  │     │  │  │  │  ├─ 📄from_Q.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄planarRotationAngle.mo
│  │  │  │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveDyade1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveDyade2.mo
│  │  │  │     │  │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄to_exy.mo
│  │  │  │     │  │  │  │  ├─ 📄to_Q.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T_inv.mo
│  │  │  │     │  │  │  │  └─ 📄to_vector.mo
│  │  │  │     │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  ├─ 📄axesRotations.mo
│  │  │  │     │  │  │  ├─ 📄axesRotationsAngles.mo
│  │  │  │     │  │  │  ├─ 📄axis.mo
│  │  │  │     │  │  │  ├─ 📄axisRotation.mo
│  │  │  │     │  │  │  ├─ 📄from_nxy.mo
│  │  │  │     │  │  │  ├─ 📄from_nxz.mo
│  │  │  │     │  │  │  ├─ 📄from_Q.mo
│  │  │  │     │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  ├─ 📄from_T2.mo
│  │  │  │     │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  ├─ 📄planarRotationAngle.mo
│  │  │  │     │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  ├─ 📄resolveDyade1.mo
│  │  │  │     │  │  │  ├─ 📄resolveDyade2.mo
│  │  │  │     │  │  │  ├─ 📄resolveRelative.mo
│  │  │  │     │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  ├─ 📄to_exy.mo
│  │  │  │     │  │  │  ├─ 📄to_Q.mo
│  │  │  │     │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  ├─ 📄to_T_inv.mo
│  │  │  │     │  │  │  └─ 📄to_vector.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Surface.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄FlangeWithBearing.mo
│  │  │  │     │  │  │  ├─ 📄FlangeWithBearingAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄Frame.mo
│  │  │  │     │  │  │  ├─ 📄Frame_a.mo
│  │  │  │     │  │  │  ├─ 📄Frame_b.mo
│  │  │  │     │  │  │  ├─ 📄Frame_resolve.mo
│  │  │  │     │  │  │  ├─ 📄LineForceBase.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄partialColorMap.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryJoint.mo
│  │  │  │     │  │  │  ├─ 📄PartialForce.mo
│  │  │  │     │  │  │  ├─ 📄partialGravityAcceleration.mo
│  │  │  │     │  │  │  ├─ 📄PartialLineForce.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFrame_a.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFrame_b.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄partialSurfaceCharacteristic.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFrames.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFramesDoubleSize.mo
│  │  │  │     │  │  │  ├─ 📄PartialVisualizer.mo
│  │  │  │     │  │  │  └─ 📄ZeroPosition.mo
│  │  │  │     │  │  ├─ 📁Joints
│  │  │  │     │  │  │  ├─ 📁Assemblies
│  │  │  │     │  │  │  │  ├─ 📄JointRRP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointRRR.mo
│  │  │  │     │  │  │  │  ├─ 📄JointSSP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointSSR.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUPS.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUSP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUSR.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Constraints
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Prismatic.mo
│  │  │  │     │  │  │  │  ├─ 📄Revolute.mo
│  │  │  │     │  │  │  │  ├─ 📄Spherical.mo
│  │  │  │     │  │  │  │  └─ 📄Universal.mo
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄InitAngle.mo
│  │  │  │     │  │  │  │  ├─ 📄InitAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄InitPosition.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PrismaticWithLengthConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄RevoluteWithLengthConstraint.mo
│  │  │  │     │  │  │  │  └─ 📄RollingConstraintVerticalWheel.mo
│  │  │  │     │  │  │  ├─ 📄Cylindrical.mo
│  │  │  │     │  │  │  ├─ 📄FreeMotion.mo
│  │  │  │     │  │  │  ├─ 📄FreeMotionScalarInit.mo
│  │  │  │     │  │  │  ├─ 📄GearConstraint.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Planar.mo
│  │  │  │     │  │  │  ├─ 📄Prismatic.mo
│  │  │  │     │  │  │  ├─ 📄Revolute.mo
│  │  │  │     │  │  │  ├─ 📄RevolutePlanarLoopConstraint.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │  │  │     │  │  │  ├─ 📄Spherical.mo
│  │  │  │     │  │  │  ├─ 📄SphericalSpherical.mo
│  │  │  │     │  │  │  ├─ 📄Universal.mo
│  │  │  │     │  │  │  └─ 📄UniversalSpherical.mo
│  │  │  │     │  │  ├─ 📁Parts
│  │  │  │     │  │  │  ├─ 📄BevelGear1D.mo
│  │  │  │     │  │  │  ├─ 📄Body.mo
│  │  │  │     │  │  │  ├─ 📄BodyBox.mo
│  │  │  │     │  │  │  ├─ 📄BodyCylinder.mo
│  │  │  │     │  │  │  ├─ 📄BodyShape.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄FixedRotation.mo
│  │  │  │     │  │  │  ├─ 📄FixedTranslation.mo
│  │  │  │     │  │  │  ├─ 📄Mounting1D.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PointMass.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │  │  │     │  │  │  └─ 📄Rotor1D.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄BasicAbsoluteAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicAbsolutePosition.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicCutForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicCutTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicRelativeAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicRelativePosition.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTransformAbsoluteVector.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTransformRelativeVector.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialAbsoluteBaseSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCutForceBaseSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCutForceSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialRelativeBaseSensor.mo
│  │  │  │     │  │  │  │  └─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteAngles.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteAngularVelocity.mo
│  │  │  │     │  │  │  ├─ 📄AbsolutePosition.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteVelocity.mo
│  │  │  │     │  │  │  ├─ 📄CutForce.mo
│  │  │  │     │  │  │  ├─ 📄CutForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄CutTorque.mo
│  │  │  │     │  │  │  ├─ 📄Distance.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Power.mo
│  │  │  │     │  │  │  ├─ 📄RelativeAngles.mo
│  │  │  │     │  │  │  ├─ 📄RelativeAngularVelocity.mo
│  │  │  │     │  │  │  ├─ 📄RelativePosition.mo
│  │  │  │     │  │  │  ├─ 📄RelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelativeVelocity.mo
│  │  │  │     │  │  │  ├─ 📄TransformAbsoluteVector.mo
│  │  │  │     │  │  │  └─ 📄TransformRelativeVector.mo
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📁Defaults
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Axis.mo
│  │  │  │     │  │  │  ├─ 📄AxisLabel.mo
│  │  │  │     │  │  │  ├─ 📄Color.mo
│  │  │  │     │  │  │  ├─ 📄GravityTypes.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RealColor.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameA.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameAB.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameB.mo
│  │  │  │     │  │  │  ├─ 📄RotationSequence.mo
│  │  │  │     │  │  │  ├─ 📄RotationTypes.mo
│  │  │  │     │  │  │  ├─ 📄ShapeExtra.mo
│  │  │  │     │  │  │  ├─ 📄ShapeType.mo
│  │  │  │     │  │  │  ├─ 📄SpecularCoefficient.mo
│  │  │  │     │  │  │  └─ 📄VectorQuantity.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📁Tutorial
│  │  │  │     │  │  │  │  ├─ 📁LoopStructures
│  │  │  │     │  │  │  │  │  ├─ 📄AnalyticLoopHandling.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Introduction.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄PlanarLoops.mo
│  │  │  │     │  │  │  │  ├─ 📄ConnectionOfLineForces.mo
│  │  │  │     │  │  │  │  ├─ 📄FirstExample.mo
│  │  │  │     │  │  │  │  ├─ 📄OverView.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Literature.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Visualizers
│  │  │  │     │  │  │  ├─ 📁Advanced
│  │  │  │     │  │  │  │  ├─ 📁SurfaceCharacteristics
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄pipeWithScalarField.mo
│  │  │  │     │  │  │  │  │  ├─ 📄rectangle.mo
│  │  │  │     │  │  │  │  │  └─ 📄torus.mo
│  │  │  │     │  │  │  │  ├─ 📄Arrow.mo
│  │  │  │     │  │  │  │  ├─ 📄DoubleArrow.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PipeWithScalarField.mo
│  │  │  │     │  │  │  │  ├─ 📄Shape.mo
│  │  │  │     │  │  │  │  ├─ 📄Surface.mo
│  │  │  │     │  │  │  │  └─ 📄Vector.mo
│  │  │  │     │  │  │  ├─ 📁Colors
│  │  │  │     │  │  │  │  ├─ 📁ColorMaps
│  │  │  │     │  │  │  │  │  ├─ 📄autumn.mo
│  │  │  │     │  │  │  │  │  ├─ 📄gray.mo
│  │  │  │     │  │  │  │  │  ├─ 📄hot.mo
│  │  │  │     │  │  │  │  │  ├─ 📄jet.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄spring.mo
│  │  │  │     │  │  │  │  │  ├─ 📄summer.mo
│  │  │  │     │  │  │  │  │  └─ 📄winter.mo
│  │  │  │     │  │  │  │  ├─ 📄colorMapToSvg.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄scalarToColor.mo
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄FixedLines.mo
│  │  │  │     │  │  │  │  ├─ 📄Lines.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄FixedArrow.mo
│  │  │  │     │  │  │  ├─ 📄FixedFrame.mo
│  │  │  │     │  │  │  ├─ 📄FixedShape.mo
│  │  │  │     │  │  │  ├─ 📄FixedShape2.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PipeWithScalarField.mo
│  │  │  │     │  │  │  ├─ 📄Rectangle.mo
│  │  │  │     │  │  │  ├─ 📄SignalArrow.mo
│  │  │  │     │  │  │  ├─ 📄Torus.mo
│  │  │  │     │  │  │  └─ 📄VoluminousWheel.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Rotational
│  │  │  │     │  │  ├─ 📁Components
│  │  │  │     │  │  │  ├─ 📄AngleToTorqueAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄BearingFriction.mo
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄Clutch.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄Disc.mo
│  │  │  │     │  │  │  ├─ 📄ElastoBacklash.mo
│  │  │  │     │  │  │  ├─ 📄ElastoBacklash2.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄Gearbox.mo
│  │  │  │     │  │  │  ├─ 📄GeneralAngleToTorqueAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralTorqueToAngleAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄IdealGear.mo
│  │  │  │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │  │  │     │  │  │  ├─ 📄IdealPlanetary.mo
│  │  │  │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄Inertia.mo
│  │  │  │     │  │  │  ├─ 📄InitializeFlange.mo
│  │  │  │     │  │  │  ├─ 📄LossyGear.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutch.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  └─ 📄TorqueToAngleAdaptor.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄DirectInertia.mo
│  │  │  │     │  │  │  │  ├─ 📄InverseInertia.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Backlash.mo
│  │  │  │     │  │  │  ├─ 📄CompareBrakingTorque.mo
│  │  │  │     │  │  │  ├─ 📄CoupledClutches.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │  │  │     │  │  │  ├─ 📄ElasticBearing.mo
│  │  │  │     │  │  │  ├─ 📄First.mo
│  │  │  │     │  │  │  ├─ 📄FirstGrounded.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │  │  │     │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo1.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo2.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo3.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutch.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutchDisengaged.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  └─ 📄SimpleGearShift.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Clutch.mo
│  │  │  │     │  │  │  ├─ 📄Gear.mo
│  │  │  │     │  │  │  ├─ 📄Gearbox.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄Flange.mo
│  │  │  │     │  │  │  ├─ 📄Flange_a.mo
│  │  │  │     │  │  │  ├─ 📄Flange_b.mo
│  │  │  │     │  │  │  ├─ 📄InternalSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliant.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialFriction.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialTorque.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │  │  │     │  │  │  └─ 📄Support.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AccSensor.mo
│  │  │  │     │  │  │  ├─ 📄AngleSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAccSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAngleSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │  │  │     │  │  │  ├─ 📄SpeedSensor.mo
│  │  │  │     │  │  │  └─ 📄TorqueSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │  │  │     │  │  │  ├─ 📄ConstantTorque.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentTorque.mo
│  │  │  │     │  │  │  ├─ 📄InverseSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄LinearSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄Move.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Position.mo
│  │  │  │     │  │  │  ├─ 📄QuadraticSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄SignTorque.mo
│  │  │  │     │  │  │  ├─ 📄Speed.mo
│  │  │  │     │  │  │  ├─ 📄Torque.mo
│  │  │  │     │  │  │  ├─ 📄Torque2.mo
│  │  │  │     │  │  │  └─ 📄TorqueStep.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │  │  │     │  │  │  ├─ 📄ModelingOfFriction.mo
│  │  │  │     │  │  │  ├─ 📄Overview.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  ├─ 📄RequirementsForSimulationTool.mo
│  │  │  │     │  │  │  ├─ 📄SignConventions.mo
│  │  │  │     │  │  │  ├─ 📄StateSelection.mo
│  │  │  │     │  │  │  ├─ 📄SupportTorques.mo
│  │  │  │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Translational
│  │  │  │     │  │  ├─ 📁Components
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄ElastoGap.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄GeneralForceToPositionAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralPositionToForceAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │  │  │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄InitializeFlange.mo
│  │  │  │     │  │  │  ├─ 📄Mass.mo
│  │  │  │     │  │  │  ├─ 📄MassWithStopAndFriction.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Rod.mo
│  │  │  │     │  │  │  ├─ 📄RollingResistance.mo
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  ├─ 📄SupportFriction.mo
│  │  │  │     │  │  │  └─ 📄Vehicle.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄DirectMass.mo
│  │  │  │     │  │  │  │  ├─ 📄GenerateStribeckFrictionTable.mo
│  │  │  │     │  │  │  │  ├─ 📄InverseMass.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄CompareBrakingForce.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │  │  │     │  │  │  ├─ 📄ElastoGap.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │  │  │     │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  ├─ 📄InitialConditions.mo
│  │  │  │     │  │  │  ├─ 📄Oscillator.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PreLoad.mo
│  │  │  │     │  │  │  ├─ 📄Sensors.mo
│  │  │  │     │  │  │  ├─ 📄SignConvention.mo
│  │  │  │     │  │  │  ├─ 📄Vehicle.mo
│  │  │  │     │  │  │  └─ 📄WhyArrows.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄Flange.mo
│  │  │  │     │  │  │  ├─ 📄Flange_a.mo
│  │  │  │     │  │  │  ├─ 📄Flange_b.mo
│  │  │  │     │  │  │  ├─ 📄InternalSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliant.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialForce.mo
│  │  │  │     │  │  │  ├─ 📄PartialFriction.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialRigid.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │  │  │     │  │  │  └─ 📄Support.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AccSensor.mo
│  │  │  │     │  │  │  ├─ 📄ForceSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PositionSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAccSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelPositionSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │  │  │     │  │  │  └─ 📄SpeedSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄ConstantForce.mo
│  │  │  │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentForce.mo
│  │  │  │     │  │  │  ├─ 📄Force.mo
│  │  │  │     │  │  │  ├─ 📄Force2.mo
│  │  │  │     │  │  │  ├─ 📄ForceStep.mo
│  │  │  │     │  │  │  ├─ 📄InverseSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄LinearSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄Move.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Position.mo
│  │  │  │     │  │  │  ├─ 📄QuadraticSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄SignForce.mo
│  │  │  │     │  │  │  └─ 📄Speed.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │  │  │     │  │  │  ├─ 📄Overview.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄SignConventions.mo
│  │  │  │     │  │  │  ├─ 📄StateSelection.mo
│  │  │  │     │  │  │  ├─ 📄SupportForces.mo
│  │  │  │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  └─ 📄package.order
│  │  │  │     ├─ 📄.gitkeep
│  │  │  │     └─ 📄Untitled
│  │  │  ├─ 📄application-dev.yml
│  │  │  ├─ 📄application-prod.yml
│  │  │  └─ 📄application.yml
│  │  ├─ 📁generated-sources
│  │  │  └─ 📁annotations
│  │  │     └─ 📁com
│  │  │        └─ 📁modelcloud
│  │  │           └─ 📁modules
│  │  │              ├─ 📁business
│  │  │              │  └─ 📁model
│  │  │              │     └─ 📁domain
│  │  │              │        └─ 📁table
│  │  │              │           ├─ 📄BsComponentTableDef.java
│  │  │              │           ├─ 📄BsModelCollectTableDef.java
│  │  │              │           ├─ 📄BsModelingProjectTableDef.java
│  │  │              │           ├─ 📄BsModelLabelTableDef.java
│  │  │              │           ├─ 📄BsModelTableDef.java
│  │  │              │           ├─ 📄BsSimulationTaskTableDef.java
│  │  │              │           └─ 📄ModelLabelCategoryTableDef.java
│  │  │              └─ 📁sys
│  │  │                 └─ 📁model
│  │  │                    └─ 📁domain
│  │  │                       └─ 📁table
│  │  │                          ├─ 📄SysFileTableDef.java
│  │  │                          ├─ 📄SysPowerTableDef.java
│  │  │                          ├─ 📄SysRoleTableDef.java
│  │  │                          ├─ 📄SysSiteStatTableDef.java
│  │  │                          ├─ 📄SysUserRoleTableDef.java
│  │  │                          └─ 📄SysUserTableDef.java
│  │  ├─ 📁generated-test-sources
│  │  │  └─ 📁test-annotations
│  │  ├─ 📁maven-status
│  │  │  └─ 📁maven-compiler-plugin
│  │  │     └─ 📁compile
│  │  │        └─ 📁default-compile
│  │  │           ├─ 📄createdFiles.lst
│  │  │           └─ 📄inputFiles.lst
│  │  └─ 📁test-classes
│  ├─ 📄.gitignore
│  ├─ 📄pom.xml
│  └─ 📄技术报告.md
├─ 📁model-cloud-frontend
│  ├─ 📁public
│  │  ├─ 📄angle.png
│  │  ├─ 📄current.png
│  │  └─ 📄omega.png
│  ├─ 📁src
│  │  ├─ 📁api
│  │  │  ├─ 📄auth.ts
│  │  │  ├─ 📄model-deploy.ts
│  │  │  ├─ 📄model.ts
│  │  │  ├─ 📄request.ts
│  │  │  └─ 📄user.ts
│  │  ├─ 📁components
│  │  │  └─ 📁model
│  │  │     ├─ 📄ModelDeleteButton.vue
│  │  │     ├─ 📄ModelFilterBar.vue
│  │  │     ├─ 📄ModelicaComponentNode.vue
│  │  │     └─ 📄ModelUploadDialog.vue
│  │  ├─ 📁layouts
│  │  │  └─ 📄MainLayout.vue
│  │  ├─ 📁router
│  │  │  └─ 📄index.ts
│  │  ├─ 📁stores
│  │  │  └─ 📄user.ts
│  │  ├─ 📁utils
│  │  │  └─ 📄stats.ts
│  │  ├─ 📁views
│  │  │  ├─ 📁auth
│  │  │  │  ├─ 📄Login.vue
│  │  │  │  └─ 📄Register.vue
│  │  │  ├─ 📁business
│  │  │  │  ├─ 📄ComponentManage.vue
│  │  │  │  ├─ 📄ModelDeploy.vue
│  │  │  │  ├─ 📄ModelDetail.vue
│  │  │  │  ├─ 📄ModelList.vue
│  │  │  │  ├─ 📄ModelManage.vue
│  │  │  │  ├─ 📄MyCollects.vue
│  │  │  │  └─ 📄MyModels.vue
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
│  ├─ 📄vite.config.ts
│  └─ 📄技术报告.md
├─ 📁model-cloud-simulation
│  ├─ 📁app
│  │  ├─ 📁api
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁models
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁services
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁tasks
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁utils
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁__pycache__
│  │  │  ├─ 📄config.cpython-311.pyc
│  │  │  ├─ 📄main.cpython-311.pyc
│  │  │  └─ 📄__init__.cpython-311.pyc
│  │  ├─ 📄config.py
│  │  ├─ 📄main.py
│  │  └─ 📄__init__.py
│  ├─ 📄.gitignore
│  ├─ 📄README.md
│  └─ 📄requirements.txt
├─ 📁__pycache__
│  └─ 📄parse_modelica_components.cpython-311.pyc
├─ 📄.gitignore
├─ 📄database_full_init.sql
├─ 📄Modelica模型部署功能开发思路说明.md
├─ 📄README.md
└─ 📄技术报告.md
```
```
model-cloud
├─ 📁model-cloud-backend
│  ├─ 📁runtime
│  │  └─ 📁modelica-icons
│  │     └─ 📄24.svg
│  ├─ 📁src
│  │  └─ 📁main
│  │     ├─ 📁java
│  │     │  └─ 📁com
│  │     │     └─ 📁modelcloud
│  │     │        ├─ 📁common
│  │     │        │  ├─ 📁config
│  │     │        │  │  ├─ 📄AsyncConfig.java
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
│  │     │        │  │  │  ├─ 📄BsModelLabelController.java
│  │     │        │  │  │  ├─ 📄ModelDeployController.java
│  │     │        │  │  │  └─ 📄SseController.java
│  │     │        │  │  ├─ 📁event
│  │     │        │  │  │  └─ 📄VisitCountEvent.java
│  │     │        │  │  ├─ 📁mapper
│  │     │        │  │  │  ├─ 📄BsComponentMapper.java
│  │     │        │  │  │  ├─ 📄BsModelCollectMapper.java
│  │     │        │  │  │  ├─ 📄BsModelingProjectMapper.java
│  │     │        │  │  │  ├─ 📄BsModelLabelMapper.java
│  │     │        │  │  │  ├─ 📄BsModelMapper.java
│  │     │        │  │  │  ├─ 📄BsSimulationTaskMapper.java
│  │     │        │  │  │  └─ 📄ModelLabelCategoryMapper.java
│  │     │        │  │  ├─ 📁model
│  │     │        │  │  │  ├─ 📁domain
│  │     │        │  │  │  │  ├─ 📄BsComponent.java
│  │     │        │  │  │  │  ├─ 📄BsComponentParseMeta.java
│  │     │        │  │  │  │  ├─ 📄BsComponentParseMetaOmc.java
│  │     │        │  │  │  │  ├─ 📄BsModel.java
│  │     │        │  │  │  │  ├─ 📄BsModelCollect.java
│  │     │        │  │  │  │  ├─ 📄BsModelingProject.java
│  │     │        │  │  │  │  ├─ 📄BsModelLabel.java
│  │     │        │  │  │  │  ├─ 📄BsModelParams.java
│  │     │        │  │  │  │  ├─ 📄BsSimulationTask.java
│  │     │        │  │  │  │  └─ 📄ModelLabelCategory.java
│  │     │        │  │  │  ├─ 📁dto
│  │     │        │  │  │  │  └─ 📄ComponentVO.java
│  │     │        │  │  │  └─ 📁request
│  │     │        │  │  │     ├─ 📄ComponentUploadRequest.java
│  │     │        │  │  │     ├─ 📄ModelingProjectRequest.java
│  │     │        │  │  │     ├─ 📄ModelUploadRequest.java
│  │     │        │  │  │     └─ 📄SimulationRequest.java
│  │     │        │  │  ├─ 📁repository
│  │     │        │  │  │  ├─ 📄BsComponentParseMetaOmcRepository.java
│  │     │        │  │  │  └─ 📄BsComponentParseMetaRepository.java
│  │     │        │  │  ├─ 📁service
│  │     │        │  │  │  ├─ 📁impl
│  │     │        │  │  │  │  ├─ 📄BsModelCollectServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄BsModelLabelServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄BsModelServiceImpl.java
│  │     │        │  │  │  │  ├─ 📄ModelDeployServiceImpl.java
│  │     │        │  │  │  │  └─ 📄ModelLabelCategoryServiceImpl.java
│  │     │        │  │  │  ├─ 📄BsModelCollectService.java
│  │     │        │  │  │  ├─ 📄BsModelLabelService.java
│  │     │        │  │  │  ├─ 📄BsModelService.java
│  │     │        │  │  │  ├─ 📄GiteaService.java
│  │     │        │  │  │  ├─ 📄ModelDeployService.java
│  │     │        │  │  │  └─ 📄ModelLabelCategoryService.java
│  │     │        │  │  └─ 📁utils
│  │     │        │  │     ├─ 📄ModelicaIconSvgRenderer.java
│  │     │        │  │     └─ 📄ModelicaParser.java
│  │     │        │  └─ 📁sys
│  │     │        │     ├─ 📁controller
│  │     │        │     │  └─ 📄SysUserController.java
│  │     │        │     ├─ 📁mapper
│  │     │        │     │  ├─ 📄SysRoleMapper.java
│  │     │        │     │  ├─ 📄SysSiteStatMapper.java
│  │     │        │     │  ├─ 📄SysUserMapper.java
│  │     │        │     │  └─ 📄SysUserRoleMapper.java
│  │     │        │     ├─ 📁model
│  │     │        │     │  ├─ 📁domain
│  │     │        │     │  │  ├─ 📄SysFile.java
│  │     │        │     │  │  ├─ 📄SysPower.java
│  │     │        │     │  │  ├─ 📄SysRole.java
│  │     │        │     │  │  ├─ 📄SysSiteStat.java
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
│  │     │        │        │  ├─ 📄SiteStatServiceImpl.java
│  │     │        │        │  ├─ 📄SysRoleServiceImpl.java
│  │     │        │        │  └─ 📄SysUserServiceImpl.java
│  │     │        │        ├─ 📄SiteStatService.java
│  │     │        │        ├─ 📄SysRoleService.java
│  │     │        │        └─ 📄SysUserService.java
│  │     │        └─ 📄ModelCloudApplication.java
│  │     └─ 📁resources
│  │        ├─ 📁mapper
│  │        │  └─ 📁business
│  │        │     └─ 📄BsModelMapper.xml
│  │        ├─ 📁static
│  │        │  ├─ 📁component_icon
│  │        │  │  ├─ 📁Electrical
│  │        │  │  │  ├─ 📄AbsoluteSensor.svg
│  │        │  │  │  ├─ 📄ACAC.svg
│  │        │  │  │  ├─ 📄ACACConcept.svg
│  │        │  │  │  ├─ 📄ACCircuit.svg
│  │        │  │  │  ├─ 📄ACDC.svg
│  │        │  │  │  ├─ 📄ACDCConcept.svg
│  │        │  │  │  ├─ 📄ACpin.svg
│  │        │  │  │  ├─ 📄ACplug.svg
│  │        │  │  │  ├─ 📄activePower.svg
│  │        │  │  │  ├─ 📄ACtwoPin.svg
│  │        │  │  │  ├─ 📄ACtwoPlug.svg
│  │        │  │  │  ├─ 📄Add.svg
│  │        │  │  │  ├─ 📄Adder.svg
│  │        │  │  │  ├─ 📄Adder4.svg
│  │        │  │  │  ├─ 📄Additionals.svg
│  │        │  │  │  ├─ 📄Admittance.svg
│  │        │  │  │  ├─ 📄AD_Converter.svg
│  │        │  │  │  ├─ 📄AD_DA_conversion.svg
│  │        │  │  │  ├─ 📄AirGapDC.svg
│  │        │  │  │  ├─ 📄AirGapR.svg
│  │        │  │  │  ├─ 📄AirGapS.svg
│  │        │  │  │  ├─ 📄AmplifierWithOpAmpDetailed.svg
│  │        │  │  │  ├─ 📄Analog.svg
│  │        │  │  │  ├─ 📄AnalysatorAC.svg
│  │        │  │  │  ├─ 📄AnalysatorDC.svg
│  │        │  │  │  ├─ 📄And.svg
│  │        │  │  │  ├─ 📄AndGate.svg
│  │        │  │  │  ├─ 📄AronSensor.svg
│  │        │  │  │  ├─ 📄AsymmetricalLoad.svg
│  │        │  │  │  ├─ 📄BalancingDelta.svg
│  │        │  │  │  ├─ 📄BalancingStar.svg
│  │        │  │  │  ├─ 📄BaseCellRecord.svg
│  │        │  │  │  ├─ 📄BaseCellStack.svg
│  │        │  │  │  ├─ 📄BaseCellWithSensors.svg
│  │        │  │  │  ├─ 📄BaseClasses.svg
│  │        │  │  │  ├─ 📄BaseStackData.svg
│  │        │  │  │  ├─ 📄BaseStackRecord.svg
│  │        │  │  │  ├─ 📄BaseStackWithSensors.svg
│  │        │  │  │  ├─ 📄Basic.svg
│  │        │  │  │  ├─ 📄BasicMachines.svg
│  │        │  │  │  ├─ 📄Batteries.svg
│  │        │  │  │  ├─ 📄Battery.svg
│  │        │  │  │  ├─ 📄BatteryDischargeCharge.svg
│  │        │  │  │  ├─ 📄BatteryIcon.svg
│  │        │  │  │  ├─ 📄BatteryStacks.svg
│  │        │  │  │  ├─ 📄BatteryStacksWithSensors.svg
│  │        │  │  │  ├─ 📄Bjt.svg
│  │        │  │  │  ├─ 📄BJT2.svg
│  │        │  │  │  ├─ 📄BjtCalc.svg
│  │        │  │  │  ├─ 📄bjtCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄bjtInitEquations.svg
│  │        │  │  │  ├─ 📄bjtModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄BjtModelLineParams.svg
│  │        │  │  │  ├─ 📄bjtNoBypassCode.svg
│  │        │  │  │  ├─ 📄bjtRenameParameters.svg
│  │        │  │  │  ├─ 📄bjtRenameParametersDev.svg
│  │        │  │  │  ├─ 📄Blocks.svg
│  │        │  │  │  ├─ 📄BooleanToLogic.svg
│  │        │  │  │  ├─ 📄Brush.svg
│  │        │  │  │  ├─ 📄BrushParameters.svg
│  │        │  │  │  ├─ 📄brushVoltageDrop.svg
│  │        │  │  │  ├─ 📄BUF3S.svg
│  │        │  │  │  ├─ 📄BUF3SL.svg
│  │        │  │  │  ├─ 📄Buffer.svg
│  │        │  │  │  ├─ 📄BufGate.svg
│  │        │  │  │  ├─ 📄BusTranscription.svg
│  │        │  │  │  ├─ 📄calculateGateCap.svg
│  │        │  │  │  ├─ 📄Capacitance.svg
│  │        │  │  │  ├─ 📄Capacitor.svg
│  │        │  │  │  ├─ 📄capacitorInitEquations.svg
│  │        │  │  │  ├─ 📄CapacitorModelLineParams.svg
│  │        │  │  │  ├─ 📄capacitorRenameParameters.svg
│  │        │  │  │  ├─ 📄capacitorRenameParametersDev.svg
│  │        │  │  │  ├─ 📄capDepGeom.svg
│  │        │  │  │  ├─ 📄CascodeCircuit.svg
│  │        │  │  │  ├─ 📄CauerLowPassAnalog.svg
│  │        │  │  │  ├─ 📄CauerLowPassOPV.svg
│  │        │  │  │  ├─ 📄CauerLowPassSC.svg
│  │        │  │  │  ├─ 📄CCC.svg
│  │        │  │  │  ├─ 📄CCCVcharger.svg
│  │        │  │  │  ├─ 📄CCCVcharging.svg
│  │        │  │  │  ├─ 📄CCCV_Cell.svg
│  │        │  │  │  ├─ 📄CCCV_CellRC.svg
│  │        │  │  │  ├─ 📄CCCV_Stack.svg
│  │        │  │  │  ├─ 📄CCCV_StackRC.svg
│  │        │  │  │  ├─ 📄CCV.svg
│  │        │  │  │  ├─ 📄Cell.svg
│  │        │  │  │  ├─ 📄CellBus.svg
│  │        │  │  │  ├─ 📄CellData.svg
│  │        │  │  │  ├─ 📄CellRC.svg
│  │        │  │  │  ├─ 📄CellRCStack.svg
│  │        │  │  │  ├─ 📄CellStack.svg
│  │        │  │  │  ├─ 📄CharacteristicIdealDiodes.svg
│  │        │  │  │  ├─ 📄CharacteristicThyristors.svg
│  │        │  │  │  ├─ 📄ChopperStepDown.svg
│  │        │  │  │  ├─ 📄ChopperStepDown_R.svg
│  │        │  │  │  ├─ 📄ChopperStepDown_RL.svg
│  │        │  │  │  ├─ 📄ChopperStepUp.svg
│  │        │  │  │  ├─ 📄ChopperStepUp_R.svg
│  │        │  │  │  ├─ 📄ChuaCircuit.svg
│  │        │  │  │  ├─ 📄CloserWithArc.svg
│  │        │  │  │  ├─ 📄Comparator.svg
│  │        │  │  │  ├─ 📄CompareTransformers.svg
│  │        │  │  │  ├─ 📄Components.svg
│  │        │  │  │  ├─ 📄CompoundDCExcitation.svg
│  │        │  │  │  ├─ 📄Concept.svg
│  │        │  │  │  ├─ 📄ConditionalHeatPort.svg
│  │        │  │  │  ├─ 📄ConditionalSubstrate.svg
│  │        │  │  │  ├─ 📄Conductor.svg
│  │        │  │  │  ├─ 📄ConstantCurrent.svg
│  │        │  │  │  ├─ 📄Constants.svg
│  │        │  │  │  ├─ 📄ConstantVoltage.svg
│  │        │  │  │  ├─ 📄Contact.svg
│  │        │  │  │  ├─ 📄Control.svg
│  │        │  │  │  ├─ 📄ControlCircuit.svg
│  │        │  │  │  ├─ 📄ControlledCloserWithArc.svg
│  │        │  │  │  ├─ 📄ControlledDCDrives.svg
│  │        │  │  │  ├─ 📄ControlledIdealClosingSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealOpeningSwitch.svg
│  │        │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.svg
│  │        │  │  │  ├─ 📄ControlledOpenerWithArc.svg
│  │        │  │  │  ├─ 📄ControlledSwitchWithArc.svg
│  │        │  │  │  ├─ 📄convertAlpha.svg
│  │        │  │  │  ├─ 📄Converter.svg
│  │        │  │  │  ├─ 📄Converters.svg
│  │        │  │  │  ├─ 📄convertResistance.svg
│  │        │  │  │  ├─ 📄Core.svg
│  │        │  │  │  ├─ 📄CoreParameters.svg
│  │        │  │  │  ├─ 📄CosineCurrent.svg
│  │        │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄CosineVoltage.svg
│  │        │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄Counter.svg
│  │        │  │  │  ├─ 📄Counter3.svg
│  │        │  │  │  ├─ 📄CoupledInductors.svg
│  │        │  │  │  ├─ 📄Csemiconductor.svg
│  │        │  │  │  ├─ 📄CurrentControlledDCPM.svg
│  │        │  │  │  ├─ 📄CurrentQuasiRMSSensor.svg
│  │        │  │  │  ├─ 📄CurrentsCapacitances.svg
│  │        │  │  │  ├─ 📄CurrentSensor.svg
│  │        │  │  │  ├─ 📄CurrentSource.svg
│  │        │  │  │  ├─ 📄CurrrentsCapacitances.svg
│  │        │  │  │  ├─ 📄C_Capacitor.svg
│  │        │  │  │  ├─ 📄C_SEMI.svg
│  │        │  │  │  ├─ 📄DamperCage.svg
│  │        │  │  │  ├─ 📄DA_Converter.svg
│  │        │  │  │  ├─ 📄DCAC.svg
│  │        │  │  │  ├─ 📄DCACConcept.svg
│  │        │  │  │  ├─ 📄DcBrakeSettings.svg
│  │        │  │  │  ├─ 📄DCDC.svg
│  │        │  │  │  ├─ 📄DCDCConcept.svg
│  │        │  │  │  ├─ 📄DcdcInverter.svg
│  │        │  │  │  ├─ 📄DCEE_Start.svg
│  │        │  │  │  ├─ 📄DcElectricalExcitedData.svg
│  │        │  │  │  ├─ 📄DCMachines.svg
│  │        │  │  │  ├─ 📄DcPermanentMagnetData.svg
│  │        │  │  │  ├─ 📄DCpin.svg
│  │        │  │  │  ├─ 📄DCPM_Cooling.svg
│  │        │  │  │  ├─ 📄DCPM_CurrentControlled.svg
│  │        │  │  │  ├─ 📄DCPM_QuasiStatic.svg
│  │        │  │  │  ├─ 📄DCPM_Start.svg
│  │        │  │  │  ├─ 📄DCPM_Temperature.svg
│  │        │  │  │  ├─ 📄DCPM_withLosses.svg
│  │        │  │  │  ├─ 📄DcSeriesExcitedData.svg
│  │        │  │  │  ├─ 📄DCSE_SinglePhase.svg
│  │        │  │  │  ├─ 📄DCSE_Start.svg
│  │        │  │  │  ├─ 📄DCtwoPin.svg
│  │        │  │  │  ├─ 📄DCtwoPin1.svg
│  │        │  │  │  ├─ 📄DCtwoPin2.svg
│  │        │  │  │  ├─ 📄DC_CompareCharacteristics.svg
│  │        │  │  │  ├─ 📄DC_ElectricalExcited.svg
│  │        │  │  │  ├─ 📄DC_PermanentMagnet.svg
│  │        │  │  │  ├─ 📄DC_SeriesExcited.svg
│  │        │  │  │  ├─ 📄Dd.svg
│  │        │  │  │  ├─ 📄Dd00.svg
│  │        │  │  │  ├─ 📄Dd02.svg
│  │        │  │  │  ├─ 📄Dd04.svg
│  │        │  │  │  ├─ 📄Dd06.svg
│  │        │  │  │  ├─ 📄Dd08.svg
│  │        │  │  │  ├─ 📄Dd10.svg
│  │        │  │  │  ├─ 📄Delay.svg
│  │        │  │  │  ├─ 📄DelayParams.svg
│  │        │  │  │  ├─ 📄Delta.svg
│  │        │  │  │  ├─ 📄Der.svg
│  │        │  │  │  ├─ 📄Derivative.svg
│  │        │  │  │  ├─ 📄DEVqmeyer.svg
│  │        │  │  │  ├─ 📄DFF.svg
│  │        │  │  │  ├─ 📄DFFR.svg
│  │        │  │  │  ├─ 📄DFFREG.svg
│  │        │  │  │  ├─ 📄DFFREGL.svg
│  │        │  │  │  ├─ 📄DFFREGSRH.svg
│  │        │  │  │  ├─ 📄DFFREGSRL.svg
│  │        │  │  │  ├─ 📄DFFSR.svg
│  │        │  │  │  ├─ 📄DifferenceAmplifier.svg
│  │        │  │  │  ├─ 📄DifferentialAmplifier.svg
│  │        │  │  │  ├─ 📄DifferentialAmplifierData.svg
│  │        │  │  │  ├─ 📄Differentiator.svg
│  │        │  │  │  ├─ 📄Digital.svg
│  │        │  │  │  ├─ 📄DigitalClock.svg
│  │        │  │  │  ├─ 📄DigitalInput.svg
│  │        │  │  │  ├─ 📄DigitalOutput.svg
│  │        │  │  │  ├─ 📄DigitalSignal.svg
│  │        │  │  │  ├─ 📄Dimmer.svg
│  │        │  │  │  ├─ 📄Dimmer_R.svg
│  │        │  │  │  ├─ 📄Dimmer_RL.svg
│  │        │  │  │  ├─ 📄Diode.svg
│  │        │  │  │  ├─ 📄Diode2.svg
│  │        │  │  │  ├─ 📄DiodeBridge2mPulse.svg
│  │        │  │  │  ├─ 📄DiodeBridge2Pulse.svg
│  │        │  │  │  ├─ 📄DiodeCalc.svg
│  │        │  │  │  ├─ 📄diodeCalcAdditionalValues.svg
│  │        │  │  │  ├─ 📄diodeCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄DiodeCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄DiodeCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄DiodeCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄diodeInitEquations.svg
│  │        │  │  │  ├─ 📄diodeModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄DiodeModelLineParams.svg
│  │        │  │  │  ├─ 📄DiodeModelLineVariables.svg
│  │        │  │  │  ├─ 📄diodeNoBypassCode.svg
│  │        │  │  │  ├─ 📄DiodeParams.svg
│  │        │  │  │  ├─ 📄diodeRenameParameters.svg
│  │        │  │  │  ├─ 📄diodeRenameParametersDev.svg
│  │        │  │  │  ├─ 📄diodeRenameParametersDevTemp.svg
│  │        │  │  │  ├─ 📄DiodeVariables.svg
│  │        │  │  │  ├─ 📄DirectCapacitor.svg
│  │        │  │  │  ├─ 📄DirectInductor.svg
│  │        │  │  │  ├─ 📄Discrimination.svg
│  │        │  │  │  ├─ 📄DLATR.svg
│  │        │  │  │  ├─ 📄DLATRAM.svg
│  │        │  │  │  ├─ 📄DLATREG.svg
│  │        │  │  │  ├─ 📄DLATREGL.svg
│  │        │  │  │  ├─ 📄DLATREGSRH.svg
│  │        │  │  │  ├─ 📄DLATREGSRL.svg
│  │        │  │  │  ├─ 📄DLATROM.svg
│  │        │  │  │  ├─ 📄DLATSR.svg
│  │        │  │  │  ├─ 📄DQCurrentController.svg
│  │        │  │  │  ├─ 📄DQToThreePhase.svg
│  │        │  │  │  ├─ 📄drainCur.svg
│  │        │  │  │  ├─ 📄drainCurRevised.svg
│  │        │  │  │  ├─ 📄Drive.svg
│  │        │  │  │  ├─ 📄DriveDataDCPM.svg
│  │        │  │  │  ├─ 📄Dy.svg
│  │        │  │  │  ├─ 📄Dy01.svg
│  │        │  │  │  ├─ 📄Dy03.svg
│  │        │  │  │  ├─ 📄Dy05.svg
│  │        │  │  │  ├─ 📄Dy07.svg
│  │        │  │  │  ├─ 📄Dy09.svg
│  │        │  │  │  ├─ 📄Dy11.svg
│  │        │  │  │  ├─ 📄Dz.svg
│  │        │  │  │  ├─ 📄Dz00.svg
│  │        │  │  │  ├─ 📄Dz02.svg
│  │        │  │  │  ├─ 📄Dz04.svg
│  │        │  │  │  ├─ 📄Dz06.svg
│  │        │  │  │  ├─ 📄Dz08.svg
│  │        │  │  │  ├─ 📄Dz10.svg
│  │        │  │  │  ├─ 📄D_DIODE.svg
│  │        │  │  │  ├─ 📄Electrical.svg
│  │        │  │  │  ├─ 📄ElectricalExcitation.svg
│  │        │  │  │  ├─ 📄ElectricalPowerSensor.svg
│  │        │  │  │  ├─ 📄ElectricFieldStrength_cm.svg
│  │        │  │  │  ├─ 📄Enable.svg
│  │        │  │  │  ├─ 📄Enable1.svg
│  │        │  │  │  ├─ 📄Enable1m.svg
│  │        │  │  │  ├─ 📄Enable2.svg
│  │        │  │  │  ├─ 📄Enable2m.svg
│  │        │  │  │  ├─ 📄EnableLogic.svg
│  │        │  │  │  ├─ 📄energyGapDepTemp.svg
│  │        │  │  │  ├─ 📄energyGapDepTemp_old.svg
│  │        │  │  │  ├─ 📄equalityConstraint.svg
│  │        │  │  │  ├─ 📄ExampleData.svg
│  │        │  │  │  ├─ 📄Examples.svg
│  │        │  │  │  ├─ 📄ExampleTemplate.svg
│  │        │  │  │  ├─ 📄ExampleTemplates.svg
│  │        │  │  │  ├─ 📄ExponentialsCurrent.svg
│  │        │  │  │  ├─ 📄ExponentialsVoltage.svg
│  │        │  │  │  ├─ 📄ExpSineCurrent.svg
│  │        │  │  │  ├─ 📄ExpSineVoltage.svg
│  │        │  │  │  ├─ 📄E_VCV.svg
│  │        │  │  │  ├─ 📄E_VCV_POLY.svg
│  │        │  │  │  ├─ 📄factorY2D.svg
│  │        │  │  │  ├─ 📄factorY2DC.svg
│  │        │  │  │  ├─ 📄FCNiout_limit.svg
│  │        │  │  │  ├─ 📄FCNq_sum_limit.svg
│  │        │  │  │  ├─ 📄Feedback.svg
│  │        │  │  │  ├─ 📄Fet.svg
│  │        │  │  │  ├─ 📄FetModelLine.svg
│  │        │  │  │  ├─ 📄fetRenameParametersDev.svg
│  │        │  │  │  ├─ 📄Filter.svg
│  │        │  │  │  ├─ 📄FirstOrder.svg
│  │        │  │  │  ├─ 📄FlangeSupport.svg
│  │        │  │  │  ├─ 📄FlipFlop.svg
│  │        │  │  │  ├─ 📄FOURBIT.svg
│  │        │  │  │  ├─ 📄FourInverters.svg
│  │        │  │  │  ├─ 📄FourPin.svg
│  │        │  │  │  ├─ 📄FourPlug.svg
│  │        │  │  │  ├─ 📄FrequencySensor.svg
│  │        │  │  │  ├─ 📄FrequencySweepCurrentSource.svg
│  │        │  │  │  ├─ 📄FrequencySweepVoltageSource.svg
│  │        │  │  │  ├─ 📄Friction.svg
│  │        │  │  │  ├─ 📄FrictionParameters.svg
│  │        │  │  │  ├─ 📄FromDQ.svg
│  │        │  │  │  ├─ 📄FromPolar.svg
│  │        │  │  │  ├─ 📄FromSpacePhasor.svg
│  │        │  │  │  ├─ 📄FromSymmetricalComponents.svg
│  │        │  │  │  ├─ 📄FullAdder.svg
│  │        │  │  │  ├─ 📄Functions.svg
│  │        │  │  │  ├─ 📄FundamentalWaveMachine.svg
│  │        │  │  │  ├─ 📄F_CCC.svg
│  │        │  │  │  ├─ 📄F_CCC_POLY.svg
│  │        │  │  │  ├─ 📄Gain.svg
│  │        │  │  │  ├─ 📄GapEnergyPerEnergy.svg
│  │        │  │  │  ├─ 📄GapEnergyPerTemperature.svg
│  │        │  │  │  ├─ 📄Gates.svg
│  │        │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.svg
│  │        │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.svg
│  │        │  │  │  ├─ 📄GenerationOfFMUs.svg
│  │        │  │  │  ├─ 📄getMemory.svg
│  │        │  │  │  ├─ 📄getNumberOfElectricalPins.svg
│  │        │  │  │  ├─ 📄Glossar.svg
│  │        │  │  │  ├─ 📄Graetz.svg
│  │        │  │  │  ├─ 📄GraetzRectifier.svg
│  │        │  │  │  ├─ 📄Ground.svg
│  │        │  │  │  ├─ 📄Gyrator.svg
│  │        │  │  │  ├─ 📄G_VCC.svg
│  │        │  │  │  ├─ 📄G_VCC_POLY.svg
│  │        │  │  │  ├─ 📄HalfAdder.svg
│  │        │  │  │  ├─ 📄HalfControlledBridge2mPulse.svg
│  │        │  │  │  ├─ 📄HalfControlledBridge2Pulse.svg
│  │        │  │  │  ├─ 📄HallSensor.svg
│  │        │  │  │  ├─ 📄HBridge.svg
│  │        │  │  │  ├─ 📄HBridge_DC_Drive.svg
│  │        │  │  │  ├─ 📄HBridge_R.svg
│  │        │  │  │  ├─ 📄HBridge_RL.svg
│  │        │  │  │  ├─ 📄HeatingMOSInverter.svg
│  │        │  │  │  ├─ 📄HeatingNPN_NORGate.svg
│  │        │  │  │  ├─ 📄HeatingPNP_NORGate.svg
│  │        │  │  │  ├─ 📄HeatingRectifier.svg
│  │        │  │  │  ├─ 📄HighPass.svg
│  │        │  │  │  ├─ 📄H_CCV.svg
│  │        │  │  │  ├─ 📄H_CCV_POLY.svg
│  │        │  │  │  ├─ 📄Icons.svg
│  │        │  │  │  ├─ 📄Ideal.svg
│  │        │  │  │  ├─ 📄IdealACDCConverter.svg
│  │        │  │  │  ├─ 📄IdealClosingSwitch.svg
│  │        │  │  │  ├─ 📄IdealCommutingSwitch.svg
│  │        │  │  │  ├─ 📄IdealCore.svg
│  │        │  │  │  ├─ 📄IdealDcDc.svg
│  │        │  │  │  ├─ 📄IdealDiode.svg
│  │        │  │  │  ├─ 📄IdealGTOThyristor.svg
│  │        │  │  │  ├─ 📄IdealIntermediateSwitch.svg
│  │        │  │  │  ├─ 📄IdealizedOpAmpLimited.svg
│  │        │  │  │  ├─ 📄IdealOpAmp.svg
│  │        │  │  │  ├─ 📄IdealOpAmp3Pin.svg
│  │        │  │  │  ├─ 📄IdealOpAmpLimited.svg
│  │        │  │  │  ├─ 📄IdealOpeningSwitch.svg
│  │        │  │  │  ├─ 📄IdealSemiconductor.svg
│  │        │  │  │  ├─ 📄IdealSwitch.svg
│  │        │  │  │  ├─ 📄IdealSwitchWithArc.svg
│  │        │  │  │  ├─ 📄IdealThyristor.svg
│  │        │  │  │  ├─ 📄IdealTransformer.svg
│  │        │  │  │  ├─ 📄IdealTriac.svg
│  │        │  │  │  ├─ 📄IdealTriacCircuit.svg
│  │        │  │  │  ├─ 📄IdealTwoWaySwitch.svg
│  │        │  │  │  ├─ 📄Idle.svg
│  │        │  │  │  ├─ 📄IMC_Conveyor.svg
│  │        │  │  │  ├─ 📄IMC_DCBraking.svg
│  │        │  │  │  ├─ 📄IMC_DOL.svg
│  │        │  │  │  ├─ 📄IMC_Initialize.svg
│  │        │  │  │  ├─ 📄IMC_Inverter.svg
│  │        │  │  │  ├─ 📄IMC_InverterDrive.svg
│  │        │  │  │  ├─ 📄IMC_Steinmetz.svg
│  │        │  │  │  ├─ 📄IMC_Transformer.svg
│  │        │  │  │  ├─ 📄IMC_withLosses.svg
│  │        │  │  │  ├─ 📄IMC_YD.svg
│  │        │  │  │  ├─ 📄IMC_YDarc.svg
│  │        │  │  │  ├─ 📄Impedance.svg
│  │        │  │  │  ├─ 📄IMS_Start.svg
│  │        │  │  │  ├─ 📄IM_SlipRing.svg
│  │        │  │  │  ├─ 📄IM_SlipRingData.svg
│  │        │  │  │  ├─ 📄IM_SquirrelCage.svg
│  │        │  │  │  ├─ 📄IM_SquirrelCageData.svg
│  │        │  │  │  ├─ 📄index.html
│  │        │  │  │  ├─ 📄indexNonPositiveSequence.svg
│  │        │  │  │  ├─ 📄indexPositiveSequence.svg
│  │        │  │  │  ├─ 📄InductionMachineData.svg
│  │        │  │  │  ├─ 📄InductionMachines.svg
│  │        │  │  │  ├─ 📄InductiveCouplePinIn.svg
│  │        │  │  │  ├─ 📄InductiveCouplePinOut.svg
│  │        │  │  │  ├─ 📄Inductor.svg
│  │        │  │  │  ├─ 📄InductorDC.svg
│  │        │  │  │  ├─ 📄InertialDelay.svg
│  │        │  │  │  ├─ 📄InertialDelaySensitive.svg
│  │        │  │  │  ├─ 📄InertialDelaySensitiveVector.svg
│  │        │  │  │  ├─ 📄initJunctionVoltagesRevised.svg
│  │        │  │  │  ├─ 📄Integrator.svg
│  │        │  │  │  ├─ 📄Interfaces.svg
│  │        │  │  │  ├─ 📄Internal.svg
│  │        │  │  │  ├─ 📄IntersectivePWM.svg
│  │        │  │  │  ├─ 📄Introduction.svg
│  │        │  │  │  ├─ 📄INV3S.svg
│  │        │  │  │  ├─ 📄INV3SL.svg
│  │        │  │  │  ├─ 📄InverseCapacitor.svg
│  │        │  │  │  ├─ 📄InverseElectricCurrent.svg
│  │        │  │  │  ├─ 📄InverseInductor.svg
│  │        │  │  │  ├─ 📄Inverter.svg
│  │        │  │  │  ├─ 📄InvertersApartRecord.svg
│  │        │  │  │  ├─ 📄InvertersExtendedModel.svg
│  │        │  │  │  ├─ 📄InvertingAmp.svg
│  │        │  │  │  ├─ 📄InvertingAmplifier.svg
│  │        │  │  │  ├─ 📄InvertingSchmittTrigger.svg
│  │        │  │  │  ├─ 📄InvGate.svg
│  │        │  │  │  ├─ 📄I_constant.svg
│  │        │  │  │  ├─ 📄I_exp.svg
│  │        │  │  │  ├─ 📄I_pulse.svg
│  │        │  │  │  ├─ 📄I_pwl.svg
│  │        │  │  │  ├─ 📄I_sffm.svg
│  │        │  │  │  ├─ 📄I_sin.svg
│  │        │  │  │  ├─ 📄JFET.svg
│  │        │  │  │  ├─ 📄jfetCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄jfetInitEquations.svg
│  │        │  │  │  ├─ 📄JfetModelLine.svg
│  │        │  │  │  ├─ 📄jfetModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄jfetNoBypassCode.svg
│  │        │  │  │  ├─ 📄jfetRenameParameters.svg
│  │        │  │  │  ├─ 📄JKFF.svg
│  │        │  │  │  ├─ 📄junction2.svg
│  │        │  │  │  ├─ 📄junction2SPICE3BJT.svg
│  │        │  │  │  ├─ 📄junction2SPICE3MOSFETRevised.svg
│  │        │  │  │  ├─ 📄junction3.svg
│  │        │  │  │  ├─ 📄junctionCapCoeffs.svg
│  │        │  │  │  ├─ 📄junctionCapRevised.svg
│  │        │  │  │  ├─ 📄junctionCapTransTime.svg
│  │        │  │  │  ├─ 📄junctionParamDepTempSPICE3.svg
│  │        │  │  │  ├─ 📄junctionPotDepTemp.svg
│  │        │  │  │  ├─ 📄junctionVCrit.svg
│  │        │  │  │  ├─ 📄junctionVoltage23SPICE3.svg
│  │        │  │  │  ├─ 📄J_NJFJFET.svg
│  │        │  │  │  ├─ 📄J_PJFJFET.svg
│  │        │  │  │  ├─ 📄K_CoupledInductors.svg
│  │        │  │  │  ├─ 📄LCOscillator.svg
│  │        │  │  │  ├─ 📄LessThreshold.svg
│  │        │  │  │  ├─ 📄LimitedPI.svg
│  │        │  │  │  ├─ 📄limitJunctionVoltageRevised.svg
│  │        │  │  │  ├─ 📄LinearTemperatureCoefficient20.svg
│  │        │  │  │  ├─ 📄linearTemperatureDependency.svg
│  │        │  │  │  ├─ 📄Lines.svg
│  │        │  │  │  ├─ 📄Literature.svg
│  │        │  │  │  ├─ 📄Logic.svg
│  │        │  │  │  ├─ 📄LogicToBoolean.svg
│  │        │  │  │  ├─ 📄LogicToReal.svg
│  │        │  │  │  ├─ 📄LogicToUX01.svg
│  │        │  │  │  ├─ 📄LogicToX01.svg
│  │        │  │  │  ├─ 📄LogicToX01Z.svg
│  │        │  │  │  ├─ 📄Losses.svg
│  │        │  │  │  ├─ 📄LowPass.svg
│  │        │  │  │  ├─ 📄L_Inductor.svg
│  │        │  │  │  ├─ 📄Machine.svg
│  │        │  │  │  ├─ 📄Machines.svg
│  │        │  │  │  ├─ 📄MaterialParameters.svg
│  │        │  │  │  ├─ 📄MechanicalPowerSensor.svg
│  │        │  │  │  ├─ 📄Memories.svg
│  │        │  │  │  ├─ 📄MemoryBase.svg
│  │        │  │  │  ├─ 📄MIMO.svg
│  │        │  │  │  ├─ 📄MISO.svg
│  │        │  │  │  ├─ 📄MNmos.svg
│  │        │  │  │  ├─ 📄Model.svg
│  │        │  │  │  ├─ 📄ModelcardBJT.svg
│  │        │  │  │  ├─ 📄ModelcardBJT2.svg
│  │        │  │  │  ├─ 📄ModelcardC.svg
│  │        │  │  │  ├─ 📄ModelcardCAPACITOR.svg
│  │        │  │  │  ├─ 📄ModelcardDIODE.svg
│  │        │  │  │  ├─ 📄ModelcardJFET.svg
│  │        │  │  │  ├─ 📄ModelcardMOS.svg
│  │        │  │  │  ├─ 📄ModelcardMOS2.svg
│  │        │  │  │  ├─ 📄ModelcardR.svg
│  │        │  │  │  ├─ 📄ModelcardRESISTOR.svg
│  │        │  │  │  ├─ 📄MOS.svg
│  │        │  │  │  ├─ 📄Mos1.svg
│  │        │  │  │  ├─ 📄Mos1Calc.svg
│  │        │  │  │  ├─ 📄Mos1ModelLineParams.svg
│  │        │  │  │  ├─ 📄mos1ModelLineParamsInitEquations.svg
│  │        │  │  │  ├─ 📄mos1RenameParameters.svg
│  │        │  │  │  ├─ 📄mos1RenameParametersDev.svg
│  │        │  │  │  ├─ 📄MOS2.svg
│  │        │  │  │  ├─ 📄Mos2Calc.svg
│  │        │  │  │  ├─ 📄mos2CalcCalcTempDependenciesRevised.svg
│  │        │  │  │  ├─ 📄mos2CalcInitEquationsRevised.svg
│  │        │  │  │  ├─ 📄mos2CalcNoBypassCodeRevised.svg
│  │        │  │  │  ├─ 📄Mos2ModelLineParams.svg
│  │        │  │  │  ├─ 📄mos2ModelLineParamsInitEquationsRevised.svg
│  │        │  │  │  ├─ 📄Mos2ModelLineVariables.svg
│  │        │  │  │  ├─ 📄mos2RenameParametersDev.svg
│  │        │  │  │  ├─ 📄mos2RenameParametersRevised.svg
│  │        │  │  │  ├─ 📄MosCalc.svg
│  │        │  │  │  ├─ 📄mosCalcCalcTempDependencies.svg
│  │        │  │  │  ├─ 📄mosCalcDEVqmeyer.svg
│  │        │  │  │  ├─ 📄mosCalcInitEquations.svg
│  │        │  │  │  ├─ 📄mosCalcNoBypassCode.svg
│  │        │  │  │  ├─ 📄Mosfet.svg
│  │        │  │  │  ├─ 📄MosfetCalc.svg
│  │        │  │  │  ├─ 📄mosfetInitEquations.svg
│  │        │  │  │  ├─ 📄MosfetModelLine.svg
│  │        │  │  │  ├─ 📄mosfetModelLineInitEquations.svg
│  │        │  │  │  ├─ 📄MosfetModelLineParams.svg
│  │        │  │  │  ├─ 📄mosfetRenameParametersDev.svg
│  │        │  │  │  ├─ 📄MosModelLineParams.svg
│  │        │  │  │  ├─ 📄MosModelLineVariables.svg
│  │        │  │  │  ├─ 📄MPmos.svg
│  │        │  │  │  ├─ 📄MultiDelta.svg
│  │        │  │  │  ├─ 📄Multiplexer.svg
│  │        │  │  │  ├─ 📄Multiplexers.svg
│  │        │  │  │  ├─ 📄MultiSensor.svg
│  │        │  │  │  ├─ 📄MultiStar.svg
│  │        │  │  │  ├─ 📄MultiStarResistance.svg
│  │        │  │  │  ├─ 📄MultiTerminalBox.svg
│  │        │  │  │  ├─ 📄Multivibrator.svg
│  │        │  │  │  ├─ 📄MutualInductor.svg
│  │        │  │  │  ├─ 📄MUX2x1.svg
│  │        │  │  │  ├─ 📄MUX4.svg
│  │        │  │  │  ├─ 📄M_NMOS.svg
│  │        │  │  │  ├─ 📄M_NMOS2.svg
│  │        │  │  │  ├─ 📄M_OLine.svg
│  │        │  │  │  ├─ 📄M_PMOS.svg
│  │        │  │  │  ├─ 📄M_PMOS2.svg
│  │        │  │  │  ├─ 📄M_Transformer.svg
│  │        │  │  │  ├─ 📄NamingPrinciple.svg
│  │        │  │  │  ├─ 📄Nand.svg
│  │        │  │  │  ├─ 📄NandGate.svg
│  │        │  │  │  ├─ 📄NegativePin.svg
│  │        │  │  │  ├─ 📄NegativePlug.svg
│  │        │  │  │  ├─ 📄NMOS.svg
│  │        │  │  │  ├─ 📄NonInvertingAmplifier.svg
│  │        │  │  │  ├─ 📄NonlinearResistor.svg
│  │        │  │  │  ├─ 📄Nor.svg
│  │        │  │  │  ├─ 📄NorGate.svg
│  │        │  │  │  ├─ 📄Not.svg
│  │        │  │  │  ├─ 📄NPN.svg
│  │        │  │  │  ├─ 📄NRXFER.svg
│  │        │  │  │  ├─ 📄NRXFERGATE.svg
│  │        │  │  │  ├─ 📄numberOfSymmetricBaseSystems.svg
│  │        │  │  │  ├─ 📄NXFER.svg
│  │        │  │  │  ├─ 📄NXFERGATE.svg
│  │        │  │  │  ├─ 📄OLine.svg
│  │        │  │  │  ├─ 📄ONEBIT.svg
│  │        │  │  │  ├─ 📄OnePort.svg
│  │        │  │  │  ├─ 📄OpAmp.svg
│  │        │  │  │  ├─ 📄OpAmpCircuits.svg
│  │        │  │  │  ├─ 📄OpAmpDetailed.svg
│  │        │  │  │  ├─ 📄OpAmps.svg
│  │        │  │  │  ├─ 📄OpenerWithArc.svg
│  │        │  │  │  ├─ 📄Or.svg
│  │        │  │  │  ├─ 📄OrGate.svg
│  │        │  │  │  ├─ 📄Oscillator.svg
│  │        │  │  │  ├─ 📄Overview.svg
│  │        │  │  │  ├─ 📄OvervoltageProtection.svg
│  │        │  │  │  ├─ 📄ParallelResonance.svg
│  │        │  │  │  ├─ 📄ParameterHandling.svg
│  │        │  │  │  ├─ 📄Parameterization.svg
│  │        │  │  │  ├─ 📄ParameterRecords.svg
│  │        │  │  │  ├─ 📄PartialAirGap.svg
│  │        │  │  │  ├─ 📄PartialAirGapDC.svg
│  │        │  │  │  ├─ 📄PartialBasicDCMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicInductionMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicMachine.svg
│  │        │  │  │  ├─ 📄PartialBasicTransformer.svg
│  │        │  │  │  ├─ 📄PartialConditionalHeatPort.svg
│  │        │  │  │  ├─ 📄PartialControlledDCPM.svg
│  │        │  │  │  ├─ 📄PartialCore.svg
│  │        │  │  │  ├─ 📄PartialOpAmp.svg
│  │        │  │  │  ├─ 📄PartialPowerBalanceDCMachines.svg
│  │        │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalAmbientDCMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalPortDCMachines.svg
│  │        │  │  │  ├─ 📄PartialThermalPortInductionMachines.svg
│  │        │  │  │  ├─ 📄PermanentMagnet.svg
│  │        │  │  │  ├─ 📄PermanentMagnetLosses.svg
│  │        │  │  │  ├─ 📄PermanentMagnetLossParameters.svg
│  │        │  │  │  ├─ 📄PermanentMagnetWithLosses.svg
│  │        │  │  │  ├─ 📄PerVolume.svg
│  │        │  │  │  ├─ 📄PhaseOrientation.svg
│  │        │  │  │  ├─ 📄PI.svg
│  │        │  │  │  ├─ 📄Pin.svg
│  │        │  │  │  ├─ 📄Plug.svg
│  │        │  │  │  ├─ 📄PlugToPins_n.svg
│  │        │  │  │  ├─ 📄PlugToPins_p.svg
│  │        │  │  │  ├─ 📄PlugToPin_n.svg
│  │        │  │  │  ├─ 📄PlugToPin_p.svg
│  │        │  │  │  ├─ 📄PMOS.svg
│  │        │  │  │  ├─ 📄PNP.svg
│  │        │  │  │  ├─ 📄poly.svg
│  │        │  │  │  ├─ 📄Polyphase.svg
│  │        │  │  │  ├─ 📄Polyphase2Level.svg
│  │        │  │  │  ├─ 📄PolyphaseRectifier.svg
│  │        │  │  │  ├─ 📄PolyphaseRectifierData.svg
│  │        │  │  │  ├─ 📄PolyphaseTriac.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel_R.svg
│  │        │  │  │  ├─ 📄PolyphaseTwoLevel_RL.svg
│  │        │  │  │  ├─ 📄PositionControlledDCPM.svg
│  │        │  │  │  ├─ 📄PositivePin.svg
│  │        │  │  │  ├─ 📄PositivePlug.svg
│  │        │  │  │  ├─ 📄PotentialSensor.svg
│  │        │  │  │  ├─ 📄Potentiometer.svg
│  │        │  │  │  ├─ 📄Power.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCCE.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCEE.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCPM.svg
│  │        │  │  │  ├─ 📄PowerBalanceDCSE.svg
│  │        │  │  │  ├─ 📄PowerBalanceIMC.svg
│  │        │  │  │  ├─ 📄PowerBalanceIMS.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMEE.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMPM.svg
│  │        │  │  │  ├─ 📄PowerBalanceSMR.svg
│  │        │  │  │  ├─ 📄PowerBalanceTransformer.svg
│  │        │  │  │  ├─ 📄PowerConverters.svg
│  │        │  │  │  ├─ 📄PowerSensor.svg
│  │        │  │  │  ├─ 📄PRXFERGATE.svg
│  │        │  │  │  ├─ 📄Pulse.svg
│  │        │  │  │  ├─ 📄PulseCurrent.svg
│  │        │  │  │  ├─ 📄PulseSeries.svg
│  │        │  │  │  ├─ 📄PulseVoltage.svg
│  │        │  │  │  ├─ 📄PWM.svg
│  │        │  │  │  ├─ 📄PWMType.svg
│  │        │  │  │  ├─ 📄PXFERGATE.svg
│  │        │  │  │  ├─ 📄QuasiRMS.svg
│  │        │  │  │  ├─ 📄QuasiStatic.svg
│  │        │  │  │  ├─ 📄QuasiStaticDCMachines.svg
│  │        │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.svg
│  │        │  │  │  ├─ 📄QuasiStaticMachine.svg
│  │        │  │  │  ├─ 📄QuasiStaticTransformer.svg
│  │        │  │  │  ├─ 📄Q_NPNBJT.svg
│  │        │  │  │  ├─ 📄Q_PNPBJT.svg
│  │        │  │  │  ├─ 📄RAM.svg
│  │        │  │  │  ├─ 📄RampCurrent.svg
│  │        │  │  │  ├─ 📄RampedRheostat.svg
│  │        │  │  │  ├─ 📄RampVoltage.svg
│  │        │  │  │  ├─ 📄RCData.svg
│  │        │  │  │  ├─ 📄ReactivePowerSensor.svg
│  │        │  │  │  ├─ 📄RealSwitch.svg
│  │        │  │  │  ├─ 📄RealToLogic.svg
│  │        │  │  │  ├─ 📄Rectifier.svg
│  │        │  │  │  ├─ 📄Rectifier12pulse.svg
│  │        │  │  │  ├─ 📄Rectifier1Pulse.svg
│  │        │  │  │  ├─ 📄Rectifier6pulse.svg
│  │        │  │  │  ├─ 📄RectifierBridge2mPulse.svg
│  │        │  │  │  ├─ 📄RectifierBridge2Pulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄RectifierCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄Reference.svg
│  │        │  │  │  ├─ 📄ReferenceCurrentSource.svg
│  │        │  │  │  ├─ 📄References.svg
│  │        │  │  │  ├─ 📄ReferenceSensor.svg
│  │        │  │  │  ├─ 📄ReferenceSource.svg
│  │        │  │  │  ├─ 📄ReferenceSystem.svg
│  │        │  │  │  ├─ 📄ReferenceType.svg
│  │        │  │  │  ├─ 📄ReferenceVoltageSource.svg
│  │        │  │  │  ├─ 📄Registers.svg
│  │        │  │  │  ├─ 📄RelativeSensor.svg
│  │        │  │  │  ├─ 📄RelativeSensorElementary.svg
│  │        │  │  │  ├─ 📄ReleaseNotes.svg
│  │        │  │  │  ├─ 📄resDepGeom.svg
│  │        │  │  │  ├─ 📄resDepTemp.svg
│  │        │  │  │  ├─ 📄Resistor.svg
│  │        │  │  │  ├─ 📄resistorInitEquations.svg
│  │        │  │  │  ├─ 📄ResistorModelLineParams.svg
│  │        │  │  │  ├─ 📄ResistorParams.svg
│  │        │  │  │  ├─ 📄resistorRenameParameters.svg
│  │        │  │  │  ├─ 📄resistorRenameParametersDev.svg
│  │        │  │  │  ├─ 📄ResistorVariables.svg
│  │        │  │  │  ├─ 📄ResonanceCircuits.svg
│  │        │  │  │  ├─ 📄RotationalEMF.svg
│  │        │  │  │  ├─ 📄Rotator.svg
│  │        │  │  │  ├─ 📄RotorDisplacementAngle.svg
│  │        │  │  │  ├─ 📄RS.svg
│  │        │  │  │  ├─ 📄Rsemiconductor.svg
│  │        │  │  │  ├─ 📄RSFF.svg
│  │        │  │  │  ├─ 📄R_Resistor.svg
│  │        │  │  │  ├─ 📄R_SEMI.svg
│  │        │  │  │  ├─ 📄SaturatingInductor.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3JFET.svg
│  │        │  │  │  ├─ 📄saturationCurDepTempSPICE3MOSFET.svg
│  │        │  │  │  ├─ 📄SawToothCurrent.svg
│  │        │  │  │  ├─ 📄SawToothVoltage.svg
│  │        │  │  │  ├─ 📄SchmittTrigger.svg
│  │        │  │  │  ├─ 📄segment.svg
│  │        │  │  │  ├─ 📄segment_last.svg
│  │        │  │  │  ├─ 📄Semiconductors.svg
│  │        │  │  │  ├─ 📄Sensors.svg
│  │        │  │  │  ├─ 📄SeriesBode.svg
│  │        │  │  │  ├─ 📄SeriesResonance.svg
│  │        │  │  │  ├─ 📄Set.svg
│  │        │  │  │  ├─ 📄Short.svg
│  │        │  │  │  ├─ 📄ShowImpedance.svg
│  │        │  │  │  ├─ 📄ShowSaturatingInductor.svg
│  │        │  │  │  ├─ 📄ShowVariableResistor.svg
│  │        │  │  │  ├─ 📄Signal2mPulse.svg
│  │        │  │  │  ├─ 📄SignalCurrent.svg
│  │        │  │  │  ├─ 📄SignalGenerator.svg
│  │        │  │  │  ├─ 📄SignalPWM.svg
│  │        │  │  │  ├─ 📄SignalVoltage.svg
│  │        │  │  │  ├─ 📄SimpleTriac.svg
│  │        │  │  │  ├─ 📄SimpleTriacCircuit.svg
│  │        │  │  │  ├─ 📄SinCosEvaluation.svg
│  │        │  │  │  ├─ 📄SinCosResolver.svg
│  │        │  │  │  ├─ 📄SineCurrent.svg
│  │        │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄SineVoltage.svg
│  │        │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.svg
│  │        │  │  │  ├─ 📄SinglePhase.svg
│  │        │  │  │  ├─ 📄SinglePhase2Level.svg
│  │        │  │  │  ├─ 📄SinglePhaseTriac.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel_R.svg
│  │        │  │  │  ├─ 📄SinglePhaseTwoLevel_RL.svg
│  │        │  │  │  ├─ 📄SingleToPolyphase.svg
│  │        │  │  │  ├─ 📄SISO.svg
│  │        │  │  │  ├─ 📄SMEE_DOL.svg
│  │        │  │  │  ├─ 📄SMEE_Generator.svg
│  │        │  │  │  ├─ 📄SMEE_LoadDump.svg
│  │        │  │  │  ├─ 📄SMEE_Rectifier.svg
│  │        │  │  │  ├─ 📄SMPM_Braking.svg
│  │        │  │  │  ├─ 📄SMPM_CurrentSource.svg
│  │        │  │  │  ├─ 📄SMPM_Inverter.svg
│  │        │  │  │  ├─ 📄SMPM_NoLoad.svg
│  │        │  │  │  ├─ 📄SMPM_ResistiveBraking.svg
│  │        │  │  │  ├─ 📄SMPM_VoltageSource.svg
│  │        │  │  │  ├─ 📄SMR_DOL.svg
│  │        │  │  │  ├─ 📄SMR_Inverter.svg
│  │        │  │  │  ├─ 📄SM_ElectricalExcited.svg
│  │        │  │  │  ├─ 📄SM_ElectricalExcitedData.svg
│  │        │  │  │  ├─ 📄SM_PermanentMagnet.svg
│  │        │  │  │  ├─ 📄SM_PermanentMagnetData.svg
│  │        │  │  │  ├─ 📄SM_ReluctanceRotor.svg
│  │        │  │  │  ├─ 📄SM_ReluctanceRotorData.svg
│  │        │  │  │  ├─ 📄SoftStartControl.svg
│  │        │  │  │  ├─ 📄SoftStarter.svg
│  │        │  │  │  ├─ 📄SoftStarterModeOfOperation.svg
│  │        │  │  │  ├─ 📄Source.svg
│  │        │  │  │  ├─ 📄Sources.svg
│  │        │  │  │  ├─ 📄SpacePhasor.svg
│  │        │  │  │  ├─ 📄SpacePhasors.svg
│  │        │  │  │  ├─ 📄SpeedControlledDCPM.svg
│  │        │  │  │  ├─ 📄Spice3.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkDifferentialPair.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkFourBitBinaryAdder.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkMosfetCharacterization.svg
│  │        │  │  │  ├─ 📄Spice3BenchmarkRtlInverter.svg
│  │        │  │  │  ├─ 📄SpiceConstants.svg
│  │        │  │  │  ├─ 📄Spicenetlist.svg
│  │        │  │  │  ├─ 📄SpiceRoot.svg
│  │        │  │  │  ├─ 📄SplitToSubsystems.svg
│  │        │  │  │  ├─ 📄SquirrelCage.svg
│  │        │  │  │  ├─ 📄Stack.svg
│  │        │  │  │  ├─ 📄StackBus.svg
│  │        │  │  │  ├─ 📄StackBusArrays.svg
│  │        │  │  │  ├─ 📄StackData.svg
│  │        │  │  │  ├─ 📄StackRC.svg
│  │        │  │  │  ├─ 📄Star.svg
│  │        │  │  │  ├─ 📄Step.svg
│  │        │  │  │  ├─ 📄StepCurrent.svg
│  │        │  │  │  ├─ 📄StepVoltage.svg
│  │        │  │  │  ├─ 📄StrayLoad.svg
│  │        │  │  │  ├─ 📄StrayLoadParameters.svg
│  │        │  │  │  ├─ 📄Strength.svg
│  │        │  │  │  ├─ 📄Subtracter.svg
│  │        │  │  │  ├─ 📄SuperCap.svg
│  │        │  │  │  ├─ 📄SuperCapDischargeCharge.svg
│  │        │  │  │  ├─ 📄SupplyVoltage.svg
│  │        │  │  │  ├─ 📄SVPWM.svg
│  │        │  │  │  ├─ 📄SwitchedCapacitor.svg
│  │        │  │  │  ├─ 📄SwitchedRheostat.svg
│  │        │  │  │  ├─ 📄SwitchingDcDc.svg
│  │        │  │  │  ├─ 📄SwitchWithArc.svg
│  │        │  │  │  ├─ 📄SwitchYD.svg
│  │        │  │  │  ├─ 📄SwitchYDwithArc.svg
│  │        │  │  │  ├─ 📄SymmetricalComponents.svg
│  │        │  │  │  ├─ 📄symmetricBackTransformationMatrix.svg
│  │        │  │  │  ├─ 📄symmetricOrientation.svg
│  │        │  │  │  ├─ 📄symmetricOrientationMatrix.svg
│  │        │  │  │  ├─ 📄symmetricTransformationMatrix.svg
│  │        │  │  │  ├─ 📄SynchronousMachineData.svg
│  │        │  │  │  ├─ 📄SynchronousMachines.svg
│  │        │  │  │  ├─ 📄Table.svg
│  │        │  │  │  ├─ 📄TableCurrent.svg
│  │        │  │  │  ├─ 📄Tables.svg
│  │        │  │  │  ├─ 📄TableVoltage.svg
│  │        │  │  │  ├─ 📄TerminalBox.svg
│  │        │  │  │  ├─ 📄TestSensors.svg
│  │        │  │  │  ├─ 📄Thermal.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCCE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCEE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCPM.svg
│  │        │  │  │  ├─ 📄ThermalAmbientDCSE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientIMC.svg
│  │        │  │  │  ├─ 📄ThermalAmbientIMS.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMEE.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMPM.svg
│  │        │  │  │  ├─ 📄ThermalAmbientSMR.svg
│  │        │  │  │  ├─ 📄ThermalAmbientTransformer.svg
│  │        │  │  │  ├─ 📄ThermalPortDCCE.svg
│  │        │  │  │  ├─ 📄ThermalPortDCEE.svg
│  │        │  │  │  ├─ 📄ThermalPortDCPM.svg
│  │        │  │  │  ├─ 📄ThermalPortDCSE.svg
│  │        │  │  │  ├─ 📄ThermalPortIMC.svg
│  │        │  │  │  ├─ 📄ThermalPortIMS.svg
│  │        │  │  │  ├─ 📄ThermalPortSMEE.svg
│  │        │  │  │  ├─ 📄ThermalPortSMPM.svg
│  │        │  │  │  ├─ 📄ThermalPortSMR.svg
│  │        │  │  │  ├─ 📄ThermalPortTransformer.svg
│  │        │  │  │  ├─ 📄ThreePhaseTwoLevel_PWM.svg
│  │        │  │  │  ├─ 📄Thyristor.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse_R.svg
│  │        │  │  │  ├─ 📄Thyristor1Pulse_R_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorBehaviourTest.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.svg
│  │        │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.svg
│  │        │  │  │  ├─ 📄TLine1.svg
│  │        │  │  │  ├─ 📄TLine2.svg
│  │        │  │  │  ├─ 📄TLine3.svg
│  │        │  │  │  ├─ 📄ToDQ.svg
│  │        │  │  │  ├─ 📄ToPolar.svg
│  │        │  │  │  ├─ 📄ToSpacePhasor.svg
│  │        │  │  │  ├─ 📄Transformer.svg
│  │        │  │  │  ├─ 📄TransformerData.svg
│  │        │  │  │  ├─ 📄Transformers.svg
│  │        │  │  │  ├─ 📄TransformerTestbench.svg
│  │        │  │  │  ├─ 📄TransformerYD.svg
│  │        │  │  │  ├─ 📄TransformerYY.svg
│  │        │  │  │  ├─ 📄TransientCellRecord.svg
│  │        │  │  │  ├─ 📄TransientData.svg
│  │        │  │  │  ├─ 📄TransientMachine.svg
│  │        │  │  │  ├─ 📄TransientModel.svg
│  │        │  │  │  ├─ 📄TransientRecordsPackage.svg
│  │        │  │  │  ├─ 📄TransientStackRecord.svg
│  │        │  │  │  ├─ 📄TransientTransformer.svg
│  │        │  │  │  ├─ 📄Transistor.svg
│  │        │  │  │  ├─ 📄TranslationalEMF.svg
│  │        │  │  │  ├─ 📄TransportDelay.svg
│  │        │  │  │  ├─ 📄TrapezoidCurrent.svg
│  │        │  │  │  ├─ 📄TrapezoidVoltage.svg
│  │        │  │  │  ├─ 📄Tristates.svg
│  │        │  │  │  ├─ 📄TWOBIT.svg
│  │        │  │  │  ├─ 📄TwoPin.svg
│  │        │  │  │  ├─ 📄TwoPinElementary.svg
│  │        │  │  │  ├─ 📄TwoPlug.svg
│  │        │  │  │  ├─ 📄TwoPlugElementary.svg
│  │        │  │  │  ├─ 📄TwoPort.svg
│  │        │  │  │  ├─ 📄TwoPortControlledSources.svg
│  │        │  │  │  ├─ 📄Types.svg
│  │        │  │  │  ├─ 📄ULine.svg
│  │        │  │  │  ├─ 📄UnsymmetricalLoad.svg
│  │        │  │  │  ├─ 📄useInitialConditions.svg
│  │        │  │  │  ├─ 📄Useofsemiconductors.svg
│  │        │  │  │  ├─ 📄UsersGuide.svg
│  │        │  │  │  ├─ 📄Utilities.svg
│  │        │  │  │  ├─ 📄UX01.svg
│  │        │  │  │  ├─ 📄VariableAdmittance.svg
│  │        │  │  │  ├─ 📄VariableCapacitor.svg
│  │        │  │  │  ├─ 📄VariableConductor.svg
│  │        │  │  │  ├─ 📄VariableCurrentSource.svg
│  │        │  │  │  ├─ 📄VariableImpedance.svg
│  │        │  │  │  ├─ 📄VariableInductor.svg
│  │        │  │  │  ├─ 📄VariableResistor.svg
│  │        │  │  │  ├─ 📄VariableVoltageSource.svg
│  │        │  │  │  ├─ 📄VCC.svg
│  │        │  │  │  ├─ 📄VCV.svg
│  │        │  │  │  ├─ 📄VectorDelay.svg
│  │        │  │  │  ├─ 📄VfController.svg
│  │        │  │  │  ├─ 📄Voltage2AngleType.svg
│  │        │  │  │  ├─ 📄Voltage2DutyCycle.svg
│  │        │  │  │  ├─ 📄VoltageBridge2mPulse.svg
│  │        │  │  │  ├─ 📄VoltageBridge2Pulse.svg
│  │        │  │  │  ├─ 📄VoltageCenterTap2mPulse.svg
│  │        │  │  │  ├─ 📄VoltageFollower.svg
│  │        │  │  │  ├─ 📄VoltageQuasiRMSSensor.svg
│  │        │  │  │  ├─ 📄VoltageSensor.svg
│  │        │  │  │  ├─ 📄VoltageSource.svg
│  │        │  │  │  ├─ 📄VoltageSquare.svg
│  │        │  │  │  ├─ 📄VoltageToAngle.svg
│  │        │  │  │  ├─ 📄V_constant.svg
│  │        │  │  │  ├─ 📄V_exp.svg
│  │        │  │  │  ├─ 📄V_pulse.svg
│  │        │  │  │  ├─ 📄V_pwl.svg
│  │        │  │  │  ├─ 📄V_sffm.svg
│  │        │  │  │  ├─ 📄V_sin.svg
│  │        │  │  │  ├─ 📄WiredX.svg
│  │        │  │  │  ├─ 📄Xnor.svg
│  │        │  │  │  ├─ 📄XnorGate.svg
│  │        │  │  │  ├─ 📄Xor.svg
│  │        │  │  │  ├─ 📄XorGate.svg
│  │        │  │  │  ├─ 📄Yd.svg
│  │        │  │  │  ├─ 📄Yd01.svg
│  │        │  │  │  ├─ 📄Yd03.svg
│  │        │  │  │  ├─ 📄Yd05.svg
│  │        │  │  │  ├─ 📄Yd07.svg
│  │        │  │  │  ├─ 📄Yd09.svg
│  │        │  │  │  ├─ 📄Yd11.svg
│  │        │  │  │  ├─ 📄Yy.svg
│  │        │  │  │  ├─ 📄Yy00.svg
│  │        │  │  │  ├─ 📄Yy02.svg
│  │        │  │  │  ├─ 📄Yy04.svg
│  │        │  │  │  ├─ 📄Yy06.svg
│  │        │  │  │  ├─ 📄Yy08.svg
│  │        │  │  │  ├─ 📄Yy10.svg
│  │        │  │  │  ├─ 📄Yz.svg
│  │        │  │  │  ├─ 📄Yz01.svg
│  │        │  │  │  ├─ 📄Yz03.svg
│  │        │  │  │  ├─ 📄Yz05.svg
│  │        │  │  │  ├─ 📄Yz07.svg
│  │        │  │  │  ├─ 📄Yz09.svg
│  │        │  │  │  ├─ 📄Yz11.svg
│  │        │  │  │  ├─ 📄ZDiode.svg
│  │        │  │  │  └─ 📄ZeroInductor.svg
│  │        │  │  └─ 📄.gitkeep
│  │        │  └─ 📁component_source
│  │        │     ├─ 📁Blocks
│  │        │     │  ├─ 📄Continuous.mo
│  │        │     │  ├─ 📄Discrete.mo
│  │        │     │  ├─ 📄Icons.mo
│  │        │     │  ├─ 📄Interaction.mo
│  │        │     │  ├─ 📄Interfaces.mo
│  │        │     │  ├─ 📄Logical.mo
│  │        │     │  ├─ 📄Math.mo
│  │        │     │  ├─ 📄MathBoolean.mo
│  │        │     │  ├─ 📄MathInteger.mo
│  │        │     │  ├─ 📄Noise.mo
│  │        │     │  ├─ 📄Nonlinear.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  ├─ 📄Routing.mo
│  │        │     │  ├─ 📄Sources.mo
│  │        │     │  ├─ 📄Tables.mo
│  │        │     │  └─ 📄Types.mo
│  │        │     ├─ 📁Electrical
│  │        │     │  ├─ 📁Analog
│  │        │     │  │  ├─ 📁Basic
│  │        │     │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  ├─ 📄CCC.mo
│  │        │     │  │  │  ├─ 📄CCV.mo
│  │        │     │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.mo
│  │        │     │  │  │  ├─ 📄Ground.mo
│  │        │     │  │  │  ├─ 📄Gyrator.mo
│  │        │     │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  ├─ 📄M_Transformer.mo
│  │        │     │  │  │  ├─ 📄OpAmp.mo
│  │        │     │  │  │  ├─ 📄OpAmpDetailed.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Potentiometer.mo
│  │        │     │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  ├─ 📄RotationalEMF.mo
│  │        │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │        │     │  │  │  ├─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📄TranslationalEMF.mo
│  │        │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  ├─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📄VCC.mo
│  │        │     │  │  │  └─ 📄VCV.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  ├─ 📁Ideal
│  │        │     │  │  │  ├─ 📄AD_Converter.mo
│  │        │     │  │  │  ├─ 📄CloserWithArc.mo
│  │        │     │  │  │  ├─ 📄ControlledCloserWithArc.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.mo
│  │        │     │  │  │  ├─ 📄ControlledOpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄DA_Converter.mo
│  │        │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealDiode.mo
│  │        │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealizedOpAmpLimited.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmp.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmp3Pin.mo
│  │        │     │  │  │  ├─ 📄IdealOpAmpLimited.mo
│  │        │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  ├─ 📄IdealTriac.mo
│  │        │     │  │  │  ├─ 📄IdealTwoWaySwitch.mo
│  │        │     │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Short.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  ├─ 📄FourPin.mo
│  │        │     │  │  │  ├─ 📄IdealSemiconductor.mo
│  │        │     │  │  │  ├─ 📄IdealSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealSwitchWithArc.mo
│  │        │     │  │  │  ├─ 📄NegativePin.mo
│  │        │     │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄Pin.mo
│  │        │     │  │  │  ├─ 📄PositivePin.mo
│  │        │     │  │  │  ├─ 📄RelativeSensor.mo
│  │        │     │  │  │  ├─ 📄TwoPin.mo
│  │        │     │  │  │  ├─ 📄TwoPort.mo
│  │        │     │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  ├─ 📁Lines
│  │        │     │  │  │  ├─ 📄M_OLine.mo
│  │        │     │  │  │  ├─ 📄OLine.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄TLine1.mo
│  │        │     │  │  │  ├─ 📄TLine2.mo
│  │        │     │  │  │  ├─ 📄TLine3.mo
│  │        │     │  │  │  └─ 📄ULine.mo
│  │        │     │  │  ├─ 📁Semiconductors
│  │        │     │  │  │  ├─ 📄Diode.mo
│  │        │     │  │  │  ├─ 📄Diode2.mo
│  │        │     │  │  │  ├─ 📄NMOS.mo
│  │        │     │  │  │  ├─ 📄NPN.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PMOS.mo
│  │        │     │  │  │  ├─ 📄PNP.mo
│  │        │     │  │  │  ├─ 📄SimpleTriac.mo
│  │        │     │  │  │  ├─ 📄Thyristor.mo
│  │        │     │  │  │  └─ 📄ZDiode.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │        │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineCurrent.mo
│  │        │     │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄CosineVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄ExponentialsCurrent.mo
│  │        │     │  │  │  ├─ 📄ExponentialsVoltage.mo
│  │        │     │  │  │  ├─ 📄ExpSineCurrent.mo
│  │        │     │  │  │  ├─ 📄ExpSineVoltage.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PulseCurrent.mo
│  │        │     │  │  │  ├─ 📄PulseVoltage.mo
│  │        │     │  │  │  ├─ 📄RampCurrent.mo
│  │        │     │  │  │  ├─ 📄RampVoltage.mo
│  │        │     │  │  │  ├─ 📄SawToothCurrent.mo
│  │        │     │  │  │  ├─ 📄SawToothVoltage.mo
│  │        │     │  │  │  ├─ 📄SignalCurrent.mo
│  │        │     │  │  │  ├─ 📄SignalVoltage.mo
│  │        │     │  │  │  ├─ 📄SineCurrent.mo
│  │        │     │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄SineVoltage.mo
│  │        │     │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.mo
│  │        │     │  │  │  ├─ 📄StepCurrent.mo
│  │        │     │  │  │  ├─ 📄StepVoltage.mo
│  │        │     │  │  │  ├─ 📄SupplyVoltage.mo
│  │        │     │  │  │  ├─ 📄TableCurrent.mo
│  │        │     │  │  │  ├─ 📄TableVoltage.mo
│  │        │     │  │  │  ├─ 📄TrapezoidCurrent.mo
│  │        │     │  │  │  └─ 📄TrapezoidVoltage.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Batteries
│  │        │     │  │  ├─ 📁BaseClasses
│  │        │     │  │  │  ├─ 📄BaseCellStack.mo
│  │        │     │  │  │  ├─ 📄BaseCellWithSensors.mo
│  │        │     │  │  │  ├─ 📄BaseStackData.mo
│  │        │     │  │  │  ├─ 📄BaseStackWithSensors.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁BatteryStacks
│  │        │     │  │  │  ├─ 📄CellRCStack.mo
│  │        │     │  │  │  ├─ 📄CellStack.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄SuperCap.mo
│  │        │     │  │  ├─ 📁BatteryStacksWithSensors
│  │        │     │  │  │  ├─ 📄Cell.mo
│  │        │     │  │  │  ├─ 📄CellRC.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Stack.mo
│  │        │     │  │  │  └─ 📄StackRC.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄BaseCellRecord.mo
│  │        │     │  │  │  ├─ 📄BaseStackRecord.mo
│  │        │     │  │  │  ├─ 📄BatteryIcon.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄TransientCellRecord.mo
│  │        │     │  │  │  ├─ 📄TransientModel.mo
│  │        │     │  │  │  ├─ 📄TransientRecordsPackage.mo
│  │        │     │  │  │  └─ 📄TransientStackRecord.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄CellBus.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄StackBus.mo
│  │        │     │  │  │  └─ 📄StackBusArrays.mo
│  │        │     │  │  ├─ 📁ParameterRecords
│  │        │     │  │  │  ├─ 📁TransientData
│  │        │     │  │  │  │  ├─ 📄CellData.mo
│  │        │     │  │  │  │  ├─ 📄ExampleData.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄RCData.mo
│  │        │     │  │  │  │  └─ 📄StackData.mo
│  │        │     │  │  │  ├─ 📄CellData.mo
│  │        │     │  │  │  ├─ 📄ExampleData.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄StackData.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Concept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Parameterization.mo
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📁Utilities
│  │        │     │  │  │  ├─ 📄BusTranscription.mo
│  │        │     │  │  │  ├─ 📄CCCVcharger.mo
│  │        │     │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄PulseSeries.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Machines
│  │        │     │  │  ├─ 📁BasicMachines
│  │        │     │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  ├─ 📄AirGapDC.mo
│  │        │     │  │  │  │  ├─ 📄AirGapR.mo
│  │        │     │  │  │  │  ├─ 📄AirGapS.mo
│  │        │     │  │  │  │  ├─ 📄CompoundDCExcitation.mo
│  │        │     │  │  │  │  ├─ 📄DamperCage.mo
│  │        │     │  │  │  │  ├─ 📄ElectricalExcitation.mo
│  │        │     │  │  │  │  ├─ 📄IdealCore.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄InductorDC.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialAirGap.mo
│  │        │     │  │  │  │  ├─ 📄PartialAirGapDC.mo
│  │        │     │  │  │  │  ├─ 📄PartialCore.mo
│  │        │     │  │  │  │  ├─ 📄PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄PermanentMagnetWithLosses.mo
│  │        │     │  │  │  │  └─ 📄SquirrelCage.mo
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄IM_SlipRing.mo
│  │        │     │  │  │  │  ├─ 📄IM_SquirrelCage.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁QuasiStaticDCMachines
│  │        │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │        │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SM_ElectricalExcited.mo
│  │        │     │  │  │  │  ├─ 📄SM_PermanentMagnet.mo
│  │        │     │  │  │  │  └─ 📄SM_ReluctanceRotor.mo
│  │        │     │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  ├─ 📁Dd
│  │        │     │  │  │  │  │  ├─ 📄Dd00.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd02.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd04.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd06.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd08.mo
│  │        │     │  │  │  │  │  ├─ 📄Dd10.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Dy
│  │        │     │  │  │  │  │  ├─ 📄Dy01.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy03.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy05.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy07.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy09.mo
│  │        │     │  │  │  │  │  ├─ 📄Dy11.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Dz
│  │        │     │  │  │  │  │  ├─ 📄Dz00.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz02.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz04.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz06.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz08.mo
│  │        │     │  │  │  │  │  ├─ 📄Dz10.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁Yd
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yd01.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd03.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd05.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd07.mo
│  │        │     │  │  │  │  │  ├─ 📄Yd09.mo
│  │        │     │  │  │  │  │  └─ 📄Yd11.mo
│  │        │     │  │  │  │  ├─ 📁Yy
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yy00.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy02.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy04.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy06.mo
│  │        │     │  │  │  │  │  ├─ 📄Yy08.mo
│  │        │     │  │  │  │  │  └─ 📄Yy10.mo
│  │        │     │  │  │  │  ├─ 📁Yz
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Yz01.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz03.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz05.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz07.mo
│  │        │     │  │  │  │  │  ├─ 📄Yz09.mo
│  │        │     │  │  │  │  │  └─ 📄Yz11.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁ControlledDCDrives
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄Battery.mo
│  │        │     │  │  │  │  │  ├─ 📄DcdcInverter.mo
│  │        │     │  │  │  │  │  ├─ 📄DriveDataDCPM.mo
│  │        │     │  │  │  │  │  ├─ 📄IdealDcDc.mo
│  │        │     │  │  │  │  │  ├─ 📄LimitedPI.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄PartialControlledDCPM.mo
│  │        │     │  │  │  │  │  └─ 📄SwitchingDcDc.mo
│  │        │     │  │  │  │  ├─ 📄CurrentControlledDCPM.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PositionControlledDCPM.mo
│  │        │     │  │  │  │  └─ 📄SpeedControlledDCPM.mo
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄DCEE_Start.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Cooling.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_CurrentControlled.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_QuasiStatic.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Start.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_Temperature.mo
│  │        │     │  │  │  │  ├─ 📄DCPM_withLosses.mo
│  │        │     │  │  │  │  ├─ 📄DCSE_SinglePhase.mo
│  │        │     │  │  │  │  ├─ 📄DCSE_Start.mo
│  │        │     │  │  │  │  ├─ 📄DC_CompareCharacteristics.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄IMC_Conveyor.mo
│  │        │     │  │  │  │  ├─ 📄IMC_DCBraking.mo
│  │        │     │  │  │  │  ├─ 📄IMC_DOL.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Initialize.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Inverter.mo
│  │        │     │  │  │  │  ├─ 📄IMC_InverterDrive.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Steinmetz.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │        │     │  │  │  │  ├─ 📄IMC_withLosses.mo
│  │        │     │  │  │  │  ├─ 📄IMC_YD.mo
│  │        │     │  │  │  │  ├─ 📄IMC_YDarc.mo
│  │        │     │  │  │  │  ├─ 📄IMS_Start.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SMEE_DOL.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_Generator.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_LoadDump.mo
│  │        │     │  │  │  │  ├─ 📄SMEE_Rectifier.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_Braking.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_Inverter.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_NoLoad.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_ResistiveBraking.mo
│  │        │     │  │  │  │  ├─ 📄SMPM_VoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄SMR_DOL.mo
│  │        │     │  │  │  │  └─ 📄SMR_Inverter.mo
│  │        │     │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  ├─ 📄AsymmetricalLoad.mo
│  │        │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Rectifier12pulse.mo
│  │        │     │  │  │  │  ├─ 📄Rectifier6pulse.mo
│  │        │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Drive.mo
│  │        │     │  │  │  ├─ 📄FundamentalWaveMachine.mo
│  │        │     │  │  │  ├─ 📄Machine.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.mo
│  │        │     │  │  │  ├─ 📄QuasiStaticMachine.mo
│  │        │     │  │  │  ├─ 📄QuasiStaticTransformer.mo
│  │        │     │  │  │  ├─ 📄TransientMachine.mo
│  │        │     │  │  │  └─ 📄TransientTransformer.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalPortDCMachines.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCCE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCEE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCPM.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceDCSE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCCE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortDCPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalPortDCSE.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceIMC.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceIMS.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMEE.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMPM.mo
│  │        │     │  │  │  │  ├─ 📄PowerBalanceSMR.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortIMC.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortIMS.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortSMEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalPortSMPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalPortSMR.mo
│  │        │     │  │  │  ├─ 📄FlangeSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialBasicDCMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicInductionMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicMachine.mo
│  │        │     │  │  │  ├─ 📄PartialBasicTransformer.mo
│  │        │     │  │  │  ├─ 📄PowerBalanceTransformer.mo
│  │        │     │  │  │  ├─ 📄SpacePhasor.mo
│  │        │     │  │  │  └─ 📄ThermalPortTransformer.mo
│  │        │     │  │  ├─ 📁Losses
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄Brush.mo
│  │        │     │  │  │  │  ├─ 📄brushVoltageDrop.mo
│  │        │     │  │  │  │  ├─ 📄Core.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄StrayLoad.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄Brush.mo
│  │        │     │  │  │  │  ├─ 📄Core.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PermanentMagnetLosses.mo
│  │        │     │  │  │  │  └─ 📄StrayLoad.mo
│  │        │     │  │  │  ├─ 📄BrushParameters.mo
│  │        │     │  │  │  ├─ 📄CoreParameters.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄FrictionParameters.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PermanentMagnetLossParameters.mo
│  │        │     │  │  │  └─ 📄StrayLoadParameters.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  ├─ 📄ElectricalPowerSensor.mo
│  │        │     │  │  │  ├─ 📄HallSensor.mo
│  │        │     │  │  │  ├─ 📄MechanicalPowerSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RotorDisplacementAngle.mo
│  │        │     │  │  │  ├─ 📄SinCosResolver.mo
│  │        │     │  │  │  └─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  ├─ 📁SpacePhasors
│  │        │     │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  ├─ 📄FromPolar.mo
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄LessThreshold.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  ├─ 📄ToPolar.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  └─ 📄SpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Functions
│  │        │     │  │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  │  ├─ 📄FromPolar.mo
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄quasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄Rotator.mo
│  │        │     │  │  │  │  ├─ 📄ToPolar.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Thermal
│  │        │     │  │  │  ├─ 📁Constants
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCCE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientDCPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientDCSE.mo
│  │        │     │  │  │  ├─ 📁InductionMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientIMC.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientIMS.mo
│  │        │     │  │  │  ├─ 📁SynchronousMachines
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientSMEE.mo
│  │        │     │  │  │  │  ├─ 📄ThermalAmbientSMPM.mo
│  │        │     │  │  │  │  └─ 📄ThermalAmbientSMR.mo
│  │        │     │  │  │  ├─ 📄convertAlpha.mo
│  │        │     │  │  │  ├─ 📄convertResistance.mo
│  │        │     │  │  │  ├─ 📄LinearTemperatureCoefficient20.mo
│  │        │     │  │  │  ├─ 📄linearTemperatureDependency.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄ThermalAmbientTransformer.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Concept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Discrimination.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📁Utilities
│  │        │     │  │  │  ├─ 📁ParameterRecords
│  │        │     │  │  │  │  ├─ 📄DcElectricalExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄DcPermanentMagnetData.mo
│  │        │     │  │  │  │  ├─ 📄DcSeriesExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄IM_SlipRingData.mo
│  │        │     │  │  │  │  ├─ 📄IM_SquirrelCageData.mo
│  │        │     │  │  │  │  ├─ 📄InductionMachineData.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SM_ElectricalExcitedData.mo
│  │        │     │  │  │  │  ├─ 📄SM_PermanentMagnetData.mo
│  │        │     │  │  │  │  ├─ 📄SM_ReluctanceRotorData.mo
│  │        │     │  │  │  │  └─ 📄TransformerData.mo
│  │        │     │  │  │  ├─ 📄DcBrakeSettings.mo
│  │        │     │  │  │  ├─ 📄DQCurrentController.mo
│  │        │     │  │  │  ├─ 📄DQToThreePhase.mo
│  │        │     │  │  │  ├─ 📄FromDQ.mo
│  │        │     │  │  │  ├─ 📄MultiTerminalBox.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RampedRheostat.mo
│  │        │     │  │  │  ├─ 📄SinCosEvaluation.mo
│  │        │     │  │  │  ├─ 📄SwitchedRheostat.mo
│  │        │     │  │  │  ├─ 📄SwitchYD.mo
│  │        │     │  │  │  ├─ 📄SwitchYDwithArc.mo
│  │        │     │  │  │  ├─ 📄SynchronousMachineData.mo
│  │        │     │  │  │  ├─ 📄TerminalBox.mo
│  │        │     │  │  │  ├─ 📄ToDQ.mo
│  │        │     │  │  │  ├─ 📄TransformerData.mo
│  │        │     │  │  │  └─ 📄VfController.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Polyphase
│  │        │     │  │  ├─ 📁Basic
│  │        │     │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  ├─ 📄Delta.mo
│  │        │     │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  ├─ 📄MultiDelta.mo
│  │        │     │  │  │  ├─ 📄MultiStar.mo
│  │        │     │  │  │  ├─ 📄MultiStarResistance.mo
│  │        │     │  │  │  ├─ 📄MutualInductor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PlugToPins_n.mo
│  │        │     │  │  │  ├─ 📄PlugToPins_p.mo
│  │        │     │  │  │  ├─ 📄PlugToPin_n.mo
│  │        │     │  │  │  ├─ 📄PlugToPin_p.mo
│  │        │     │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │        │     │  │  │  ├─ 📄SplitToSubsystems.mo
│  │        │     │  │  │  ├─ 📄Star.mo
│  │        │     │  │  │  ├─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  ├─ 📄VariableResistor.mo
│  │        │     │  │  │  └─ 📄ZeroInductor.mo
│  │        │     │  │  ├─ 📁Blocks
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄QuasiRMS.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄AnalysatorAC.mo
│  │        │     │  │  │  │  ├─ 📄AnalysatorDC.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄PolyphaseRectifierData.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PolyphaseRectifier.mo
│  │        │     │  │  │  ├─ 📄Rectifier.mo
│  │        │     │  │  │  ├─ 📄TestSensors.mo
│  │        │     │  │  │  ├─ 📄TransformerYD.mo
│  │        │     │  │  │  └─ 📄TransformerYY.mo
│  │        │     │  │  ├─ 📁Functions
│  │        │     │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  ├─ 📄factorY2D.mo
│  │        │     │  │  │  ├─ 📄factorY2DC.mo
│  │        │     │  │  │  ├─ 📄indexNonPositiveSequence.mo
│  │        │     │  │  │  ├─ 📄indexPositiveSequence.mo
│  │        │     │  │  │  ├─ 📄numberOfSymmetricBaseSystems.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄quasiRMS.mo
│  │        │     │  │  │  ├─ 📄symmetricBackTransformationMatrix.mo
│  │        │     │  │  │  ├─ 📄symmetricOrientation.mo
│  │        │     │  │  │  ├─ 📄symmetricOrientationMatrix.mo
│  │        │     │  │  │  └─ 📄symmetricTransformationMatrix.mo
│  │        │     │  │  ├─ 📁Ideal
│  │        │     │  │  │  ├─ 📄CloserWithArc.mo
│  │        │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealDiode.mo
│  │        │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  ├─ 📄IdealThyristor.mo
│  │        │     │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Short.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │        │     │  │  │  ├─ 📄FourPlug.mo
│  │        │     │  │  │  ├─ 📄NegativePlug.mo
│  │        │     │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Plug.mo
│  │        │     │  │  │  ├─ 📄PositivePlug.mo
│  │        │     │  │  │  ├─ 📄TwoPlug.mo
│  │        │     │  │  │  └─ 📄TwoPort.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AronSensor.mo
│  │        │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │        │     │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │        │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │        │     │  │  │  ├─ 📄CosineCurrent.mo
│  │        │     │  │  │  ├─ 📄CosineVoltage.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄SignalCurrent.mo
│  │        │     │  │  │  ├─ 📄SignalVoltage.mo
│  │        │     │  │  │  ├─ 📄SineCurrent.mo
│  │        │     │  │  │  └─ 📄SineVoltage.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PhaseOrientation.mo
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁PowerConverters
│  │        │     │  │  ├─ 📁ACAC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SoftStartControl.mo
│  │        │     │  │  │  │  └─ 📄VoltageToAngle.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PolyphaseTriac.mo
│  │        │     │  │  │  └─ 📄SinglePhaseTriac.mo
│  │        │     │  │  ├─ 📁ACDC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄Filter.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Signal2mPulse.mo
│  │        │     │  │  │  │  ├─ 📄VoltageBridge2mPulse.mo
│  │        │     │  │  │  │  ├─ 📄VoltageBridge2Pulse.mo
│  │        │     │  │  │  │  └─ 📄VoltageCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │        │     │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │        │     │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │        │     │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │        │     │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │        │     │  │  ├─ 📁DCAC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄IntersectivePWM.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PWM.mo
│  │        │     │  │  │  │  └─ 📄SVPWM.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Polyphase2Level.mo
│  │        │     │  │  │  └─ 📄SinglePhase2Level.mo
│  │        │     │  │  ├─ 📁DCDC
│  │        │     │  │  │  ├─ 📁Control
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄SignalPWM.mo
│  │        │     │  │  │  │  └─ 📄Voltage2DutyCycle.mo
│  │        │     │  │  │  ├─ 📄ChopperStepDown.mo
│  │        │     │  │  │  ├─ 📄ChopperStepUp.mo
│  │        │     │  │  │  ├─ 📄HBridge.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Enable
│  │        │     │  │  │  ├─ 📄EnableLogic.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁ACAC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄Dimmer.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Dimmer_R.mo
│  │        │     │  │  │  │  ├─ 📄Dimmer_RL.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄SoftStarter.mo
│  │        │     │  │  │  ├─ 📁ACDC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Thyristor1Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │        │     │  │  │  │  ├─ 📁Rectifier1Pulse
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.mo
│  │        │     │  │  │  │  │  └─ 📄Thyristor1Pulse_R_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierBridge2mPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorBridge2mPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierBridge2Pulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorBridge2Pulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTap2mPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTap2Pulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📁RectifierCenterTapmPulse
│  │        │     │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.mo
│  │        │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCAC
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel.mo
│  │        │     │  │  │  │  ├─ 📁PolyphaseTwoLevel
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.mo
│  │        │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.mo
│  │        │     │  │  │  │  │  └─ 📄ThreePhaseTwoLevel_PWM.mo
│  │        │     │  │  │  │  ├─ 📁SinglePhaseTwoLevel
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.mo
│  │        │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel_RL.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCDC
│  │        │     │  │  │  │  ├─ 📁ChopperStepDown
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown_R.mo
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁ChopperStepUp
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepUp_R.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁ExampleTemplates
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepDown.mo
│  │        │     │  │  │  │  │  ├─ 📄ChopperStepUp.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📁HBridge
│  │        │     │  │  │  │  │  ├─ 📄HBridge_DC_Drive.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge_R.mo
│  │        │     │  │  │  │  │  ├─ 📄HBridge_RL.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Control.mo
│  │        │     │  │  │  ├─ 📄Converter.mo
│  │        │     │  │  │  ├─ 📄ExampleTemplate.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📁ACDC
│  │        │     │  │  │  │  ├─ 📄ACplug.mo
│  │        │     │  │  │  │  ├─ 📄ACtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄ACtwoPlug.mo
│  │        │     │  │  │  │  ├─ 📄DCpin.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCAC
│  │        │     │  │  │  │  ├─ 📄ACpin.mo
│  │        │     │  │  │  │  ├─ 📄ACplug.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁DCDC
│  │        │     │  │  │  │  ├─ 📄DCtwoPin1.mo
│  │        │     │  │  │  │  ├─ 📄DCtwoPin2.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Enable
│  │        │     │  │  │  │  ├─ 📄Enable.mo
│  │        │     │  │  │  │  ├─ 📄Enable1.mo
│  │        │     │  │  │  │  ├─ 📄Enable1m.mo
│  │        │     │  │  │  │  ├─ 📄Enable2.mo
│  │        │     │  │  │  │  ├─ 📄Enable2m.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PWMType.mo
│  │        │     │  │  │  ├─ 📄ReferenceType.mo
│  │        │     │  │  │  ├─ 📄SoftStarterModeOfOperation.mo
│  │        │     │  │  │  └─ 📄Voltage2AngleType.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄ACACConcept.mo
│  │        │     │  │  │  ├─ 📄ACDCConcept.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄DCACConcept.mo
│  │        │     │  │  │  ├─ 📄DCDCConcept.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁QuasiStatic
│  │        │     │  │  ├─ 📁Machines
│  │        │     │  │  │  ├─ 📁BasicMachines
│  │        │     │  │  │  │  ├─ 📁Components
│  │        │     │  │  │  │  │  ├─ 📄IdealCore.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄PartialCore.mo
│  │        │     │  │  │  │  ├─ 📁Transformers
│  │        │     │  │  │  │  │  ├─ 📁Dd
│  │        │     │  │  │  │  │  │  ├─ 📄Dd00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd08.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dd10.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Dy
│  │        │     │  │  │  │  │  │  ├─ 📄Dy01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy09.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dy11.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Dz
│  │        │     │  │  │  │  │  │  ├─ 📄Dz00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz08.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Dz10.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📁Yd
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yd01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yd09.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yd11.mo
│  │        │     │  │  │  │  │  ├─ 📁Yy
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yy00.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy02.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy04.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy06.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yy08.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yy10.mo
│  │        │     │  │  │  │  │  ├─ 📁Yz
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄Yz01.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz03.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz05.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz07.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Yz09.mo
│  │        │     │  │  │  │  │  │  └─ 📄Yz11.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄PartialBasicTransformer.mo
│  │        │     │  │  │  ├─ 📁SpacePhasors
│  │        │     │  │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Polyphase
│  │        │     │  │  │  ├─ 📁Basic
│  │        │     │  │  │  │  ├─ 📄Admittance.mo
│  │        │     │  │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  │  ├─ 📄Delta.mo
│  │        │     │  │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄MultiDelta.mo
│  │        │     │  │  │  │  ├─ 📄MultiStar.mo
│  │        │     │  │  │  │  ├─ 📄MultiStarResistance.mo
│  │        │     │  │  │  │  ├─ 📄MutualInductor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PlugToPins_n.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPins_p.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPin_n.mo
│  │        │     │  │  │  │  ├─ 📄PlugToPin_p.mo
│  │        │     │  │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  │  ├─ 📄Star.mo
│  │        │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │        │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │        │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  │  └─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📁Blocks
│  │        │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │        │     │  │  │  │  ├─ 📄FromSymmetricalComponents.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │        │     │  │  │  │  ├─ 📄SingleToPolyphase.mo
│  │        │     │  │  │  │  ├─ 📄SymmetricalComponents.mo
│  │        │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄BalancingDelta.mo
│  │        │     │  │  │  │  ├─ 📄BalancingStar.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄TestSensors.mo
│  │        │     │  │  │  │  └─ 📄UnsymmetricalLoad.mo
│  │        │     │  │  │  ├─ 📁Functions
│  │        │     │  │  │  │  ├─ 📄activePower.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄quasiRMS.mo
│  │        │     │  │  │  ├─ 📁Ideal
│  │        │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄Short.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄NegativePlug.mo
│  │        │     │  │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Plug.mo
│  │        │     │  │  │  │  ├─ 📄PositivePlug.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSource.mo
│  │        │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │        │     │  │  │  │  ├─ 📄Source.mo
│  │        │     │  │  │  │  ├─ 📄TwoPlug.mo
│  │        │     │  │  │  │  └─ 📄TwoPlugElementary.mo
│  │        │     │  │  │  ├─ 📁Sensors
│  │        │     │  │  │  │  ├─ 📄AronSensor.mo
│  │        │     │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │        │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │        │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │        │     │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │        │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  │  ├─ 📁Sources
│  │        │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ReferenceCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │        │     │  │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁SinglePhase
│  │        │     │  │  │  ├─ 📁Basic
│  │        │     │  │  │  │  ├─ 📄Admittance.mo
│  │        │     │  │  │  │  ├─ 📄Capacitor.mo
│  │        │     │  │  │  │  ├─ 📄Conductor.mo
│  │        │     │  │  │  │  ├─ 📄Ground.mo
│  │        │     │  │  │  │  ├─ 📄Impedance.mo
│  │        │     │  │  │  │  ├─ 📄Inductor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Resistor.mo
│  │        │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │        │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │        │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │        │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │        │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │        │     │  │  │  │  └─ 📄VariableResistor.mo
│  │        │     │  │  │  ├─ 📁Examples
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄ParallelResonance.mo
│  │        │     │  │  │  │  ├─ 📄Rectifier.mo
│  │        │     │  │  │  │  ├─ 📄SeriesBode.mo
│  │        │     │  │  │  │  ├─ 📄SeriesResonance.mo
│  │        │     │  │  │  │  └─ 📄Transformer.mo
│  │        │     │  │  │  ├─ 📁Ideal
│  │        │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │        │     │  │  │  │  ├─ 📄IdealTransformer.mo
│  │        │     │  │  │  │  ├─ 📄Idle.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄Short.mo
│  │        │     │  │  │  ├─ 📁Interfaces
│  │        │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄NegativePin.mo
│  │        │     │  │  │  │  ├─ 📄OnePort.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Pin.mo
│  │        │     │  │  │  │  ├─ 📄PositivePin.mo
│  │        │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │        │     │  │  │  │  ├─ 📄Source.mo
│  │        │     │  │  │  │  ├─ 📄TwoPin.mo
│  │        │     │  │  │  │  └─ 📄TwoPinElementary.mo
│  │        │     │  │  │  ├─ 📁Sensors
│  │        │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │        │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │        │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │        │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │        │     │  │  │  ├─ 📁Sources
│  │        │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │        │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │        │     │  │  │  │  └─ 📄VoltageSource.mo
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄GraetzRectifier.mo
│  │        │     │  │  │  │  ├─ 📄IdealACDCConverter.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Reference.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📁Overview
│  │        │     │  │  │  │  ├─ 📄ACCircuit.mo
│  │        │     │  │  │  │  ├─ 📄Introduction.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Power.mo
│  │        │     │  │  │  │  └─ 📄ReferenceSystem.mo
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Glossar.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  └─ 📄ReleaseNotes.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📄Digital.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  └─ 📄Spice3.mo
│  │        │     ├─ 📁Math
│  │        │     │  ├─ 📄BooleanVectors.mo
│  │        │     │  ├─ 📄Distributions.mo
│  │        │     │  ├─ 📄FastFourierTransform.mo
│  │        │     │  ├─ 📄isPowerOf2.mo
│  │        │     │  ├─ 📄Nonlinear.mo
│  │        │     │  ├─ 📄package.mo
│  │        │     │  ├─ 📄package.order
│  │        │     │  ├─ 📄Polynomials.mo
│  │        │     │  ├─ 📄Random.mo
│  │        │     │  ├─ 📄Special.mo
│  │        │     │  └─ 📄wrapAngle.mo
│  │        │     ├─ 📁Mechanics
│  │        │     │  ├─ 📁MultiBody
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Constraints
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PrismaticConstraint.mo
│  │        │     │  │  │  │  ├─ 📄RevoluteConstraint.mo
│  │        │     │  │  │  │  ├─ 📄SphericalConstraint.mo
│  │        │     │  │  │  │  └─ 📄UniversalConstraint.mo
│  │        │     │  │  │  ├─ 📁Elementary
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄sineSurface.mo
│  │        │     │  │  │  │  │  └─ 📄theoreticalNormalGravityWGS84.mo
│  │        │     │  │  │  │  ├─ 📄DoublePendulum.mo
│  │        │     │  │  │  │  ├─ 📄DoublePendulumInitTip.mo
│  │        │     │  │  │  │  ├─ 📄ForceAndTorque.mo
│  │        │     │  │  │  │  ├─ 📄FreeBody.mo
│  │        │     │  │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  │  ├─ 📄InitSpringConstant.mo
│  │        │     │  │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Pendulum.mo
│  │        │     │  │  │  │  ├─ 📄PendulumWithSpringDamper.mo
│  │        │     │  │  │  │  ├─ 📄PointGravity.mo
│  │        │     │  │  │  │  ├─ 📄PointGravityWithPointMasses.mo
│  │        │     │  │  │  │  ├─ 📄PointGravityWithPointMasses2.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheelSetDriving.mo
│  │        │     │  │  │  │  ├─ 📄RollingWheelSetPulling.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamperSystem.mo
│  │        │     │  │  │  │  ├─ 📄SpringMassSystem.mo
│  │        │     │  │  │  │  ├─ 📄SpringWithMass.mo
│  │        │     │  │  │  │  ├─ 📄Surfaces.mo
│  │        │     │  │  │  │  ├─ 📄ThreeSprings.mo
│  │        │     │  │  │  │  └─ 📄UserDefinedGravityField.mo
│  │        │     │  │  │  ├─ 📁Loops
│  │        │     │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  ├─ 📄Cylinder.mo
│  │        │     │  │  │  │  │  ├─ 📄CylinderBase.mo
│  │        │     │  │  │  │  │  ├─ 📄Cylinder_analytic_CAD.mo
│  │        │     │  │  │  │  │  ├─ 📄Engine1Base.mo
│  │        │     │  │  │  │  │  ├─ 📄Engine1bBase.mo
│  │        │     │  │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │        │     │  │  │  │  │  ├─ 📄GasForce2.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Engine1a.mo
│  │        │     │  │  │  │  ├─ 📄Engine1b.mo
│  │        │     │  │  │  │  ├─ 📄Engine1b_analytic.mo
│  │        │     │  │  │  │  ├─ 📄EngineV6.mo
│  │        │     │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar1.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar2.mo
│  │        │     │  │  │  │  ├─ 📄Fourbar_analytic.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PlanarFourbar.mo
│  │        │     │  │  │  │  └─ 📄PlanarLoops_analytic.mo
│  │        │     │  │  │  ├─ 📁Rotational3DEffects
│  │        │     │  │  │  │  ├─ 📄ActuatedDrive.mo
│  │        │     │  │  │  │  ├─ 📄BevelGear1D.mo
│  │        │     │  │  │  │  ├─ 📄GearConstraint.mo
│  │        │     │  │  │  │  ├─ 📄GyroscopicEffects.mo
│  │        │     │  │  │  │  ├─ 📄MovingActuatedDrive.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Systems
│  │        │     │  │  │  │  ├─ 📁RobotR3
│  │        │     │  │  │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  │  │  ├─ 📄AxisControlBus.mo
│  │        │     │  │  │  │  │  │  ├─ 📄AxisType1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄AxisType2.mo
│  │        │     │  │  │  │  │  │  ├─ 📄ControlBus.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Controller.mo
│  │        │     │  │  │  │  │  │  ├─ 📄GearType1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄GearType2.mo
│  │        │     │  │  │  │  │  │  ├─ 📄MechanicalStructure.mo
│  │        │     │  │  │  │  │  │  ├─ 📄Motor.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  │  ├─ 📄PathPlanning1.mo
│  │        │     │  │  │  │  │  │  ├─ 📄PathPlanning6.mo
│  │        │     │  │  │  │  │  │  └─ 📄PathToAxisControlBus.mo
│  │        │     │  │  │  │  │  ├─ 📄FullRobot.mo
│  │        │     │  │  │  │  │  ├─ 📄OneAxis.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Forces
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄BasicForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicTorque.mo
│  │        │     │  │  │  │  ├─ 📄BasicWorldForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicWorldTorque.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄standardGravityAcceleration.mo
│  │        │     │  │  │  │  └─ 📄ZeroForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄Force.mo
│  │        │     │  │  │  ├─ 📄ForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄LineForceWithMass.mo
│  │        │     │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamperParallel.mo
│  │        │     │  │  │  ├─ 📄SpringDamperSeries.mo
│  │        │     │  │  │  ├─ 📄Torque.mo
│  │        │     │  │  │  ├─ 📄WorldForce.mo
│  │        │     │  │  │  ├─ 📄WorldForceAndTorque.mo
│  │        │     │  │  │  └─ 📄WorldTorque.mo
│  │        │     │  │  ├─ 📁Frames
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent.mo
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent_d.mo
│  │        │     │  │  │  │  ├─ 📄maxWithoutEvent_dd.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄QuaternionBase.mo
│  │        │     │  │  │  │  ├─ 📄resolve1_der.mo
│  │        │     │  │  │  │  ├─ 📄resolve2_der.mo
│  │        │     │  │  │  │  ├─ 📄resolveRelative_der.mo
│  │        │     │  │  │  │  └─ 📄TransformationMatrix.mo
│  │        │     │  │  │  ├─ 📁Quaternions
│  │        │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │        │     │  │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │        │     │  │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  │  └─ 📄to_T_inv.mo
│  │        │     │  │  │  ├─ 📁TransformationMatrices
│  │        │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  │  ├─ 📄axesRotations.mo
│  │        │     │  │  │  │  ├─ 📄axesRotationsAngles.mo
│  │        │     │  │  │  │  ├─ 📄axisRotation.mo
│  │        │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │        │     │  │  │  │  ├─ 📄from_nxy.mo
│  │        │     │  │  │  │  ├─ 📄from_nxz.mo
│  │        │     │  │  │  │  ├─ 📄from_Q.mo
│  │        │     │  │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │        │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │        │     │  │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  │  ├─ 📄planarRotationAngle.mo
│  │        │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  │  ├─ 📄resolveDyade1.mo
│  │        │     │  │  │  │  ├─ 📄resolveDyade2.mo
│  │        │     │  │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  │  ├─ 📄to_exy.mo
│  │        │     │  │  │  │  ├─ 📄to_Q.mo
│  │        │     │  │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  │  ├─ 📄to_T_inv.mo
│  │        │     │  │  │  │  └─ 📄to_vector.mo
│  │        │     │  │  │  ├─ 📄absoluteRotation.mo
│  │        │     │  │  │  ├─ 📄angularVelocity1.mo
│  │        │     │  │  │  ├─ 📄angularVelocity2.mo
│  │        │     │  │  │  ├─ 📄axesRotations.mo
│  │        │     │  │  │  ├─ 📄axesRotationsAngles.mo
│  │        │     │  │  │  ├─ 📄axis.mo
│  │        │     │  │  │  ├─ 📄axisRotation.mo
│  │        │     │  │  │  ├─ 📄from_nxy.mo
│  │        │     │  │  │  ├─ 📄from_nxz.mo
│  │        │     │  │  │  ├─ 📄from_Q.mo
│  │        │     │  │  │  ├─ 📄from_T.mo
│  │        │     │  │  │  ├─ 📄from_T2.mo
│  │        │     │  │  │  ├─ 📄from_T_inv.mo
│  │        │     │  │  │  ├─ 📄inverseRotation.mo
│  │        │     │  │  │  ├─ 📄nullRotation.mo
│  │        │     │  │  │  ├─ 📄Orientation.mo
│  │        │     │  │  │  ├─ 📄orientationConstraint.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄planarRotation.mo
│  │        │     │  │  │  ├─ 📄planarRotationAngle.mo
│  │        │     │  │  │  ├─ 📄relativeRotation.mo
│  │        │     │  │  │  ├─ 📄resolve1.mo
│  │        │     │  │  │  ├─ 📄resolve2.mo
│  │        │     │  │  │  ├─ 📄resolveDyade1.mo
│  │        │     │  │  │  ├─ 📄resolveDyade2.mo
│  │        │     │  │  │  ├─ 📄resolveRelative.mo
│  │        │     │  │  │  ├─ 📄smallRotation.mo
│  │        │     │  │  │  ├─ 📄to_exy.mo
│  │        │     │  │  │  ├─ 📄to_Q.mo
│  │        │     │  │  │  ├─ 📄to_T.mo
│  │        │     │  │  │  ├─ 📄to_T_inv.mo
│  │        │     │  │  │  └─ 📄to_vector.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  └─ 📄Surface.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄FlangeWithBearing.mo
│  │        │     │  │  │  ├─ 📄FlangeWithBearingAdaptor.mo
│  │        │     │  │  │  ├─ 📄Frame.mo
│  │        │     │  │  │  ├─ 📄Frame_a.mo
│  │        │     │  │  │  ├─ 📄Frame_b.mo
│  │        │     │  │  │  ├─ 📄Frame_resolve.mo
│  │        │     │  │  │  ├─ 📄LineForceBase.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄partialColorMap.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryJoint.mo
│  │        │     │  │  │  ├─ 📄PartialForce.mo
│  │        │     │  │  │  ├─ 📄partialGravityAcceleration.mo
│  │        │     │  │  │  ├─ 📄PartialLineForce.mo
│  │        │     │  │  │  ├─ 📄PartialOneFrame_a.mo
│  │        │     │  │  │  ├─ 📄PartialOneFrame_b.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄partialSurfaceCharacteristic.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFrames.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFramesDoubleSize.mo
│  │        │     │  │  │  ├─ 📄PartialVisualizer.mo
│  │        │     │  │  │  └─ 📄ZeroPosition.mo
│  │        │     │  │  ├─ 📁Joints
│  │        │     │  │  │  ├─ 📁Assemblies
│  │        │     │  │  │  │  ├─ 📄JointRRP.mo
│  │        │     │  │  │  │  ├─ 📄JointRRR.mo
│  │        │     │  │  │  │  ├─ 📄JointSSP.mo
│  │        │     │  │  │  │  ├─ 📄JointSSR.mo
│  │        │     │  │  │  │  ├─ 📄JointUPS.mo
│  │        │     │  │  │  │  ├─ 📄JointUSP.mo
│  │        │     │  │  │  │  ├─ 📄JointUSR.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📁Constraints
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Prismatic.mo
│  │        │     │  │  │  │  ├─ 📄Revolute.mo
│  │        │     │  │  │  │  ├─ 📄Spherical.mo
│  │        │     │  │  │  │  └─ 📄Universal.mo
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄InitAngle.mo
│  │        │     │  │  │  │  ├─ 📄InitAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄InitPosition.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PrismaticWithLengthConstraint.mo
│  │        │     │  │  │  │  ├─ 📄RevoluteWithLengthConstraint.mo
│  │        │     │  │  │  │  └─ 📄RollingConstraintVerticalWheel.mo
│  │        │     │  │  │  ├─ 📄Cylindrical.mo
│  │        │     │  │  │  ├─ 📄FreeMotion.mo
│  │        │     │  │  │  ├─ 📄FreeMotionScalarInit.mo
│  │        │     │  │  │  ├─ 📄GearConstraint.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Planar.mo
│  │        │     │  │  │  ├─ 📄Prismatic.mo
│  │        │     │  │  │  ├─ 📄Revolute.mo
│  │        │     │  │  │  ├─ 📄RevolutePlanarLoopConstraint.mo
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │        │     │  │  │  ├─ 📄Spherical.mo
│  │        │     │  │  │  ├─ 📄SphericalSpherical.mo
│  │        │     │  │  │  ├─ 📄Universal.mo
│  │        │     │  │  │  └─ 📄UniversalSpherical.mo
│  │        │     │  │  ├─ 📁Parts
│  │        │     │  │  │  ├─ 📄BevelGear1D.mo
│  │        │     │  │  │  ├─ 📄Body.mo
│  │        │     │  │  │  ├─ 📄BodyBox.mo
│  │        │     │  │  │  ├─ 📄BodyCylinder.mo
│  │        │     │  │  │  ├─ 📄BodyShape.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄FixedRotation.mo
│  │        │     │  │  │  ├─ 📄FixedTranslation.mo
│  │        │     │  │  │  ├─ 📄Mounting1D.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PointMass.mo
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │        │     │  │  │  └─ 📄Rotor1D.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄BasicAbsoluteAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄BasicAbsolutePosition.mo
│  │        │     │  │  │  │  ├─ 📄BasicCutForce.mo
│  │        │     │  │  │  │  ├─ 📄BasicCutTorque.mo
│  │        │     │  │  │  │  ├─ 📄BasicRelativeAngularVelocity.mo
│  │        │     │  │  │  │  ├─ 📄BasicRelativePosition.mo
│  │        │     │  │  │  │  ├─ 📄BasicTransformAbsoluteVector.mo
│  │        │     │  │  │  │  ├─ 📄BasicTransformRelativeVector.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PartialAbsoluteBaseSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialCutForceBaseSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialCutForceSensor.mo
│  │        │     │  │  │  │  ├─ 📄PartialRelativeBaseSensor.mo
│  │        │     │  │  │  │  └─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄AbsoluteAngles.mo
│  │        │     │  │  │  ├─ 📄AbsoluteAngularVelocity.mo
│  │        │     │  │  │  ├─ 📄AbsolutePosition.mo
│  │        │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄AbsoluteVelocity.mo
│  │        │     │  │  │  ├─ 📄CutForce.mo
│  │        │     │  │  │  ├─ 📄CutForceAndTorque.mo
│  │        │     │  │  │  ├─ 📄CutTorque.mo
│  │        │     │  │  │  ├─ 📄Distance.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Power.mo
│  │        │     │  │  │  ├─ 📄RelativeAngles.mo
│  │        │     │  │  │  ├─ 📄RelativeAngularVelocity.mo
│  │        │     │  │  │  ├─ 📄RelativePosition.mo
│  │        │     │  │  │  ├─ 📄RelativeSensor.mo
│  │        │     │  │  │  ├─ 📄RelativeVelocity.mo
│  │        │     │  │  │  ├─ 📄TransformAbsoluteVector.mo
│  │        │     │  │  │  └─ 📄TransformRelativeVector.mo
│  │        │     │  │  ├─ 📁Types
│  │        │     │  │  │  ├─ 📁Defaults
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄Axis.mo
│  │        │     │  │  │  ├─ 📄AxisLabel.mo
│  │        │     │  │  │  ├─ 📄Color.mo
│  │        │     │  │  │  ├─ 📄GravityTypes.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RealColor.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameA.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameAB.mo
│  │        │     │  │  │  ├─ 📄ResolveInFrameB.mo
│  │        │     │  │  │  ├─ 📄RotationSequence.mo
│  │        │     │  │  │  ├─ 📄RotationTypes.mo
│  │        │     │  │  │  ├─ 📄ShapeExtra.mo
│  │        │     │  │  │  ├─ 📄ShapeType.mo
│  │        │     │  │  │  ├─ 📄SpecularCoefficient.mo
│  │        │     │  │  │  └─ 📄VectorQuantity.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📁Tutorial
│  │        │     │  │  │  │  ├─ 📁LoopStructures
│  │        │     │  │  │  │  │  ├─ 📄AnalyticLoopHandling.mo
│  │        │     │  │  │  │  │  ├─ 📄Introduction.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  └─ 📄PlanarLoops.mo
│  │        │     │  │  │  │  ├─ 📄ConnectionOfLineForces.mo
│  │        │     │  │  │  │  ├─ 📄FirstExample.mo
│  │        │     │  │  │  │  ├─ 📄OverView.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄Literature.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Visualizers
│  │        │     │  │  │  ├─ 📁Advanced
│  │        │     │  │  │  │  ├─ 📁SurfaceCharacteristics
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄pipeWithScalarField.mo
│  │        │     │  │  │  │  │  ├─ 📄rectangle.mo
│  │        │     │  │  │  │  │  └─ 📄torus.mo
│  │        │     │  │  │  │  ├─ 📄Arrow.mo
│  │        │     │  │  │  │  ├─ 📄DoubleArrow.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄PipeWithScalarField.mo
│  │        │     │  │  │  │  ├─ 📄Shape.mo
│  │        │     │  │  │  │  ├─ 📄Surface.mo
│  │        │     │  │  │  │  └─ 📄Vector.mo
│  │        │     │  │  │  ├─ 📁Colors
│  │        │     │  │  │  │  ├─ 📁ColorMaps
│  │        │     │  │  │  │  │  ├─ 📄autumn.mo
│  │        │     │  │  │  │  │  ├─ 📄gray.mo
│  │        │     │  │  │  │  │  ├─ 📄hot.mo
│  │        │     │  │  │  │  │  ├─ 📄jet.mo
│  │        │     │  │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  │  ├─ 📄spring.mo
│  │        │     │  │  │  │  │  ├─ 📄summer.mo
│  │        │     │  │  │  │  │  └─ 📄winter.mo
│  │        │     │  │  │  │  ├─ 📄colorMapToSvg.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  └─ 📄scalarToColor.mo
│  │        │     │  │  │  ├─ 📁Internal
│  │        │     │  │  │  │  ├─ 📄FixedLines.mo
│  │        │     │  │  │  │  ├─ 📄Lines.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  └─ 📄package.order
│  │        │     │  │  │  ├─ 📄FixedArrow.mo
│  │        │     │  │  │  ├─ 📄FixedFrame.mo
│  │        │     │  │  │  ├─ 📄FixedShape.mo
│  │        │     │  │  │  ├─ 📄FixedShape2.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PipeWithScalarField.mo
│  │        │     │  │  │  ├─ 📄Rectangle.mo
│  │        │     │  │  │  ├─ 📄SignalArrow.mo
│  │        │     │  │  │  ├─ 📄Torus.mo
│  │        │     │  │  │  └─ 📄VoluminousWheel.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Rotational
│  │        │     │  │  ├─ 📁Components
│  │        │     │  │  │  ├─ 📄AngleToTorqueAdaptor.mo
│  │        │     │  │  │  ├─ 📄BearingFriction.mo
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄Clutch.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄Disc.mo
│  │        │     │  │  │  ├─ 📄ElastoBacklash.mo
│  │        │     │  │  │  ├─ 📄ElastoBacklash2.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄Gearbox.mo
│  │        │     │  │  │  ├─ 📄GeneralAngleToTorqueAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralTorqueToAngleAdaptor.mo
│  │        │     │  │  │  ├─ 📄IdealGear.mo
│  │        │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │        │     │  │  │  ├─ 📄IdealPlanetary.mo
│  │        │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │        │     │  │  │  ├─ 📄Inertia.mo
│  │        │     │  │  │  ├─ 📄InitializeFlange.mo
│  │        │     │  │  │  ├─ 📄LossyGear.mo
│  │        │     │  │  │  ├─ 📄OneWayClutch.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RelativeStates.mo
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  └─ 📄TorqueToAngleAdaptor.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄DirectInertia.mo
│  │        │     │  │  │  │  ├─ 📄InverseInertia.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │        │     │  │  │  ├─ 📄Backlash.mo
│  │        │     │  │  │  ├─ 📄CompareBrakingTorque.mo
│  │        │     │  │  │  ├─ 📄CoupledClutches.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │        │     │  │  │  ├─ 📄ElasticBearing.mo
│  │        │     │  │  │  ├─ 📄First.mo
│  │        │     │  │  │  ├─ 📄FirstGrounded.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │        │     │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo1.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo2.mo
│  │        │     │  │  │  ├─ 📄LossyGearDemo3.mo
│  │        │     │  │  │  ├─ 📄OneWayClutch.mo
│  │        │     │  │  │  ├─ 📄OneWayClutchDisengaged.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RollingWheel.mo
│  │        │     │  │  │  └─ 📄SimpleGearShift.mo
│  │        │     │  │  ├─ 📁Icons
│  │        │     │  │  │  ├─ 📄Clutch.mo
│  │        │     │  │  │  ├─ 📄Gear.mo
│  │        │     │  │  │  ├─ 📄Gearbox.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  └─ 📄package.order
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄Flange.mo
│  │        │     │  │  │  ├─ 📄Flange_a.mo
│  │        │     │  │  │  ├─ 📄Flange_b.mo
│  │        │     │  │  │  ├─ 📄InternalSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄PartialCompliant.mo
│  │        │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialFriction.mo
│  │        │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄PartialTorque.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │        │     │  │  │  └─ 📄Support.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AccSensor.mo
│  │        │     │  │  │  ├─ 📄AngleSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄RelAccSensor.mo
│  │        │     │  │  │  ├─ 📄RelAngleSensor.mo
│  │        │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │        │     │  │  │  ├─ 📄SpeedSensor.mo
│  │        │     │  │  │  └─ 📄TorqueSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │        │     │  │  │  ├─ 📄ConstantTorque.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentTorque.mo
│  │        │     │  │  │  ├─ 📄InverseSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄LinearSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄Move.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Position.mo
│  │        │     │  │  │  ├─ 📄QuadraticSpeedDependentTorque.mo
│  │        │     │  │  │  ├─ 📄SignTorque.mo
│  │        │     │  │  │  ├─ 📄Speed.mo
│  │        │     │  │  │  ├─ 📄Torque.mo
│  │        │     │  │  │  ├─ 📄Torque2.mo
│  │        │     │  │  │  └─ 📄TorqueStep.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │        │     │  │  │  ├─ 📄ModelingOfFriction.mo
│  │        │     │  │  │  ├─ 📄Overview.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄References.mo
│  │        │     │  │  │  ├─ 📄RequirementsForSimulationTool.mo
│  │        │     │  │  │  ├─ 📄SignConventions.mo
│  │        │     │  │  │  ├─ 📄StateSelection.mo
│  │        │     │  │  │  ├─ 📄SupportTorques.mo
│  │        │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📁Translational
│  │        │     │  │  ├─ 📁Components
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄ElastoGap.mo
│  │        │     │  │  │  ├─ 📄Fixed.mo
│  │        │     │  │  │  ├─ 📄GeneralForceToPositionAdaptor.mo
│  │        │     │  │  │  ├─ 📄GeneralPositionToForceAdaptor.mo
│  │        │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │        │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │        │     │  │  │  ├─ 📄InitializeFlange.mo
│  │        │     │  │  │  ├─ 📄Mass.mo
│  │        │     │  │  │  ├─ 📄MassWithStopAndFriction.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄RelativeStates.mo
│  │        │     │  │  │  ├─ 📄Rod.mo
│  │        │     │  │  │  ├─ 📄RollingResistance.mo
│  │        │     │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  ├─ 📄SupportFriction.mo
│  │        │     │  │  │  └─ 📄Vehicle.mo
│  │        │     │  │  ├─ 📁Examples
│  │        │     │  │  │  ├─ 📁Utilities
│  │        │     │  │  │  │  ├─ 📄DirectMass.mo
│  │        │     │  │  │  │  ├─ 📄GenerateStribeckFrictionTable.mo
│  │        │     │  │  │  │  ├─ 📄InverseMass.mo
│  │        │     │  │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  │  ├─ 📄package.order
│  │        │     │  │  │  │  ├─ 📄Spring.mo
│  │        │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │        │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄Brake.mo
│  │        │     │  │  │  ├─ 📄CompareBrakingForce.mo
│  │        │     │  │  │  ├─ 📄Damper.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │        │     │  │  │  ├─ 📄ElastoGap.mo
│  │        │     │  │  │  ├─ 📄Friction.mo
│  │        │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │        │     │  │  │  ├─ 📄HeatLosses.mo
│  │        │     │  │  │  ├─ 📄InitialConditions.mo
│  │        │     │  │  │  ├─ 📄Oscillator.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PreLoad.mo
│  │        │     │  │  │  ├─ 📄Sensors.mo
│  │        │     │  │  │  ├─ 📄SignConvention.mo
│  │        │     │  │  │  ├─ 📄Vehicle.mo
│  │        │     │  │  │  └─ 📄WhyArrows.mo
│  │        │     │  │  ├─ 📁Interfaces
│  │        │     │  │  │  ├─ 📄Flange.mo
│  │        │     │  │  │  ├─ 📄Flange_a.mo
│  │        │     │  │  │  ├─ 📄Flange_b.mo
│  │        │     │  │  │  ├─ 📄InternalSupport.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │        │     │  │  │  ├─ 📄PartialCompliant.mo
│  │        │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │        │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │        │     │  │  │  ├─ 📄PartialForce.mo
│  │        │     │  │  │  ├─ 📄PartialFriction.mo
│  │        │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │        │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │        │     │  │  │  ├─ 📄PartialRigid.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │        │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │        │     │  │  │  └─ 📄Support.mo
│  │        │     │  │  ├─ 📁Sensors
│  │        │     │  │  │  ├─ 📄AccSensor.mo
│  │        │     │  │  │  ├─ 📄ForceSensor.mo
│  │        │     │  │  │  ├─ 📄MultiSensor.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄PositionSensor.mo
│  │        │     │  │  │  ├─ 📄PowerSensor.mo
│  │        │     │  │  │  ├─ 📄RelAccSensor.mo
│  │        │     │  │  │  ├─ 📄RelPositionSensor.mo
│  │        │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │        │     │  │  │  └─ 📄SpeedSensor.mo
│  │        │     │  │  ├─ 📁Sources
│  │        │     │  │  │  ├─ 📄Accelerate.mo
│  │        │     │  │  │  ├─ 📄ConstantForce.mo
│  │        │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │        │     │  │  │  ├─ 📄EddyCurrentForce.mo
│  │        │     │  │  │  ├─ 📄Force.mo
│  │        │     │  │  │  ├─ 📄Force2.mo
│  │        │     │  │  │  ├─ 📄ForceStep.mo
│  │        │     │  │  │  ├─ 📄InverseSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄LinearSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄Move.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄Position.mo
│  │        │     │  │  │  ├─ 📄QuadraticSpeedDependentForce.mo
│  │        │     │  │  │  ├─ 📄SignForce.mo
│  │        │     │  │  │  └─ 📄Speed.mo
│  │        │     │  │  ├─ 📁UsersGuide
│  │        │     │  │  │  ├─ 📄Contact.mo
│  │        │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │        │     │  │  │  ├─ 📄Overview.mo
│  │        │     │  │  │  ├─ 📄package.mo
│  │        │     │  │  │  ├─ 📄package.order
│  │        │     │  │  │  ├─ 📄SignConventions.mo
│  │        │     │  │  │  ├─ 📄StateSelection.mo
│  │        │     │  │  │  ├─ 📄SupportForces.mo
│  │        │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │        │     │  │  ├─ 📄package.mo
│  │        │     │  │  └─ 📄package.order
│  │        │     │  ├─ 📄package.mo
│  │        │     │  └─ 📄package.order
│  │        │     ├─ 📄.gitkeep
│  │        │     └─ 📄Untitled
│  │        ├─ 📄application-dev.yml
│  │        ├─ 📄application-prod.yml
│  │        └─ 📄application.yml
│  ├─ 📁target
│  │  ├─ 📁classes
│  │  │  ├─ 📁com
│  │  │  │  └─ 📁modelcloud
│  │  │  │     ├─ 📁common
│  │  │  │     │  ├─ 📁config
│  │  │  │     │  │  ├─ 📄AsyncConfig.class
│  │  │  │     │  │  ├─ 📄GiteaConfig.class
│  │  │  │     │  │  ├─ 📄MybatisConfig.class
│  │  │  │     │  │  ├─ 📄SecurityConfig.class
│  │  │  │     │  │  ├─ 📄SecurityUtilsConfig.class
│  │  │  │     │  │  └─ 📄WebConfig.class
│  │  │  │     │  ├─ 📁constant
│  │  │  │     │  │  └─ 📄CommonConstant.class
│  │  │  │     │  ├─ 📁exception
│  │  │  │     │  │  ├─ 📄BusinessException.class
│  │  │  │     │  │  └─ 📄GlobalExceptionHandler.class
│  │  │  │     │  ├─ 📁security
│  │  │  │     │  │  └─ 📄JwtAuthenticationFilter.class
│  │  │  │     │  ├─ 📁tools
│  │  │  │     │  │  ├─ 📄JwtUtil.class
│  │  │  │     │  │  ├─ 📄PasswordUtil.class
│  │  │  │     │  │  └─ 📄SecurityUtils.class
│  │  │  │     │  └─ 📁web
│  │  │  │     │     └─ 📁domain
│  │  │  │     │        ├─ 📁request
│  │  │  │     │        │  └─ 📄PageRequest.class
│  │  │  │     │        └─ 📁response
│  │  │  │     │           ├─ 📄Result.class
│  │  │  │     │           └─ 📄ResultCode.class
│  │  │  │     ├─ 📁modules
│  │  │  │     │  ├─ 📁auth
│  │  │  │     │  │  ├─ 📁controller
│  │  │  │     │  │  │  └─ 📄AuthController.class
│  │  │  │     │  │  ├─ 📁model
│  │  │  │     │  │  │  └─ 📁dto
│  │  │  │     │  │  │     ├─ 📄CaptchaResponse.class
│  │  │  │     │  │  │     ├─ 📄LoginRequest.class
│  │  │  │     │  │  │     ├─ 📄LoginResponse$UserInfo.class
│  │  │  │     │  │  │     ├─ 📄LoginResponse.class
│  │  │  │     │  │  │     └─ 📄RegisterRequest.class
│  │  │  │     │  │  └─ 📁service
│  │  │  │     │  │     ├─ 📁impl
│  │  │  │     │  │     │  ├─ 📄AuthServiceImpl.class
│  │  │  │     │  │     │  └─ 📄CaptchaServiceImpl.class
│  │  │  │     │  │     ├─ 📄AuthService.class
│  │  │  │     │  │     └─ 📄CaptchaService.class
│  │  │  │     │  ├─ 📁business
│  │  │  │     │  │  ├─ 📁controller
│  │  │  │     │  │  │  ├─ 📄BsModelCollectController.class
│  │  │  │     │  │  │  ├─ 📄BsModelController.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelController.class
│  │  │  │     │  │  │  ├─ 📄ModelDeployController.class
│  │  │  │     │  │  │  └─ 📄SseController.class
│  │  │  │     │  │  ├─ 📁event
│  │  │  │     │  │  │  └─ 📄VisitCountEvent.class
│  │  │  │     │  │  ├─ 📁mapper
│  │  │  │     │  │  │  ├─ 📄BsComponentMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelCollectMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelingProjectMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelMapper.class
│  │  │  │     │  │  │  ├─ 📄BsModelMapper.class
│  │  │  │     │  │  │  ├─ 📄BsSimulationTaskMapper.class
│  │  │  │     │  │  │  └─ 📄ModelLabelCategoryMapper.class
│  │  │  │     │  │  ├─ 📁model
│  │  │  │     │  │  │  ├─ 📁domain
│  │  │  │     │  │  │  │  ├─ 📁table
│  │  │  │     │  │  │  │  │  ├─ 📄BsComponentTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelCollectTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelingProjectTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelLabelTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsModelTableDef.class
│  │  │  │     │  │  │  │  │  ├─ 📄BsSimulationTaskTableDef.class
│  │  │  │     │  │  │  │  │  └─ 📄ModelLabelCategoryTableDef.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponent.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta$ConnectorMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta$ParamMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc$ConnectorMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc$ParamMeta.class
│  │  │  │     │  │  │  │  ├─ 📄BsComponentParseMetaOmc.class
│  │  │  │     │  │  │  │  ├─ 📄BsModel.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelCollect.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelingProject.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelLabel.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelParams.class
│  │  │  │     │  │  │  │  ├─ 📄BsSimulationTask.class
│  │  │  │     │  │  │  │  └─ 📄ModelLabelCategory.class
│  │  │  │     │  │  │  ├─ 📁dto
│  │  │  │     │  │  │  │  └─ 📄ComponentVO.class
│  │  │  │     │  │  │  └─ 📁request
│  │  │  │     │  │  │     ├─ 📄ComponentUploadRequest.class
│  │  │  │     │  │  │     ├─ 📄ModelingProjectRequest.class
│  │  │  │     │  │  │     ├─ 📄ModelUploadRequest.class
│  │  │  │     │  │  │     ├─ 📄SimulationRequest$SimulationParams.class
│  │  │  │     │  │  │     └─ 📄SimulationRequest.class
│  │  │  │     │  │  ├─ 📁repository
│  │  │  │     │  │  │  ├─ 📄BsComponentParseMetaOmcRepository.class
│  │  │  │     │  │  │  └─ 📄BsComponentParseMetaRepository.class
│  │  │  │     │  │  ├─ 📁service
│  │  │  │     │  │  │  ├─ 📁impl
│  │  │  │     │  │  │  │  ├─ 📄BsModelCollectServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelLabelServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄BsModelServiceImpl.class
│  │  │  │     │  │  │  │  ├─ 📄ModelDeployServiceImpl.class
│  │  │  │     │  │  │  │  └─ 📄ModelLabelCategoryServiceImpl.class
│  │  │  │     │  │  │  ├─ 📄BsModelCollectService.class
│  │  │  │     │  │  │  ├─ 📄BsModelLabelService.class
│  │  │  │     │  │  │  ├─ 📄BsModelService.class
│  │  │  │     │  │  │  ├─ 📄GiteaService.class
│  │  │  │     │  │  │  ├─ 📄ModelDeployService.class
│  │  │  │     │  │  │  └─ 📄ModelLabelCategoryService.class
│  │  │  │     │  │  └─ 📁utils
│  │  │  │     │  │     ├─ 📄ModelicaIconSvgRenderer.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ConnectorInfo.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ModelicaComponentInfo.class
│  │  │  │     │  │     ├─ 📄ModelicaParser$ParameterInfo.class
│  │  │  │     │  │     └─ 📄ModelicaParser.class
│  │  │  │     │  └─ 📁sys
│  │  │  │     │     ├─ 📁controller
│  │  │  │     │     │  └─ 📄SysUserController.class
│  │  │  │     │     ├─ 📁mapper
│  │  │  │     │     │  ├─ 📄SysRoleMapper.class
│  │  │  │     │     │  ├─ 📄SysSiteStatMapper.class
│  │  │  │     │     │  ├─ 📄SysUserMapper.class
│  │  │  │     │     │  └─ 📄SysUserRoleMapper.class
│  │  │  │     │     ├─ 📁model
│  │  │  │     │     │  ├─ 📁domain
│  │  │  │     │     │  │  ├─ 📁table
│  │  │  │     │     │  │  │  ├─ 📄SysFileTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysPowerTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysRoleTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysSiteStatTableDef.class
│  │  │  │     │     │  │  │  ├─ 📄SysUserRoleTableDef.class
│  │  │  │     │     │  │  │  └─ 📄SysUserTableDef.class
│  │  │  │     │     │  │  ├─ 📄SysFile.class
│  │  │  │     │     │  │  ├─ 📄SysPower.class
│  │  │  │     │     │  │  ├─ 📄SysRole.class
│  │  │  │     │     │  │  ├─ 📄SysSiteStat.class
│  │  │  │     │     │  │  ├─ 📄SysUser.class
│  │  │  │     │     │  │  └─ 📄SysUserRole.class
│  │  │  │     │     │  └─ 📁dto
│  │  │  │     │     │     ├─ 📄ChangePasswordRequest.class
│  │  │  │     │     │     ├─ 📄ResetPasswordRequest.class
│  │  │  │     │     │     ├─ 📄RoleVO.class
│  │  │  │     │     │     ├─ 📄UserCreateRequest.class
│  │  │  │     │     │     ├─ 📄UserProfileUpdateRequest.class
│  │  │  │     │     │     ├─ 📄UserQueryRequest.class
│  │  │  │     │     │     ├─ 📄UserUpdateRequest.class
│  │  │  │     │     │     └─ 📄UserVO.class
│  │  │  │     │     └─ 📁service
│  │  │  │     │        ├─ 📁impl
│  │  │  │     │        │  ├─ 📄SiteStatServiceImpl.class
│  │  │  │     │        │  ├─ 📄SysRoleServiceImpl.class
│  │  │  │     │        │  └─ 📄SysUserServiceImpl.class
│  │  │  │     │        ├─ 📄SiteStatService.class
│  │  │  │     │        ├─ 📄SysRoleService.class
│  │  │  │     │        └─ 📄SysUserService.class
│  │  │  │     └─ 📄ModelCloudApplication.class
│  │  │  ├─ 📁mapper
│  │  │  │  └─ 📁business
│  │  │  │     └─ 📄BsModelMapper.xml
│  │  │  ├─ 📁static
│  │  │  │  ├─ 📁component_icon
│  │  │  │  │  ├─ 📁Electrical
│  │  │  │  │  │  ├─ 📄AbsoluteSensor.svg
│  │  │  │  │  │  ├─ 📄ACAC.svg
│  │  │  │  │  │  ├─ 📄ACACConcept.svg
│  │  │  │  │  │  ├─ 📄ACCircuit.svg
│  │  │  │  │  │  ├─ 📄ACDC.svg
│  │  │  │  │  │  ├─ 📄ACDCConcept.svg
│  │  │  │  │  │  ├─ 📄ACpin.svg
│  │  │  │  │  │  ├─ 📄ACplug.svg
│  │  │  │  │  │  ├─ 📄activePower.svg
│  │  │  │  │  │  ├─ 📄ACtwoPin.svg
│  │  │  │  │  │  ├─ 📄ACtwoPlug.svg
│  │  │  │  │  │  ├─ 📄Add.svg
│  │  │  │  │  │  ├─ 📄Adder.svg
│  │  │  │  │  │  ├─ 📄Adder4.svg
│  │  │  │  │  │  ├─ 📄Additionals.svg
│  │  │  │  │  │  ├─ 📄Admittance.svg
│  │  │  │  │  │  ├─ 📄AD_Converter.svg
│  │  │  │  │  │  ├─ 📄AD_DA_conversion.svg
│  │  │  │  │  │  ├─ 📄AirGapDC.svg
│  │  │  │  │  │  ├─ 📄AirGapR.svg
│  │  │  │  │  │  ├─ 📄AirGapS.svg
│  │  │  │  │  │  ├─ 📄AmplifierWithOpAmpDetailed.svg
│  │  │  │  │  │  ├─ 📄Analog.svg
│  │  │  │  │  │  ├─ 📄AnalysatorAC.svg
│  │  │  │  │  │  ├─ 📄AnalysatorDC.svg
│  │  │  │  │  │  ├─ 📄And.svg
│  │  │  │  │  │  ├─ 📄AndGate.svg
│  │  │  │  │  │  ├─ 📄AronSensor.svg
│  │  │  │  │  │  ├─ 📄AsymmetricalLoad.svg
│  │  │  │  │  │  ├─ 📄BalancingDelta.svg
│  │  │  │  │  │  ├─ 📄BalancingStar.svg
│  │  │  │  │  │  ├─ 📄BaseCellRecord.svg
│  │  │  │  │  │  ├─ 📄BaseCellStack.svg
│  │  │  │  │  │  ├─ 📄BaseCellWithSensors.svg
│  │  │  │  │  │  ├─ 📄BaseClasses.svg
│  │  │  │  │  │  ├─ 📄BaseStackData.svg
│  │  │  │  │  │  ├─ 📄BaseStackRecord.svg
│  │  │  │  │  │  ├─ 📄BaseStackWithSensors.svg
│  │  │  │  │  │  ├─ 📄Basic.svg
│  │  │  │  │  │  ├─ 📄BasicMachines.svg
│  │  │  │  │  │  ├─ 📄Batteries.svg
│  │  │  │  │  │  ├─ 📄Battery.svg
│  │  │  │  │  │  ├─ 📄BatteryDischargeCharge.svg
│  │  │  │  │  │  ├─ 📄BatteryIcon.svg
│  │  │  │  │  │  ├─ 📄BatteryStacks.svg
│  │  │  │  │  │  ├─ 📄BatteryStacksWithSensors.svg
│  │  │  │  │  │  ├─ 📄Bjt.svg
│  │  │  │  │  │  ├─ 📄BJT2.svg
│  │  │  │  │  │  ├─ 📄BjtCalc.svg
│  │  │  │  │  │  ├─ 📄bjtCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄bjtInitEquations.svg
│  │  │  │  │  │  ├─ 📄bjtModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄BjtModelLineParams.svg
│  │  │  │  │  │  ├─ 📄bjtNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄bjtRenameParameters.svg
│  │  │  │  │  │  ├─ 📄bjtRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄Blocks.svg
│  │  │  │  │  │  ├─ 📄BooleanToLogic.svg
│  │  │  │  │  │  ├─ 📄Brush.svg
│  │  │  │  │  │  ├─ 📄BrushParameters.svg
│  │  │  │  │  │  ├─ 📄brushVoltageDrop.svg
│  │  │  │  │  │  ├─ 📄BUF3S.svg
│  │  │  │  │  │  ├─ 📄BUF3SL.svg
│  │  │  │  │  │  ├─ 📄Buffer.svg
│  │  │  │  │  │  ├─ 📄BufGate.svg
│  │  │  │  │  │  ├─ 📄BusTranscription.svg
│  │  │  │  │  │  ├─ 📄calculateGateCap.svg
│  │  │  │  │  │  ├─ 📄Capacitance.svg
│  │  │  │  │  │  ├─ 📄Capacitor.svg
│  │  │  │  │  │  ├─ 📄capacitorInitEquations.svg
│  │  │  │  │  │  ├─ 📄CapacitorModelLineParams.svg
│  │  │  │  │  │  ├─ 📄capacitorRenameParameters.svg
│  │  │  │  │  │  ├─ 📄capacitorRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄capDepGeom.svg
│  │  │  │  │  │  ├─ 📄CascodeCircuit.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassAnalog.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassOPV.svg
│  │  │  │  │  │  ├─ 📄CauerLowPassSC.svg
│  │  │  │  │  │  ├─ 📄CCC.svg
│  │  │  │  │  │  ├─ 📄CCCVcharger.svg
│  │  │  │  │  │  ├─ 📄CCCVcharging.svg
│  │  │  │  │  │  ├─ 📄CCCV_Cell.svg
│  │  │  │  │  │  ├─ 📄CCCV_CellRC.svg
│  │  │  │  │  │  ├─ 📄CCCV_Stack.svg
│  │  │  │  │  │  ├─ 📄CCCV_StackRC.svg
│  │  │  │  │  │  ├─ 📄CCV.svg
│  │  │  │  │  │  ├─ 📄Cell.svg
│  │  │  │  │  │  ├─ 📄CellBus.svg
│  │  │  │  │  │  ├─ 📄CellData.svg
│  │  │  │  │  │  ├─ 📄CellRC.svg
│  │  │  │  │  │  ├─ 📄CellRCStack.svg
│  │  │  │  │  │  ├─ 📄CellStack.svg
│  │  │  │  │  │  ├─ 📄CharacteristicIdealDiodes.svg
│  │  │  │  │  │  ├─ 📄CharacteristicThyristors.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown_R.svg
│  │  │  │  │  │  ├─ 📄ChopperStepDown_RL.svg
│  │  │  │  │  │  ├─ 📄ChopperStepUp.svg
│  │  │  │  │  │  ├─ 📄ChopperStepUp_R.svg
│  │  │  │  │  │  ├─ 📄ChuaCircuit.svg
│  │  │  │  │  │  ├─ 📄CloserWithArc.svg
│  │  │  │  │  │  ├─ 📄Comparator.svg
│  │  │  │  │  │  ├─ 📄CompareTransformers.svg
│  │  │  │  │  │  ├─ 📄Components.svg
│  │  │  │  │  │  ├─ 📄CompoundDCExcitation.svg
│  │  │  │  │  │  ├─ 📄Concept.svg
│  │  │  │  │  │  ├─ 📄ConditionalHeatPort.svg
│  │  │  │  │  │  ├─ 📄ConditionalSubstrate.svg
│  │  │  │  │  │  ├─ 📄Conductor.svg
│  │  │  │  │  │  ├─ 📄ConstantCurrent.svg
│  │  │  │  │  │  ├─ 📄Constants.svg
│  │  │  │  │  │  ├─ 📄ConstantVoltage.svg
│  │  │  │  │  │  ├─ 📄Contact.svg
│  │  │  │  │  │  ├─ 📄Control.svg
│  │  │  │  │  │  ├─ 📄ControlCircuit.svg
│  │  │  │  │  │  ├─ 📄ControlledCloserWithArc.svg
│  │  │  │  │  │  ├─ 📄ControlledDCDrives.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealClosingSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealOpeningSwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.svg
│  │  │  │  │  │  ├─ 📄ControlledOpenerWithArc.svg
│  │  │  │  │  │  ├─ 📄ControlledSwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄convertAlpha.svg
│  │  │  │  │  │  ├─ 📄Converter.svg
│  │  │  │  │  │  ├─ 📄Converters.svg
│  │  │  │  │  │  ├─ 📄convertResistance.svg
│  │  │  │  │  │  ├─ 📄Core.svg
│  │  │  │  │  │  ├─ 📄CoreParameters.svg
│  │  │  │  │  │  ├─ 📄CosineCurrent.svg
│  │  │  │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄CosineVoltage.svg
│  │  │  │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄Counter.svg
│  │  │  │  │  │  ├─ 📄Counter3.svg
│  │  │  │  │  │  ├─ 📄CoupledInductors.svg
│  │  │  │  │  │  ├─ 📄Csemiconductor.svg
│  │  │  │  │  │  ├─ 📄CurrentControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.svg
│  │  │  │  │  │  ├─ 📄CurrentsCapacitances.svg
│  │  │  │  │  │  ├─ 📄CurrentSensor.svg
│  │  │  │  │  │  ├─ 📄CurrentSource.svg
│  │  │  │  │  │  ├─ 📄CurrrentsCapacitances.svg
│  │  │  │  │  │  ├─ 📄C_Capacitor.svg
│  │  │  │  │  │  ├─ 📄C_SEMI.svg
│  │  │  │  │  │  ├─ 📄DamperCage.svg
│  │  │  │  │  │  ├─ 📄DA_Converter.svg
│  │  │  │  │  │  ├─ 📄DCAC.svg
│  │  │  │  │  │  ├─ 📄DCACConcept.svg
│  │  │  │  │  │  ├─ 📄DcBrakeSettings.svg
│  │  │  │  │  │  ├─ 📄DCDC.svg
│  │  │  │  │  │  ├─ 📄DCDCConcept.svg
│  │  │  │  │  │  ├─ 📄DcdcInverter.svg
│  │  │  │  │  │  ├─ 📄DCEE_Start.svg
│  │  │  │  │  │  ├─ 📄DcElectricalExcitedData.svg
│  │  │  │  │  │  ├─ 📄DCMachines.svg
│  │  │  │  │  │  ├─ 📄DcPermanentMagnetData.svg
│  │  │  │  │  │  ├─ 📄DCpin.svg
│  │  │  │  │  │  ├─ 📄DCPM_Cooling.svg
│  │  │  │  │  │  ├─ 📄DCPM_CurrentControlled.svg
│  │  │  │  │  │  ├─ 📄DCPM_QuasiStatic.svg
│  │  │  │  │  │  ├─ 📄DCPM_Start.svg
│  │  │  │  │  │  ├─ 📄DCPM_Temperature.svg
│  │  │  │  │  │  ├─ 📄DCPM_withLosses.svg
│  │  │  │  │  │  ├─ 📄DcSeriesExcitedData.svg
│  │  │  │  │  │  ├─ 📄DCSE_SinglePhase.svg
│  │  │  │  │  │  ├─ 📄DCSE_Start.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin1.svg
│  │  │  │  │  │  ├─ 📄DCtwoPin2.svg
│  │  │  │  │  │  ├─ 📄DC_CompareCharacteristics.svg
│  │  │  │  │  │  ├─ 📄DC_ElectricalExcited.svg
│  │  │  │  │  │  ├─ 📄DC_PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄DC_SeriesExcited.svg
│  │  │  │  │  │  ├─ 📄Dd.svg
│  │  │  │  │  │  ├─ 📄Dd00.svg
│  │  │  │  │  │  ├─ 📄Dd02.svg
│  │  │  │  │  │  ├─ 📄Dd04.svg
│  │  │  │  │  │  ├─ 📄Dd06.svg
│  │  │  │  │  │  ├─ 📄Dd08.svg
│  │  │  │  │  │  ├─ 📄Dd10.svg
│  │  │  │  │  │  ├─ 📄Delay.svg
│  │  │  │  │  │  ├─ 📄DelayParams.svg
│  │  │  │  │  │  ├─ 📄Delta.svg
│  │  │  │  │  │  ├─ 📄Der.svg
│  │  │  │  │  │  ├─ 📄Derivative.svg
│  │  │  │  │  │  ├─ 📄DEVqmeyer.svg
│  │  │  │  │  │  ├─ 📄DFF.svg
│  │  │  │  │  │  ├─ 📄DFFR.svg
│  │  │  │  │  │  ├─ 📄DFFREG.svg
│  │  │  │  │  │  ├─ 📄DFFREGL.svg
│  │  │  │  │  │  ├─ 📄DFFREGSRH.svg
│  │  │  │  │  │  ├─ 📄DFFREGSRL.svg
│  │  │  │  │  │  ├─ 📄DFFSR.svg
│  │  │  │  │  │  ├─ 📄DifferenceAmplifier.svg
│  │  │  │  │  │  ├─ 📄DifferentialAmplifier.svg
│  │  │  │  │  │  ├─ 📄DifferentialAmplifierData.svg
│  │  │  │  │  │  ├─ 📄Differentiator.svg
│  │  │  │  │  │  ├─ 📄Digital.svg
│  │  │  │  │  │  ├─ 📄DigitalClock.svg
│  │  │  │  │  │  ├─ 📄DigitalInput.svg
│  │  │  │  │  │  ├─ 📄DigitalOutput.svg
│  │  │  │  │  │  ├─ 📄DigitalSignal.svg
│  │  │  │  │  │  ├─ 📄Dimmer.svg
│  │  │  │  │  │  ├─ 📄Dimmer_R.svg
│  │  │  │  │  │  ├─ 📄Dimmer_RL.svg
│  │  │  │  │  │  ├─ 📄Diode.svg
│  │  │  │  │  │  ├─ 📄Diode2.svg
│  │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCalc.svg
│  │  │  │  │  │  ├─ 📄diodeCalcAdditionalValues.svg
│  │  │  │  │  │  ├─ 📄diodeCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄diodeInitEquations.svg
│  │  │  │  │  │  ├─ 📄diodeModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄DiodeModelLineParams.svg
│  │  │  │  │  │  ├─ 📄DiodeModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄diodeNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄DiodeParams.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParameters.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄diodeRenameParametersDevTemp.svg
│  │  │  │  │  │  ├─ 📄DiodeVariables.svg
│  │  │  │  │  │  ├─ 📄DirectCapacitor.svg
│  │  │  │  │  │  ├─ 📄DirectInductor.svg
│  │  │  │  │  │  ├─ 📄Discrimination.svg
│  │  │  │  │  │  ├─ 📄DLATR.svg
│  │  │  │  │  │  ├─ 📄DLATRAM.svg
│  │  │  │  │  │  ├─ 📄DLATREG.svg
│  │  │  │  │  │  ├─ 📄DLATREGL.svg
│  │  │  │  │  │  ├─ 📄DLATREGSRH.svg
│  │  │  │  │  │  ├─ 📄DLATREGSRL.svg
│  │  │  │  │  │  ├─ 📄DLATROM.svg
│  │  │  │  │  │  ├─ 📄DLATSR.svg
│  │  │  │  │  │  ├─ 📄DQCurrentController.svg
│  │  │  │  │  │  ├─ 📄DQToThreePhase.svg
│  │  │  │  │  │  ├─ 📄drainCur.svg
│  │  │  │  │  │  ├─ 📄drainCurRevised.svg
│  │  │  │  │  │  ├─ 📄Drive.svg
│  │  │  │  │  │  ├─ 📄DriveDataDCPM.svg
│  │  │  │  │  │  ├─ 📄Dy.svg
│  │  │  │  │  │  ├─ 📄Dy01.svg
│  │  │  │  │  │  ├─ 📄Dy03.svg
│  │  │  │  │  │  ├─ 📄Dy05.svg
│  │  │  │  │  │  ├─ 📄Dy07.svg
│  │  │  │  │  │  ├─ 📄Dy09.svg
│  │  │  │  │  │  ├─ 📄Dy11.svg
│  │  │  │  │  │  ├─ 📄Dz.svg
│  │  │  │  │  │  ├─ 📄Dz00.svg
│  │  │  │  │  │  ├─ 📄Dz02.svg
│  │  │  │  │  │  ├─ 📄Dz04.svg
│  │  │  │  │  │  ├─ 📄Dz06.svg
│  │  │  │  │  │  ├─ 📄Dz08.svg
│  │  │  │  │  │  ├─ 📄Dz10.svg
│  │  │  │  │  │  ├─ 📄D_DIODE.svg
│  │  │  │  │  │  ├─ 📄Electrical.svg
│  │  │  │  │  │  ├─ 📄ElectricalExcitation.svg
│  │  │  │  │  │  ├─ 📄ElectricalPowerSensor.svg
│  │  │  │  │  │  ├─ 📄ElectricFieldStrength_cm.svg
│  │  │  │  │  │  ├─ 📄Enable.svg
│  │  │  │  │  │  ├─ 📄Enable1.svg
│  │  │  │  │  │  ├─ 📄Enable1m.svg
│  │  │  │  │  │  ├─ 📄Enable2.svg
│  │  │  │  │  │  ├─ 📄Enable2m.svg
│  │  │  │  │  │  ├─ 📄EnableLogic.svg
│  │  │  │  │  │  ├─ 📄energyGapDepTemp.svg
│  │  │  │  │  │  ├─ 📄energyGapDepTemp_old.svg
│  │  │  │  │  │  ├─ 📄equalityConstraint.svg
│  │  │  │  │  │  ├─ 📄ExampleData.svg
│  │  │  │  │  │  ├─ 📄Examples.svg
│  │  │  │  │  │  ├─ 📄ExampleTemplate.svg
│  │  │  │  │  │  ├─ 📄ExampleTemplates.svg
│  │  │  │  │  │  ├─ 📄ExponentialsCurrent.svg
│  │  │  │  │  │  ├─ 📄ExponentialsVoltage.svg
│  │  │  │  │  │  ├─ 📄ExpSineCurrent.svg
│  │  │  │  │  │  ├─ 📄ExpSineVoltage.svg
│  │  │  │  │  │  ├─ 📄E_VCV.svg
│  │  │  │  │  │  ├─ 📄E_VCV_POLY.svg
│  │  │  │  │  │  ├─ 📄factorY2D.svg
│  │  │  │  │  │  ├─ 📄factorY2DC.svg
│  │  │  │  │  │  ├─ 📄FCNiout_limit.svg
│  │  │  │  │  │  ├─ 📄FCNq_sum_limit.svg
│  │  │  │  │  │  ├─ 📄Feedback.svg
│  │  │  │  │  │  ├─ 📄Fet.svg
│  │  │  │  │  │  ├─ 📄FetModelLine.svg
│  │  │  │  │  │  ├─ 📄fetRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄Filter.svg
│  │  │  │  │  │  ├─ 📄FirstOrder.svg
│  │  │  │  │  │  ├─ 📄FlangeSupport.svg
│  │  │  │  │  │  ├─ 📄FlipFlop.svg
│  │  │  │  │  │  ├─ 📄FOURBIT.svg
│  │  │  │  │  │  ├─ 📄FourInverters.svg
│  │  │  │  │  │  ├─ 📄FourPin.svg
│  │  │  │  │  │  ├─ 📄FourPlug.svg
│  │  │  │  │  │  ├─ 📄FrequencySensor.svg
│  │  │  │  │  │  ├─ 📄FrequencySweepCurrentSource.svg
│  │  │  │  │  │  ├─ 📄FrequencySweepVoltageSource.svg
│  │  │  │  │  │  ├─ 📄Friction.svg
│  │  │  │  │  │  ├─ 📄FrictionParameters.svg
│  │  │  │  │  │  ├─ 📄FromDQ.svg
│  │  │  │  │  │  ├─ 📄FromPolar.svg
│  │  │  │  │  │  ├─ 📄FromSpacePhasor.svg
│  │  │  │  │  │  ├─ 📄FromSymmetricalComponents.svg
│  │  │  │  │  │  ├─ 📄FullAdder.svg
│  │  │  │  │  │  ├─ 📄Functions.svg
│  │  │  │  │  │  ├─ 📄FundamentalWaveMachine.svg
│  │  │  │  │  │  ├─ 📄F_CCC.svg
│  │  │  │  │  │  ├─ 📄F_CCC_POLY.svg
│  │  │  │  │  │  ├─ 📄Gain.svg
│  │  │  │  │  │  ├─ 📄GapEnergyPerEnergy.svg
│  │  │  │  │  │  ├─ 📄GapEnergyPerTemperature.svg
│  │  │  │  │  │  ├─ 📄Gates.svg
│  │  │  │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.svg
│  │  │  │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.svg
│  │  │  │  │  │  ├─ 📄GenerationOfFMUs.svg
│  │  │  │  │  │  ├─ 📄getMemory.svg
│  │  │  │  │  │  ├─ 📄getNumberOfElectricalPins.svg
│  │  │  │  │  │  ├─ 📄Glossar.svg
│  │  │  │  │  │  ├─ 📄Graetz.svg
│  │  │  │  │  │  ├─ 📄GraetzRectifier.svg
│  │  │  │  │  │  ├─ 📄Ground.svg
│  │  │  │  │  │  ├─ 📄Gyrator.svg
│  │  │  │  │  │  ├─ 📄G_VCC.svg
│  │  │  │  │  │  ├─ 📄G_VCC_POLY.svg
│  │  │  │  │  │  ├─ 📄HalfAdder.svg
│  │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄HallSensor.svg
│  │  │  │  │  │  ├─ 📄HBridge.svg
│  │  │  │  │  │  ├─ 📄HBridge_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄HBridge_R.svg
│  │  │  │  │  │  ├─ 📄HBridge_RL.svg
│  │  │  │  │  │  ├─ 📄HeatingMOSInverter.svg
│  │  │  │  │  │  ├─ 📄HeatingNPN_NORGate.svg
│  │  │  │  │  │  ├─ 📄HeatingPNP_NORGate.svg
│  │  │  │  │  │  ├─ 📄HeatingRectifier.svg
│  │  │  │  │  │  ├─ 📄HighPass.svg
│  │  │  │  │  │  ├─ 📄H_CCV.svg
│  │  │  │  │  │  ├─ 📄H_CCV_POLY.svg
│  │  │  │  │  │  ├─ 📄Icons.svg
│  │  │  │  │  │  ├─ 📄Ideal.svg
│  │  │  │  │  │  ├─ 📄IdealACDCConverter.svg
│  │  │  │  │  │  ├─ 📄IdealClosingSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealCommutingSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealCore.svg
│  │  │  │  │  │  ├─ 📄IdealDcDc.svg
│  │  │  │  │  │  ├─ 📄IdealDiode.svg
│  │  │  │  │  │  ├─ 📄IdealGTOThyristor.svg
│  │  │  │  │  │  ├─ 📄IdealIntermediateSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealizedOpAmpLimited.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmp.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmp3Pin.svg
│  │  │  │  │  │  ├─ 📄IdealOpAmpLimited.svg
│  │  │  │  │  │  ├─ 📄IdealOpeningSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealSemiconductor.svg
│  │  │  │  │  │  ├─ 📄IdealSwitch.svg
│  │  │  │  │  │  ├─ 📄IdealSwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄IdealThyristor.svg
│  │  │  │  │  │  ├─ 📄IdealTransformer.svg
│  │  │  │  │  │  ├─ 📄IdealTriac.svg
│  │  │  │  │  │  ├─ 📄IdealTriacCircuit.svg
│  │  │  │  │  │  ├─ 📄IdealTwoWaySwitch.svg
│  │  │  │  │  │  ├─ 📄Idle.svg
│  │  │  │  │  │  ├─ 📄IMC_Conveyor.svg
│  │  │  │  │  │  ├─ 📄IMC_DCBraking.svg
│  │  │  │  │  │  ├─ 📄IMC_DOL.svg
│  │  │  │  │  │  ├─ 📄IMC_Initialize.svg
│  │  │  │  │  │  ├─ 📄IMC_Inverter.svg
│  │  │  │  │  │  ├─ 📄IMC_InverterDrive.svg
│  │  │  │  │  │  ├─ 📄IMC_Steinmetz.svg
│  │  │  │  │  │  ├─ 📄IMC_Transformer.svg
│  │  │  │  │  │  ├─ 📄IMC_withLosses.svg
│  │  │  │  │  │  ├─ 📄IMC_YD.svg
│  │  │  │  │  │  ├─ 📄IMC_YDarc.svg
│  │  │  │  │  │  ├─ 📄Impedance.svg
│  │  │  │  │  │  ├─ 📄IMS_Start.svg
│  │  │  │  │  │  ├─ 📄IM_SlipRing.svg
│  │  │  │  │  │  ├─ 📄IM_SlipRingData.svg
│  │  │  │  │  │  ├─ 📄IM_SquirrelCage.svg
│  │  │  │  │  │  ├─ 📄IM_SquirrelCageData.svg
│  │  │  │  │  │  ├─ 📄index.html
│  │  │  │  │  │  ├─ 📄indexNonPositiveSequence.svg
│  │  │  │  │  │  ├─ 📄indexPositiveSequence.svg
│  │  │  │  │  │  ├─ 📄InductionMachineData.svg
│  │  │  │  │  │  ├─ 📄InductionMachines.svg
│  │  │  │  │  │  ├─ 📄InductiveCouplePinIn.svg
│  │  │  │  │  │  ├─ 📄InductiveCouplePinOut.svg
│  │  │  │  │  │  ├─ 📄Inductor.svg
│  │  │  │  │  │  ├─ 📄InductorDC.svg
│  │  │  │  │  │  ├─ 📄InertialDelay.svg
│  │  │  │  │  │  ├─ 📄InertialDelaySensitive.svg
│  │  │  │  │  │  ├─ 📄InertialDelaySensitiveVector.svg
│  │  │  │  │  │  ├─ 📄initJunctionVoltagesRevised.svg
│  │  │  │  │  │  ├─ 📄Integrator.svg
│  │  │  │  │  │  ├─ 📄Interfaces.svg
│  │  │  │  │  │  ├─ 📄Internal.svg
│  │  │  │  │  │  ├─ 📄IntersectivePWM.svg
│  │  │  │  │  │  ├─ 📄Introduction.svg
│  │  │  │  │  │  ├─ 📄INV3S.svg
│  │  │  │  │  │  ├─ 📄INV3SL.svg
│  │  │  │  │  │  ├─ 📄InverseCapacitor.svg
│  │  │  │  │  │  ├─ 📄InverseElectricCurrent.svg
│  │  │  │  │  │  ├─ 📄InverseInductor.svg
│  │  │  │  │  │  ├─ 📄Inverter.svg
│  │  │  │  │  │  ├─ 📄InvertersApartRecord.svg
│  │  │  │  │  │  ├─ 📄InvertersExtendedModel.svg
│  │  │  │  │  │  ├─ 📄InvertingAmp.svg
│  │  │  │  │  │  ├─ 📄InvertingAmplifier.svg
│  │  │  │  │  │  ├─ 📄InvertingSchmittTrigger.svg
│  │  │  │  │  │  ├─ 📄InvGate.svg
│  │  │  │  │  │  ├─ 📄I_constant.svg
│  │  │  │  │  │  ├─ 📄I_exp.svg
│  │  │  │  │  │  ├─ 📄I_pulse.svg
│  │  │  │  │  │  ├─ 📄I_pwl.svg
│  │  │  │  │  │  ├─ 📄I_sffm.svg
│  │  │  │  │  │  ├─ 📄I_sin.svg
│  │  │  │  │  │  ├─ 📄JFET.svg
│  │  │  │  │  │  ├─ 📄jfetCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄jfetInitEquations.svg
│  │  │  │  │  │  ├─ 📄JfetModelLine.svg
│  │  │  │  │  │  ├─ 📄jfetModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄jfetNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄jfetRenameParameters.svg
│  │  │  │  │  │  ├─ 📄JKFF.svg
│  │  │  │  │  │  ├─ 📄junction2.svg
│  │  │  │  │  │  ├─ 📄junction2SPICE3BJT.svg
│  │  │  │  │  │  ├─ 📄junction2SPICE3MOSFETRevised.svg
│  │  │  │  │  │  ├─ 📄junction3.svg
│  │  │  │  │  │  ├─ 📄junctionCapCoeffs.svg
│  │  │  │  │  │  ├─ 📄junctionCapRevised.svg
│  │  │  │  │  │  ├─ 📄junctionCapTransTime.svg
│  │  │  │  │  │  ├─ 📄junctionParamDepTempSPICE3.svg
│  │  │  │  │  │  ├─ 📄junctionPotDepTemp.svg
│  │  │  │  │  │  ├─ 📄junctionVCrit.svg
│  │  │  │  │  │  ├─ 📄junctionVoltage23SPICE3.svg
│  │  │  │  │  │  ├─ 📄J_NJFJFET.svg
│  │  │  │  │  │  ├─ 📄J_PJFJFET.svg
│  │  │  │  │  │  ├─ 📄K_CoupledInductors.svg
│  │  │  │  │  │  ├─ 📄LCOscillator.svg
│  │  │  │  │  │  ├─ 📄LessThreshold.svg
│  │  │  │  │  │  ├─ 📄LimitedPI.svg
│  │  │  │  │  │  ├─ 📄limitJunctionVoltageRevised.svg
│  │  │  │  │  │  ├─ 📄LinearTemperatureCoefficient20.svg
│  │  │  │  │  │  ├─ 📄linearTemperatureDependency.svg
│  │  │  │  │  │  ├─ 📄Lines.svg
│  │  │  │  │  │  ├─ 📄Literature.svg
│  │  │  │  │  │  ├─ 📄Logic.svg
│  │  │  │  │  │  ├─ 📄LogicToBoolean.svg
│  │  │  │  │  │  ├─ 📄LogicToReal.svg
│  │  │  │  │  │  ├─ 📄LogicToUX01.svg
│  │  │  │  │  │  ├─ 📄LogicToX01.svg
│  │  │  │  │  │  ├─ 📄LogicToX01Z.svg
│  │  │  │  │  │  ├─ 📄Losses.svg
│  │  │  │  │  │  ├─ 📄LowPass.svg
│  │  │  │  │  │  ├─ 📄L_Inductor.svg
│  │  │  │  │  │  ├─ 📄Machine.svg
│  │  │  │  │  │  ├─ 📄Machines.svg
│  │  │  │  │  │  ├─ 📄MaterialParameters.svg
│  │  │  │  │  │  ├─ 📄MechanicalPowerSensor.svg
│  │  │  │  │  │  ├─ 📄Memories.svg
│  │  │  │  │  │  ├─ 📄MemoryBase.svg
│  │  │  │  │  │  ├─ 📄MIMO.svg
│  │  │  │  │  │  ├─ 📄MISO.svg
│  │  │  │  │  │  ├─ 📄MNmos.svg
│  │  │  │  │  │  ├─ 📄Model.svg
│  │  │  │  │  │  ├─ 📄ModelcardBJT.svg
│  │  │  │  │  │  ├─ 📄ModelcardBJT2.svg
│  │  │  │  │  │  ├─ 📄ModelcardC.svg
│  │  │  │  │  │  ├─ 📄ModelcardCAPACITOR.svg
│  │  │  │  │  │  ├─ 📄ModelcardDIODE.svg
│  │  │  │  │  │  ├─ 📄ModelcardJFET.svg
│  │  │  │  │  │  ├─ 📄ModelcardMOS.svg
│  │  │  │  │  │  ├─ 📄ModelcardMOS2.svg
│  │  │  │  │  │  ├─ 📄ModelcardR.svg
│  │  │  │  │  │  ├─ 📄ModelcardRESISTOR.svg
│  │  │  │  │  │  ├─ 📄MOS.svg
│  │  │  │  │  │  ├─ 📄Mos1.svg
│  │  │  │  │  │  ├─ 📄Mos1Calc.svg
│  │  │  │  │  │  ├─ 📄Mos1ModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mos1ModelLineParamsInitEquations.svg
│  │  │  │  │  │  ├─ 📄mos1RenameParameters.svg
│  │  │  │  │  │  ├─ 📄mos1RenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄MOS2.svg
│  │  │  │  │  │  ├─ 📄Mos2Calc.svg
│  │  │  │  │  │  ├─ 📄mos2CalcCalcTempDependenciesRevised.svg
│  │  │  │  │  │  ├─ 📄mos2CalcInitEquationsRevised.svg
│  │  │  │  │  │  ├─ 📄mos2CalcNoBypassCodeRevised.svg
│  │  │  │  │  │  ├─ 📄Mos2ModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mos2ModelLineParamsInitEquationsRevised.svg
│  │  │  │  │  │  ├─ 📄Mos2ModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄mos2RenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄mos2RenameParametersRevised.svg
│  │  │  │  │  │  ├─ 📄MosCalc.svg
│  │  │  │  │  │  ├─ 📄mosCalcCalcTempDependencies.svg
│  │  │  │  │  │  ├─ 📄mosCalcDEVqmeyer.svg
│  │  │  │  │  │  ├─ 📄mosCalcInitEquations.svg
│  │  │  │  │  │  ├─ 📄mosCalcNoBypassCode.svg
│  │  │  │  │  │  ├─ 📄Mosfet.svg
│  │  │  │  │  │  ├─ 📄MosfetCalc.svg
│  │  │  │  │  │  ├─ 📄mosfetInitEquations.svg
│  │  │  │  │  │  ├─ 📄MosfetModelLine.svg
│  │  │  │  │  │  ├─ 📄mosfetModelLineInitEquations.svg
│  │  │  │  │  │  ├─ 📄MosfetModelLineParams.svg
│  │  │  │  │  │  ├─ 📄mosfetRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄MosModelLineParams.svg
│  │  │  │  │  │  ├─ 📄MosModelLineVariables.svg
│  │  │  │  │  │  ├─ 📄MPmos.svg
│  │  │  │  │  │  ├─ 📄MultiDelta.svg
│  │  │  │  │  │  ├─ 📄Multiplexer.svg
│  │  │  │  │  │  ├─ 📄Multiplexers.svg
│  │  │  │  │  │  ├─ 📄MultiSensor.svg
│  │  │  │  │  │  ├─ 📄MultiStar.svg
│  │  │  │  │  │  ├─ 📄MultiStarResistance.svg
│  │  │  │  │  │  ├─ 📄MultiTerminalBox.svg
│  │  │  │  │  │  ├─ 📄Multivibrator.svg
│  │  │  │  │  │  ├─ 📄MutualInductor.svg
│  │  │  │  │  │  ├─ 📄MUX2x1.svg
│  │  │  │  │  │  ├─ 📄MUX4.svg
│  │  │  │  │  │  ├─ 📄M_NMOS.svg
│  │  │  │  │  │  ├─ 📄M_NMOS2.svg
│  │  │  │  │  │  ├─ 📄M_OLine.svg
│  │  │  │  │  │  ├─ 📄M_PMOS.svg
│  │  │  │  │  │  ├─ 📄M_PMOS2.svg
│  │  │  │  │  │  ├─ 📄M_Transformer.svg
│  │  │  │  │  │  ├─ 📄NamingPrinciple.svg
│  │  │  │  │  │  ├─ 📄Nand.svg
│  │  │  │  │  │  ├─ 📄NandGate.svg
│  │  │  │  │  │  ├─ 📄NegativePin.svg
│  │  │  │  │  │  ├─ 📄NegativePlug.svg
│  │  │  │  │  │  ├─ 📄NMOS.svg
│  │  │  │  │  │  ├─ 📄NonInvertingAmplifier.svg
│  │  │  │  │  │  ├─ 📄NonlinearResistor.svg
│  │  │  │  │  │  ├─ 📄Nor.svg
│  │  │  │  │  │  ├─ 📄NorGate.svg
│  │  │  │  │  │  ├─ 📄Not.svg
│  │  │  │  │  │  ├─ 📄NPN.svg
│  │  │  │  │  │  ├─ 📄NRXFER.svg
│  │  │  │  │  │  ├─ 📄NRXFERGATE.svg
│  │  │  │  │  │  ├─ 📄numberOfSymmetricBaseSystems.svg
│  │  │  │  │  │  ├─ 📄NXFER.svg
│  │  │  │  │  │  ├─ 📄NXFERGATE.svg
│  │  │  │  │  │  ├─ 📄OLine.svg
│  │  │  │  │  │  ├─ 📄ONEBIT.svg
│  │  │  │  │  │  ├─ 📄OnePort.svg
│  │  │  │  │  │  ├─ 📄OpAmp.svg
│  │  │  │  │  │  ├─ 📄OpAmpCircuits.svg
│  │  │  │  │  │  ├─ 📄OpAmpDetailed.svg
│  │  │  │  │  │  ├─ 📄OpAmps.svg
│  │  │  │  │  │  ├─ 📄OpenerWithArc.svg
│  │  │  │  │  │  ├─ 📄Or.svg
│  │  │  │  │  │  ├─ 📄OrGate.svg
│  │  │  │  │  │  ├─ 📄Oscillator.svg
│  │  │  │  │  │  ├─ 📄Overview.svg
│  │  │  │  │  │  ├─ 📄OvervoltageProtection.svg
│  │  │  │  │  │  ├─ 📄ParallelResonance.svg
│  │  │  │  │  │  ├─ 📄ParameterHandling.svg
│  │  │  │  │  │  ├─ 📄Parameterization.svg
│  │  │  │  │  │  ├─ 📄ParameterRecords.svg
│  │  │  │  │  │  ├─ 📄PartialAirGap.svg
│  │  │  │  │  │  ├─ 📄PartialAirGapDC.svg
│  │  │  │  │  │  ├─ 📄PartialBasicDCMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicInductionMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicMachine.svg
│  │  │  │  │  │  ├─ 📄PartialBasicTransformer.svg
│  │  │  │  │  │  ├─ 📄PartialConditionalHeatPort.svg
│  │  │  │  │  │  ├─ 📄PartialControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄PartialCore.svg
│  │  │  │  │  │  ├─ 📄PartialOpAmp.svg
│  │  │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalPortDCMachines.svg
│  │  │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetLosses.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetLossParameters.svg
│  │  │  │  │  │  ├─ 📄PermanentMagnetWithLosses.svg
│  │  │  │  │  │  ├─ 📄PerVolume.svg
│  │  │  │  │  │  ├─ 📄PhaseOrientation.svg
│  │  │  │  │  │  ├─ 📄PI.svg
│  │  │  │  │  │  ├─ 📄Pin.svg
│  │  │  │  │  │  ├─ 📄Plug.svg
│  │  │  │  │  │  ├─ 📄PlugToPins_n.svg
│  │  │  │  │  │  ├─ 📄PlugToPins_p.svg
│  │  │  │  │  │  ├─ 📄PlugToPin_n.svg
│  │  │  │  │  │  ├─ 📄PlugToPin_p.svg
│  │  │  │  │  │  ├─ 📄PMOS.svg
│  │  │  │  │  │  ├─ 📄PNP.svg
│  │  │  │  │  │  ├─ 📄poly.svg
│  │  │  │  │  │  ├─ 📄Polyphase.svg
│  │  │  │  │  │  ├─ 📄Polyphase2Level.svg
│  │  │  │  │  │  ├─ 📄PolyphaseRectifier.svg
│  │  │  │  │  │  ├─ 📄PolyphaseRectifierData.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTriac.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.svg
│  │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.svg
│  │  │  │  │  │  ├─ 📄PositionControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄PositivePin.svg
│  │  │  │  │  │  ├─ 📄PositivePlug.svg
│  │  │  │  │  │  ├─ 📄PotentialSensor.svg
│  │  │  │  │  │  ├─ 📄Potentiometer.svg
│  │  │  │  │  │  ├─ 📄Power.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCCE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCEE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCPM.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceDCSE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceIMC.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceIMS.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMEE.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMPM.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceSMR.svg
│  │  │  │  │  │  ├─ 📄PowerBalanceTransformer.svg
│  │  │  │  │  │  ├─ 📄PowerConverters.svg
│  │  │  │  │  │  ├─ 📄PowerSensor.svg
│  │  │  │  │  │  ├─ 📄PRXFERGATE.svg
│  │  │  │  │  │  ├─ 📄Pulse.svg
│  │  │  │  │  │  ├─ 📄PulseCurrent.svg
│  │  │  │  │  │  ├─ 📄PulseSeries.svg
│  │  │  │  │  │  ├─ 📄PulseVoltage.svg
│  │  │  │  │  │  ├─ 📄PWM.svg
│  │  │  │  │  │  ├─ 📄PWMType.svg
│  │  │  │  │  │  ├─ 📄PXFERGATE.svg
│  │  │  │  │  │  ├─ 📄QuasiRMS.svg
│  │  │  │  │  │  ├─ 📄QuasiStatic.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticDCMachines.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticMachine.svg
│  │  │  │  │  │  ├─ 📄QuasiStaticTransformer.svg
│  │  │  │  │  │  ├─ 📄Q_NPNBJT.svg
│  │  │  │  │  │  ├─ 📄Q_PNPBJT.svg
│  │  │  │  │  │  ├─ 📄RAM.svg
│  │  │  │  │  │  ├─ 📄RampCurrent.svg
│  │  │  │  │  │  ├─ 📄RampedRheostat.svg
│  │  │  │  │  │  ├─ 📄RampVoltage.svg
│  │  │  │  │  │  ├─ 📄RCData.svg
│  │  │  │  │  │  ├─ 📄ReactivePowerSensor.svg
│  │  │  │  │  │  ├─ 📄RealSwitch.svg
│  │  │  │  │  │  ├─ 📄RealToLogic.svg
│  │  │  │  │  │  ├─ 📄Rectifier.svg
│  │  │  │  │  │  ├─ 📄Rectifier12pulse.svg
│  │  │  │  │  │  ├─ 📄Rectifier1Pulse.svg
│  │  │  │  │  │  ├─ 📄Rectifier6pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄RectifierBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄RectifierCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄Reference.svg
│  │  │  │  │  │  ├─ 📄ReferenceCurrentSource.svg
│  │  │  │  │  │  ├─ 📄References.svg
│  │  │  │  │  │  ├─ 📄ReferenceSensor.svg
│  │  │  │  │  │  ├─ 📄ReferenceSource.svg
│  │  │  │  │  │  ├─ 📄ReferenceSystem.svg
│  │  │  │  │  │  ├─ 📄ReferenceType.svg
│  │  │  │  │  │  ├─ 📄ReferenceVoltageSource.svg
│  │  │  │  │  │  ├─ 📄Registers.svg
│  │  │  │  │  │  ├─ 📄RelativeSensor.svg
│  │  │  │  │  │  ├─ 📄RelativeSensorElementary.svg
│  │  │  │  │  │  ├─ 📄ReleaseNotes.svg
│  │  │  │  │  │  ├─ 📄resDepGeom.svg
│  │  │  │  │  │  ├─ 📄resDepTemp.svg
│  │  │  │  │  │  ├─ 📄Resistor.svg
│  │  │  │  │  │  ├─ 📄resistorInitEquations.svg
│  │  │  │  │  │  ├─ 📄ResistorModelLineParams.svg
│  │  │  │  │  │  ├─ 📄ResistorParams.svg
│  │  │  │  │  │  ├─ 📄resistorRenameParameters.svg
│  │  │  │  │  │  ├─ 📄resistorRenameParametersDev.svg
│  │  │  │  │  │  ├─ 📄ResistorVariables.svg
│  │  │  │  │  │  ├─ 📄ResonanceCircuits.svg
│  │  │  │  │  │  ├─ 📄RotationalEMF.svg
│  │  │  │  │  │  ├─ 📄Rotator.svg
│  │  │  │  │  │  ├─ 📄RotorDisplacementAngle.svg
│  │  │  │  │  │  ├─ 📄RS.svg
│  │  │  │  │  │  ├─ 📄Rsemiconductor.svg
│  │  │  │  │  │  ├─ 📄RSFF.svg
│  │  │  │  │  │  ├─ 📄R_Resistor.svg
│  │  │  │  │  │  ├─ 📄R_SEMI.svg
│  │  │  │  │  │  ├─ 📄SaturatingInductor.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3JFET.svg
│  │  │  │  │  │  ├─ 📄saturationCurDepTempSPICE3MOSFET.svg
│  │  │  │  │  │  ├─ 📄SawToothCurrent.svg
│  │  │  │  │  │  ├─ 📄SawToothVoltage.svg
│  │  │  │  │  │  ├─ 📄SchmittTrigger.svg
│  │  │  │  │  │  ├─ 📄segment.svg
│  │  │  │  │  │  ├─ 📄segment_last.svg
│  │  │  │  │  │  ├─ 📄Semiconductors.svg
│  │  │  │  │  │  ├─ 📄Sensors.svg
│  │  │  │  │  │  ├─ 📄SeriesBode.svg
│  │  │  │  │  │  ├─ 📄SeriesResonance.svg
│  │  │  │  │  │  ├─ 📄Set.svg
│  │  │  │  │  │  ├─ 📄Short.svg
│  │  │  │  │  │  ├─ 📄ShowImpedance.svg
│  │  │  │  │  │  ├─ 📄ShowSaturatingInductor.svg
│  │  │  │  │  │  ├─ 📄ShowVariableResistor.svg
│  │  │  │  │  │  ├─ 📄Signal2mPulse.svg
│  │  │  │  │  │  ├─ 📄SignalCurrent.svg
│  │  │  │  │  │  ├─ 📄SignalGenerator.svg
│  │  │  │  │  │  ├─ 📄SignalPWM.svg
│  │  │  │  │  │  ├─ 📄SignalVoltage.svg
│  │  │  │  │  │  ├─ 📄SimpleTriac.svg
│  │  │  │  │  │  ├─ 📄SimpleTriacCircuit.svg
│  │  │  │  │  │  ├─ 📄SinCosEvaluation.svg
│  │  │  │  │  │  ├─ 📄SinCosResolver.svg
│  │  │  │  │  │  ├─ 📄SineCurrent.svg
│  │  │  │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄SineVoltage.svg
│  │  │  │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.svg
│  │  │  │  │  │  ├─ 📄SinglePhase.svg
│  │  │  │  │  │  ├─ 📄SinglePhase2Level.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTriac.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.svg
│  │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_RL.svg
│  │  │  │  │  │  ├─ 📄SingleToPolyphase.svg
│  │  │  │  │  │  ├─ 📄SISO.svg
│  │  │  │  │  │  ├─ 📄SMEE_DOL.svg
│  │  │  │  │  │  ├─ 📄SMEE_Generator.svg
│  │  │  │  │  │  ├─ 📄SMEE_LoadDump.svg
│  │  │  │  │  │  ├─ 📄SMEE_Rectifier.svg
│  │  │  │  │  │  ├─ 📄SMPM_Braking.svg
│  │  │  │  │  │  ├─ 📄SMPM_CurrentSource.svg
│  │  │  │  │  │  ├─ 📄SMPM_Inverter.svg
│  │  │  │  │  │  ├─ 📄SMPM_NoLoad.svg
│  │  │  │  │  │  ├─ 📄SMPM_ResistiveBraking.svg
│  │  │  │  │  │  ├─ 📄SMPM_VoltageSource.svg
│  │  │  │  │  │  ├─ 📄SMR_DOL.svg
│  │  │  │  │  │  ├─ 📄SMR_Inverter.svg
│  │  │  │  │  │  ├─ 📄SM_ElectricalExcited.svg
│  │  │  │  │  │  ├─ 📄SM_ElectricalExcitedData.svg
│  │  │  │  │  │  ├─ 📄SM_PermanentMagnet.svg
│  │  │  │  │  │  ├─ 📄SM_PermanentMagnetData.svg
│  │  │  │  │  │  ├─ 📄SM_ReluctanceRotor.svg
│  │  │  │  │  │  ├─ 📄SM_ReluctanceRotorData.svg
│  │  │  │  │  │  ├─ 📄SoftStartControl.svg
│  │  │  │  │  │  ├─ 📄SoftStarter.svg
│  │  │  │  │  │  ├─ 📄SoftStarterModeOfOperation.svg
│  │  │  │  │  │  ├─ 📄Source.svg
│  │  │  │  │  │  ├─ 📄Sources.svg
│  │  │  │  │  │  ├─ 📄SpacePhasor.svg
│  │  │  │  │  │  ├─ 📄SpacePhasors.svg
│  │  │  │  │  │  ├─ 📄SpeedControlledDCPM.svg
│  │  │  │  │  │  ├─ 📄Spice3.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkDifferentialPair.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkFourBitBinaryAdder.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkMosfetCharacterization.svg
│  │  │  │  │  │  ├─ 📄Spice3BenchmarkRtlInverter.svg
│  │  │  │  │  │  ├─ 📄SpiceConstants.svg
│  │  │  │  │  │  ├─ 📄Spicenetlist.svg
│  │  │  │  │  │  ├─ 📄SpiceRoot.svg
│  │  │  │  │  │  ├─ 📄SplitToSubsystems.svg
│  │  │  │  │  │  ├─ 📄SquirrelCage.svg
│  │  │  │  │  │  ├─ 📄Stack.svg
│  │  │  │  │  │  ├─ 📄StackBus.svg
│  │  │  │  │  │  ├─ 📄StackBusArrays.svg
│  │  │  │  │  │  ├─ 📄StackData.svg
│  │  │  │  │  │  ├─ 📄StackRC.svg
│  │  │  │  │  │  ├─ 📄Star.svg
│  │  │  │  │  │  ├─ 📄Step.svg
│  │  │  │  │  │  ├─ 📄StepCurrent.svg
│  │  │  │  │  │  ├─ 📄StepVoltage.svg
│  │  │  │  │  │  ├─ 📄StrayLoad.svg
│  │  │  │  │  │  ├─ 📄StrayLoadParameters.svg
│  │  │  │  │  │  ├─ 📄Strength.svg
│  │  │  │  │  │  ├─ 📄Subtracter.svg
│  │  │  │  │  │  ├─ 📄SuperCap.svg
│  │  │  │  │  │  ├─ 📄SuperCapDischargeCharge.svg
│  │  │  │  │  │  ├─ 📄SupplyVoltage.svg
│  │  │  │  │  │  ├─ 📄SVPWM.svg
│  │  │  │  │  │  ├─ 📄SwitchedCapacitor.svg
│  │  │  │  │  │  ├─ 📄SwitchedRheostat.svg
│  │  │  │  │  │  ├─ 📄SwitchingDcDc.svg
│  │  │  │  │  │  ├─ 📄SwitchWithArc.svg
│  │  │  │  │  │  ├─ 📄SwitchYD.svg
│  │  │  │  │  │  ├─ 📄SwitchYDwithArc.svg
│  │  │  │  │  │  ├─ 📄SymmetricalComponents.svg
│  │  │  │  │  │  ├─ 📄symmetricBackTransformationMatrix.svg
│  │  │  │  │  │  ├─ 📄symmetricOrientation.svg
│  │  │  │  │  │  ├─ 📄symmetricOrientationMatrix.svg
│  │  │  │  │  │  ├─ 📄symmetricTransformationMatrix.svg
│  │  │  │  │  │  ├─ 📄SynchronousMachineData.svg
│  │  │  │  │  │  ├─ 📄SynchronousMachines.svg
│  │  │  │  │  │  ├─ 📄Table.svg
│  │  │  │  │  │  ├─ 📄TableCurrent.svg
│  │  │  │  │  │  ├─ 📄Tables.svg
│  │  │  │  │  │  ├─ 📄TableVoltage.svg
│  │  │  │  │  │  ├─ 📄TerminalBox.svg
│  │  │  │  │  │  ├─ 📄TestSensors.svg
│  │  │  │  │  │  ├─ 📄Thermal.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCCE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCEE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCPM.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientDCSE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientIMC.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientIMS.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMEE.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMPM.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientSMR.svg
│  │  │  │  │  │  ├─ 📄ThermalAmbientTransformer.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCCE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCEE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCPM.svg
│  │  │  │  │  │  ├─ 📄ThermalPortDCSE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortIMC.svg
│  │  │  │  │  │  ├─ 📄ThermalPortIMS.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMEE.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMPM.svg
│  │  │  │  │  │  ├─ 📄ThermalPortSMR.svg
│  │  │  │  │  │  ├─ 📄ThermalPortTransformer.svg
│  │  │  │  │  │  ├─ 📄ThreePhaseTwoLevel_PWM.svg
│  │  │  │  │  │  ├─ 📄Thyristor.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.svg
│  │  │  │  │  │  ├─ 📄Thyristor1Pulse_R_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorBehaviourTest.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.svg
│  │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.svg
│  │  │  │  │  │  ├─ 📄TLine1.svg
│  │  │  │  │  │  ├─ 📄TLine2.svg
│  │  │  │  │  │  ├─ 📄TLine3.svg
│  │  │  │  │  │  ├─ 📄ToDQ.svg
│  │  │  │  │  │  ├─ 📄ToPolar.svg
│  │  │  │  │  │  ├─ 📄ToSpacePhasor.svg
│  │  │  │  │  │  ├─ 📄Transformer.svg
│  │  │  │  │  │  ├─ 📄TransformerData.svg
│  │  │  │  │  │  ├─ 📄Transformers.svg
│  │  │  │  │  │  ├─ 📄TransformerTestbench.svg
│  │  │  │  │  │  ├─ 📄TransformerYD.svg
│  │  │  │  │  │  ├─ 📄TransformerYY.svg
│  │  │  │  │  │  ├─ 📄TransientCellRecord.svg
│  │  │  │  │  │  ├─ 📄TransientData.svg
│  │  │  │  │  │  ├─ 📄TransientMachine.svg
│  │  │  │  │  │  ├─ 📄TransientModel.svg
│  │  │  │  │  │  ├─ 📄TransientRecordsPackage.svg
│  │  │  │  │  │  ├─ 📄TransientStackRecord.svg
│  │  │  │  │  │  ├─ 📄TransientTransformer.svg
│  │  │  │  │  │  ├─ 📄Transistor.svg
│  │  │  │  │  │  ├─ 📄TranslationalEMF.svg
│  │  │  │  │  │  ├─ 📄TransportDelay.svg
│  │  │  │  │  │  ├─ 📄TrapezoidCurrent.svg
│  │  │  │  │  │  ├─ 📄TrapezoidVoltage.svg
│  │  │  │  │  │  ├─ 📄Tristates.svg
│  │  │  │  │  │  ├─ 📄TWOBIT.svg
│  │  │  │  │  │  ├─ 📄TwoPin.svg
│  │  │  │  │  │  ├─ 📄TwoPinElementary.svg
│  │  │  │  │  │  ├─ 📄TwoPlug.svg
│  │  │  │  │  │  ├─ 📄TwoPlugElementary.svg
│  │  │  │  │  │  ├─ 📄TwoPort.svg
│  │  │  │  │  │  ├─ 📄TwoPortControlledSources.svg
│  │  │  │  │  │  ├─ 📄Types.svg
│  │  │  │  │  │  ├─ 📄ULine.svg
│  │  │  │  │  │  ├─ 📄UnsymmetricalLoad.svg
│  │  │  │  │  │  ├─ 📄useInitialConditions.svg
│  │  │  │  │  │  ├─ 📄Useofsemiconductors.svg
│  │  │  │  │  │  ├─ 📄UsersGuide.svg
│  │  │  │  │  │  ├─ 📄Utilities.svg
│  │  │  │  │  │  ├─ 📄UX01.svg
│  │  │  │  │  │  ├─ 📄VariableAdmittance.svg
│  │  │  │  │  │  ├─ 📄VariableCapacitor.svg
│  │  │  │  │  │  ├─ 📄VariableConductor.svg
│  │  │  │  │  │  ├─ 📄VariableCurrentSource.svg
│  │  │  │  │  │  ├─ 📄VariableImpedance.svg
│  │  │  │  │  │  ├─ 📄VariableInductor.svg
│  │  │  │  │  │  ├─ 📄VariableResistor.svg
│  │  │  │  │  │  ├─ 📄VariableVoltageSource.svg
│  │  │  │  │  │  ├─ 📄VCC.svg
│  │  │  │  │  │  ├─ 📄VCV.svg
│  │  │  │  │  │  ├─ 📄VectorDelay.svg
│  │  │  │  │  │  ├─ 📄VfController.svg
│  │  │  │  │  │  ├─ 📄Voltage2AngleType.svg
│  │  │  │  │  │  ├─ 📄Voltage2DutyCycle.svg
│  │  │  │  │  │  ├─ 📄VoltageBridge2mPulse.svg
│  │  │  │  │  │  ├─ 📄VoltageBridge2Pulse.svg
│  │  │  │  │  │  ├─ 📄VoltageCenterTap2mPulse.svg
│  │  │  │  │  │  ├─ 📄VoltageFollower.svg
│  │  │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.svg
│  │  │  │  │  │  ├─ 📄VoltageSensor.svg
│  │  │  │  │  │  ├─ 📄VoltageSource.svg
│  │  │  │  │  │  ├─ 📄VoltageSquare.svg
│  │  │  │  │  │  ├─ 📄VoltageToAngle.svg
│  │  │  │  │  │  ├─ 📄V_constant.svg
│  │  │  │  │  │  ├─ 📄V_exp.svg
│  │  │  │  │  │  ├─ 📄V_pulse.svg
│  │  │  │  │  │  ├─ 📄V_pwl.svg
│  │  │  │  │  │  ├─ 📄V_sffm.svg
│  │  │  │  │  │  ├─ 📄V_sin.svg
│  │  │  │  │  │  ├─ 📄WiredX.svg
│  │  │  │  │  │  ├─ 📄Xnor.svg
│  │  │  │  │  │  ├─ 📄XnorGate.svg
│  │  │  │  │  │  ├─ 📄Xor.svg
│  │  │  │  │  │  ├─ 📄XorGate.svg
│  │  │  │  │  │  ├─ 📄Yd.svg
│  │  │  │  │  │  ├─ 📄Yd01.svg
│  │  │  │  │  │  ├─ 📄Yd03.svg
│  │  │  │  │  │  ├─ 📄Yd05.svg
│  │  │  │  │  │  ├─ 📄Yd07.svg
│  │  │  │  │  │  ├─ 📄Yd09.svg
│  │  │  │  │  │  ├─ 📄Yd11.svg
│  │  │  │  │  │  ├─ 📄Yy.svg
│  │  │  │  │  │  ├─ 📄Yy00.svg
│  │  │  │  │  │  ├─ 📄Yy02.svg
│  │  │  │  │  │  ├─ 📄Yy04.svg
│  │  │  │  │  │  ├─ 📄Yy06.svg
│  │  │  │  │  │  ├─ 📄Yy08.svg
│  │  │  │  │  │  ├─ 📄Yy10.svg
│  │  │  │  │  │  ├─ 📄Yz.svg
│  │  │  │  │  │  ├─ 📄Yz01.svg
│  │  │  │  │  │  ├─ 📄Yz03.svg
│  │  │  │  │  │  ├─ 📄Yz05.svg
│  │  │  │  │  │  ├─ 📄Yz07.svg
│  │  │  │  │  │  ├─ 📄Yz09.svg
│  │  │  │  │  │  ├─ 📄Yz11.svg
│  │  │  │  │  │  ├─ 📄ZDiode.svg
│  │  │  │  │  │  └─ 📄ZeroInductor.svg
│  │  │  │  │  └─ 📄.gitkeep
│  │  │  │  └─ 📁component_source
│  │  │  │     ├─ 📁Blocks
│  │  │  │     │  ├─ 📄Continuous.mo
│  │  │  │     │  ├─ 📄Discrete.mo
│  │  │  │     │  ├─ 📄Icons.mo
│  │  │  │     │  ├─ 📄Interaction.mo
│  │  │  │     │  ├─ 📄Interfaces.mo
│  │  │  │     │  ├─ 📄Logical.mo
│  │  │  │     │  ├─ 📄Math.mo
│  │  │  │     │  ├─ 📄MathBoolean.mo
│  │  │  │     │  ├─ 📄MathInteger.mo
│  │  │  │     │  ├─ 📄Noise.mo
│  │  │  │     │  ├─ 📄Nonlinear.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  ├─ 📄Routing.mo
│  │  │  │     │  ├─ 📄Sources.mo
│  │  │  │     │  ├─ 📄Tables.mo
│  │  │  │     │  └─ 📄Types.mo
│  │  │  │     ├─ 📁Electrical
│  │  │  │     │  ├─ 📁Analog
│  │  │  │     │  │  ├─ 📁Basic
│  │  │  │     │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  ├─ 📄CCC.mo
│  │  │  │     │  │  │  ├─ 📄CCV.mo
│  │  │  │     │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralCurrentToVoltageAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralVoltageToCurrentAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄Ground.mo
│  │  │  │     │  │  │  ├─ 📄Gyrator.mo
│  │  │  │     │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  ├─ 📄M_Transformer.mo
│  │  │  │     │  │  │  ├─ 📄OpAmp.mo
│  │  │  │     │  │  │  ├─ 📄OpAmpDetailed.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Potentiometer.mo
│  │  │  │     │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  ├─ 📄RotationalEMF.mo
│  │  │  │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │  │  │     │  │  │  ├─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📄TranslationalEMF.mo
│  │  │  │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📄VCC.mo
│  │  │  │     │  │  │  └─ 📄VCV.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  ├─ 📄AD_Converter.mo
│  │  │  │     │  │  │  ├─ 📄CloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄ControlledCloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledIdealTwoWaySwitch.mo
│  │  │  │     │  │  │  ├─ 📄ControlledOpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄DA_Converter.mo
│  │  │  │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealDiode.mo
│  │  │  │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealizedOpAmpLimited.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmp.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmp3Pin.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpAmpLimited.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  ├─ 📄IdealTriac.mo
│  │  │  │     │  │  │  ├─ 📄IdealTwoWaySwitch.mo
│  │  │  │     │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  ├─ 📄FourPin.mo
│  │  │  │     │  │  │  ├─ 📄IdealSemiconductor.mo
│  │  │  │     │  │  │  ├─ 📄IdealSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealSwitchWithArc.mo
│  │  │  │     │  │  │  ├─ 📄NegativePin.mo
│  │  │  │     │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄Pin.mo
│  │  │  │     │  │  │  ├─ 📄PositivePin.mo
│  │  │  │     │  │  │  ├─ 📄RelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄TwoPin.mo
│  │  │  │     │  │  │  ├─ 📄TwoPort.mo
│  │  │  │     │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  ├─ 📁Lines
│  │  │  │     │  │  │  ├─ 📄M_OLine.mo
│  │  │  │     │  │  │  ├─ 📄OLine.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄TLine1.mo
│  │  │  │     │  │  │  ├─ 📄TLine2.mo
│  │  │  │     │  │  │  ├─ 📄TLine3.mo
│  │  │  │     │  │  │  └─ 📄ULine.mo
│  │  │  │     │  │  ├─ 📁Semiconductors
│  │  │  │     │  │  │  ├─ 📄Diode.mo
│  │  │  │     │  │  │  ├─ 📄Diode2.mo
│  │  │  │     │  │  │  ├─ 📄NMOS.mo
│  │  │  │     │  │  │  ├─ 📄NPN.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PMOS.mo
│  │  │  │     │  │  │  ├─ 📄PNP.mo
│  │  │  │     │  │  │  ├─ 📄SimpleTriac.mo
│  │  │  │     │  │  │  ├─ 📄Thyristor.mo
│  │  │  │     │  │  │  └─ 📄ZDiode.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrentVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltageVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄ExponentialsCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ExponentialsVoltage.mo
│  │  │  │     │  │  │  ├─ 📄ExpSineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ExpSineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PulseCurrent.mo
│  │  │  │     │  │  │  ├─ 📄PulseVoltage.mo
│  │  │  │     │  │  │  ├─ 📄RampCurrent.mo
│  │  │  │     │  │  │  ├─ 📄RampVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SawToothCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SawToothVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SignalCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SignalVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrentVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄SineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineVoltageVariableFrequencyAndAmplitude.mo
│  │  │  │     │  │  │  ├─ 📄StepCurrent.mo
│  │  │  │     │  │  │  ├─ 📄StepVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SupplyVoltage.mo
│  │  │  │     │  │  │  ├─ 📄TableCurrent.mo
│  │  │  │     │  │  │  ├─ 📄TableVoltage.mo
│  │  │  │     │  │  │  ├─ 📄TrapezoidCurrent.mo
│  │  │  │     │  │  │  └─ 📄TrapezoidVoltage.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Batteries
│  │  │  │     │  │  ├─ 📁BaseClasses
│  │  │  │     │  │  │  ├─ 📄BaseCellStack.mo
│  │  │  │     │  │  │  ├─ 📄BaseCellWithSensors.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackData.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackWithSensors.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁BatteryStacks
│  │  │  │     │  │  │  ├─ 📄CellRCStack.mo
│  │  │  │     │  │  │  ├─ 📄CellStack.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄SuperCap.mo
│  │  │  │     │  │  ├─ 📁BatteryStacksWithSensors
│  │  │  │     │  │  │  ├─ 📄Cell.mo
│  │  │  │     │  │  │  ├─ 📄CellRC.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Stack.mo
│  │  │  │     │  │  │  └─ 📄StackRC.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄BaseCellRecord.mo
│  │  │  │     │  │  │  ├─ 📄BaseStackRecord.mo
│  │  │  │     │  │  │  ├─ 📄BatteryIcon.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄TransientCellRecord.mo
│  │  │  │     │  │  │  ├─ 📄TransientModel.mo
│  │  │  │     │  │  │  ├─ 📄TransientRecordsPackage.mo
│  │  │  │     │  │  │  └─ 📄TransientStackRecord.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄CellBus.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄StackBus.mo
│  │  │  │     │  │  │  └─ 📄StackBusArrays.mo
│  │  │  │     │  │  ├─ 📁ParameterRecords
│  │  │  │     │  │  │  ├─ 📁TransientData
│  │  │  │     │  │  │  │  ├─ 📄CellData.mo
│  │  │  │     │  │  │  │  ├─ 📄ExampleData.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄RCData.mo
│  │  │  │     │  │  │  │  └─ 📄StackData.mo
│  │  │  │     │  │  │  ├─ 📄CellData.mo
│  │  │  │     │  │  │  ├─ 📄ExampleData.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄StackData.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Concept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Parameterization.mo
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  ├─ 📄BusTranscription.mo
│  │  │  │     │  │  │  ├─ 📄CCCVcharger.mo
│  │  │  │     │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄PulseSeries.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Machines
│  │  │  │     │  │  ├─ 📁BasicMachines
│  │  │  │     │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  ├─ 📄AirGapDC.mo
│  │  │  │     │  │  │  │  ├─ 📄AirGapR.mo
│  │  │  │     │  │  │  │  ├─ 📄AirGapS.mo
│  │  │  │     │  │  │  │  ├─ 📄CompoundDCExcitation.mo
│  │  │  │     │  │  │  │  ├─ 📄DamperCage.mo
│  │  │  │     │  │  │  │  ├─ 📄ElectricalExcitation.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCore.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄InductorDC.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialAirGap.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialAirGapDC.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCore.mo
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnetWithLosses.mo
│  │  │  │     │  │  │  │  └─ 📄SquirrelCage.mo
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄IM_SlipRing.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SquirrelCage.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁QuasiStaticDCMachines
│  │  │  │     │  │  │  │  ├─ 📄DC_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_PermanentMagnet.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_SeriesExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SM_ElectricalExcited.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_PermanentMagnet.mo
│  │  │  │     │  │  │  │  └─ 📄SM_ReluctanceRotor.mo
│  │  │  │     │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  ├─ 📁Dd
│  │  │  │     │  │  │  │  │  ├─ 📄Dd00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd08.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dd10.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Dy
│  │  │  │     │  │  │  │  │  ├─ 📄Dy01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy09.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dy11.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Dz
│  │  │  │     │  │  │  │  │  ├─ 📄Dz00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz08.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Dz10.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁Yd
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yd01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yd09.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yd11.mo
│  │  │  │     │  │  │  │  ├─ 📁Yy
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yy00.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy02.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy04.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy06.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yy08.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yy10.mo
│  │  │  │     │  │  │  │  ├─ 📁Yz
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Yz01.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz03.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz05.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz07.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Yz09.mo
│  │  │  │     │  │  │  │  │  └─ 📄Yz11.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁ControlledDCDrives
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄Battery.mo
│  │  │  │     │  │  │  │  │  ├─ 📄DcdcInverter.mo
│  │  │  │     │  │  │  │  │  ├─ 📄DriveDataDCPM.mo
│  │  │  │     │  │  │  │  │  ├─ 📄IdealDcDc.mo
│  │  │  │     │  │  │  │  │  ├─ 📄LimitedPI.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄PartialControlledDCPM.mo
│  │  │  │     │  │  │  │  │  └─ 📄SwitchingDcDc.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentControlledDCPM.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PositionControlledDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄SpeedControlledDCPM.mo
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄DCEE_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Cooling.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_CurrentControlled.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_QuasiStatic.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_Temperature.mo
│  │  │  │     │  │  │  │  ├─ 📄DCPM_withLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄DCSE_SinglePhase.mo
│  │  │  │     │  │  │  │  ├─ 📄DCSE_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄DC_CompareCharacteristics.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄IMC_Conveyor.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_DCBraking.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_DOL.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Initialize.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Inverter.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_InverterDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Steinmetz.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_withLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_YD.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_YDarc.mo
│  │  │  │     │  │  │  │  ├─ 📄IMS_Start.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SMEE_DOL.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_Generator.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_LoadDump.mo
│  │  │  │     │  │  │  │  ├─ 📄SMEE_Rectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_Braking.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_Inverter.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_NoLoad.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_ResistiveBraking.mo
│  │  │  │     │  │  │  │  ├─ 📄SMPM_VoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄SMR_DOL.mo
│  │  │  │     │  │  │  │  └─ 📄SMR_Inverter.mo
│  │  │  │     │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  ├─ 📄AsymmetricalLoad.mo
│  │  │  │     │  │  │  │  ├─ 📄IMC_Transformer.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Rectifier12pulse.mo
│  │  │  │     │  │  │  │  ├─ 📄Rectifier6pulse.mo
│  │  │  │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Drive.mo
│  │  │  │     │  │  │  ├─ 📄FundamentalWaveMachine.mo
│  │  │  │     │  │  │  ├─ 📄Machine.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄QuasiStaticFundamentalWaveMachine.mo
│  │  │  │     │  │  │  ├─ 📄QuasiStaticMachine.mo
│  │  │  │     │  │  │  ├─ 📄QuasiStaticTransformer.mo
│  │  │  │     │  │  │  ├─ 📄TransientMachine.mo
│  │  │  │     │  │  │  └─ 📄TransientTransformer.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialPowerBalanceDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalAmbientDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalPortDCMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCPM.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceDCSE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalPortDCSE.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialPowerBalanceInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalAmbientInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialThermalPortInductionMachines.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceIMC.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceIMS.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMPM.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerBalanceSMR.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortIMC.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortIMS.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalPortSMPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalPortSMR.mo
│  │  │  │     │  │  │  ├─ 📄FlangeSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialBasicDCMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicInductionMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicMachine.mo
│  │  │  │     │  │  │  ├─ 📄PartialBasicTransformer.mo
│  │  │  │     │  │  │  ├─ 📄PowerBalanceTransformer.mo
│  │  │  │     │  │  │  ├─ 📄SpacePhasor.mo
│  │  │  │     │  │  │  └─ 📄ThermalPortTransformer.mo
│  │  │  │     │  │  ├─ 📁Losses
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄Brush.mo
│  │  │  │     │  │  │  │  ├─ 📄brushVoltageDrop.mo
│  │  │  │     │  │  │  │  ├─ 📄Core.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄StrayLoad.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄Brush.mo
│  │  │  │     │  │  │  │  ├─ 📄Core.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PermanentMagnetLosses.mo
│  │  │  │     │  │  │  │  └─ 📄StrayLoad.mo
│  │  │  │     │  │  │  ├─ 📄BrushParameters.mo
│  │  │  │     │  │  │  ├─ 📄CoreParameters.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄FrictionParameters.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PermanentMagnetLossParameters.mo
│  │  │  │     │  │  │  └─ 📄StrayLoadParameters.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  ├─ 📄ElectricalPowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄HallSensor.mo
│  │  │  │     │  │  │  ├─ 📄MechanicalPowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RotorDisplacementAngle.mo
│  │  │  │     │  │  │  ├─ 📄SinCosResolver.mo
│  │  │  │     │  │  │  └─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  ├─ 📁SpacePhasors
│  │  │  │     │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  ├─ 📄FromPolar.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄LessThreshold.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  ├─ 📄ToPolar.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  └─ 📄SpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Functions
│  │  │  │     │  │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  │  ├─ 📄FromPolar.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄quasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄Rotator.mo
│  │  │  │     │  │  │  │  ├─ 📄ToPolar.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Thermal
│  │  │  │     │  │  │  ├─ 📁Constants
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCCE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientDCPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientDCSE.mo
│  │  │  │     │  │  │  ├─ 📁InductionMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientIMC.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientIMS.mo
│  │  │  │     │  │  │  ├─ 📁SynchronousMachines
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientSMEE.mo
│  │  │  │     │  │  │  │  ├─ 📄ThermalAmbientSMPM.mo
│  │  │  │     │  │  │  │  └─ 📄ThermalAmbientSMR.mo
│  │  │  │     │  │  │  ├─ 📄convertAlpha.mo
│  │  │  │     │  │  │  ├─ 📄convertResistance.mo
│  │  │  │     │  │  │  ├─ 📄LinearTemperatureCoefficient20.mo
│  │  │  │     │  │  │  ├─ 📄linearTemperatureDependency.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄ThermalAmbientTransformer.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Concept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Discrimination.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  ├─ 📁ParameterRecords
│  │  │  │     │  │  │  │  ├─ 📄DcElectricalExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄DcPermanentMagnetData.mo
│  │  │  │     │  │  │  │  ├─ 📄DcSeriesExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SlipRingData.mo
│  │  │  │     │  │  │  │  ├─ 📄IM_SquirrelCageData.mo
│  │  │  │     │  │  │  │  ├─ 📄InductionMachineData.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SM_ElectricalExcitedData.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_PermanentMagnetData.mo
│  │  │  │     │  │  │  │  ├─ 📄SM_ReluctanceRotorData.mo
│  │  │  │     │  │  │  │  └─ 📄TransformerData.mo
│  │  │  │     │  │  │  ├─ 📄DcBrakeSettings.mo
│  │  │  │     │  │  │  ├─ 📄DQCurrentController.mo
│  │  │  │     │  │  │  ├─ 📄DQToThreePhase.mo
│  │  │  │     │  │  │  ├─ 📄FromDQ.mo
│  │  │  │     │  │  │  ├─ 📄MultiTerminalBox.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RampedRheostat.mo
│  │  │  │     │  │  │  ├─ 📄SinCosEvaluation.mo
│  │  │  │     │  │  │  ├─ 📄SwitchedRheostat.mo
│  │  │  │     │  │  │  ├─ 📄SwitchYD.mo
│  │  │  │     │  │  │  ├─ 📄SwitchYDwithArc.mo
│  │  │  │     │  │  │  ├─ 📄SynchronousMachineData.mo
│  │  │  │     │  │  │  ├─ 📄TerminalBox.mo
│  │  │  │     │  │  │  ├─ 📄ToDQ.mo
│  │  │  │     │  │  │  ├─ 📄TransformerData.mo
│  │  │  │     │  │  │  └─ 📄VfController.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Polyphase
│  │  │  │     │  │  ├─ 📁Basic
│  │  │  │     │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  ├─ 📄Delta.mo
│  │  │  │     │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  ├─ 📄MultiDelta.mo
│  │  │  │     │  │  │  ├─ 📄MultiStar.mo
│  │  │  │     │  │  │  ├─ 📄MultiStarResistance.mo
│  │  │  │     │  │  │  ├─ 📄MutualInductor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PlugToPins_n.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPins_p.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPin_n.mo
│  │  │  │     │  │  │  ├─ 📄PlugToPin_p.mo
│  │  │  │     │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  ├─ 📄SaturatingInductor.mo
│  │  │  │     │  │  │  ├─ 📄SplitToSubsystems.mo
│  │  │  │     │  │  │  ├─ 📄Star.mo
│  │  │  │     │  │  │  ├─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  ├─ 📄VariableResistor.mo
│  │  │  │     │  │  │  └─ 📄ZeroInductor.mo
│  │  │  │     │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄QuasiRMS.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄AnalysatorAC.mo
│  │  │  │     │  │  │  │  ├─ 📄AnalysatorDC.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄PolyphaseRectifierData.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PolyphaseRectifier.mo
│  │  │  │     │  │  │  ├─ 📄Rectifier.mo
│  │  │  │     │  │  │  ├─ 📄TestSensors.mo
│  │  │  │     │  │  │  ├─ 📄TransformerYD.mo
│  │  │  │     │  │  │  └─ 📄TransformerYY.mo
│  │  │  │     │  │  ├─ 📁Functions
│  │  │  │     │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  ├─ 📄factorY2D.mo
│  │  │  │     │  │  │  ├─ 📄factorY2DC.mo
│  │  │  │     │  │  │  ├─ 📄indexNonPositiveSequence.mo
│  │  │  │     │  │  │  ├─ 📄indexPositiveSequence.mo
│  │  │  │     │  │  │  ├─ 📄numberOfSymmetricBaseSystems.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄quasiRMS.mo
│  │  │  │     │  │  │  ├─ 📄symmetricBackTransformationMatrix.mo
│  │  │  │     │  │  │  ├─ 📄symmetricOrientation.mo
│  │  │  │     │  │  │  ├─ 📄symmetricOrientationMatrix.mo
│  │  │  │     │  │  │  └─ 📄symmetricTransformationMatrix.mo
│  │  │  │     │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  ├─ 📄CloserWithArc.mo
│  │  │  │     │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealDiode.mo
│  │  │  │     │  │  │  ├─ 📄IdealGTOThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  ├─ 📄IdealThyristor.mo
│  │  │  │     │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  ├─ 📄OpenerWithArc.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄ConditionalHeatPort.mo
│  │  │  │     │  │  │  ├─ 📄FourPlug.mo
│  │  │  │     │  │  │  ├─ 📄NegativePlug.mo
│  │  │  │     │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Plug.mo
│  │  │  │     │  │  │  ├─ 📄PositivePlug.mo
│  │  │  │     │  │  │  ├─ 📄TwoPlug.mo
│  │  │  │     │  │  │  └─ 📄TwoPort.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AronSensor.mo
│  │  │  │     │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄ConstantCurrent.mo
│  │  │  │     │  │  │  ├─ 📄ConstantVoltage.mo
│  │  │  │     │  │  │  ├─ 📄CosineCurrent.mo
│  │  │  │     │  │  │  ├─ 📄CosineVoltage.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄SignalCurrent.mo
│  │  │  │     │  │  │  ├─ 📄SignalVoltage.mo
│  │  │  │     │  │  │  ├─ 📄SineCurrent.mo
│  │  │  │     │  │  │  └─ 📄SineVoltage.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PhaseOrientation.mo
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁PowerConverters
│  │  │  │     │  │  ├─ 📁ACAC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SoftStartControl.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageToAngle.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PolyphaseTriac.mo
│  │  │  │     │  │  │  └─ 📄SinglePhaseTriac.mo
│  │  │  │     │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄Filter.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Signal2mPulse.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageBridge2mPulse.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageBridge2Pulse.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │  │  │     │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │  │  │     │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │  │  │     │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │  │  │     │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄IntersectivePWM.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PWM.mo
│  │  │  │     │  │  │  │  └─ 📄SVPWM.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Polyphase2Level.mo
│  │  │  │     │  │  │  └─ 📄SinglePhase2Level.mo
│  │  │  │     │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  ├─ 📁Control
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄SignalPWM.mo
│  │  │  │     │  │  │  │  └─ 📄Voltage2DutyCycle.mo
│  │  │  │     │  │  │  ├─ 📄ChopperStepDown.mo
│  │  │  │     │  │  │  ├─ 📄ChopperStepUp.mo
│  │  │  │     │  │  │  ├─ 📄HBridge.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Enable
│  │  │  │     │  │  │  ├─ 📄EnableLogic.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁ACAC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄Dimmer.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Dimmer_R.mo
│  │  │  │     │  │  │  │  ├─ 📄Dimmer_RL.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄SoftStarter.mo
│  │  │  │     │  │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Thyristor1Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse.mo
│  │  │  │     │  │  │  │  ├─ 📁Rectifier1Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄Thyristor1Pulse_R.mo
│  │  │  │     │  │  │  │  │  └─ 📄Thyristor1Pulse_R_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierBridge2mPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HalfControlledBridge2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2mPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorBridge2mPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierBridge2Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HalfControlledBridge2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorBridge2Pulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorBridge2Pulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTap2mPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTap2mPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2mPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTap2mPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTap2Pulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTap2Pulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTap2Pulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTap2Pulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📁RectifierCenterTapmPulse
│  │  │  │     │  │  │  │  │  ├─ 📄DiodeCenterTapmPulse.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ThyristorCenterTapmPulse_RLV.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThyristorCenterTapmPulse_RLV_Characteristic.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel.mo
│  │  │  │     │  │  │  │  ├─ 📁PolyphaseTwoLevel
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄PolyphaseTwoLevel_RL.mo
│  │  │  │     │  │  │  │  │  └─ 📄ThreePhaseTwoLevel_PWM.mo
│  │  │  │     │  │  │  │  ├─ 📁SinglePhaseTwoLevel
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄SinglePhaseTwoLevel_R.mo
│  │  │  │     │  │  │  │  │  └─ 📄SinglePhaseTwoLevel_RL.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  │  ├─ 📁ChopperStepDown
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁ChopperStepUp
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepUp_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁ExampleTemplates
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepDown.mo
│  │  │  │     │  │  │  │  │  ├─ 📄ChopperStepUp.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📁HBridge
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_DC_Drive.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_R.mo
│  │  │  │     │  │  │  │  │  ├─ 📄HBridge_RL.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Control.mo
│  │  │  │     │  │  │  ├─ 📄Converter.mo
│  │  │  │     │  │  │  ├─ 📄ExampleTemplate.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📁ACDC
│  │  │  │     │  │  │  │  ├─ 📄ACplug.mo
│  │  │  │     │  │  │  │  ├─ 📄ACtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄ACtwoPlug.mo
│  │  │  │     │  │  │  │  ├─ 📄DCpin.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCAC
│  │  │  │     │  │  │  │  ├─ 📄ACpin.mo
│  │  │  │     │  │  │  │  ├─ 📄ACplug.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁DCDC
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin1.mo
│  │  │  │     │  │  │  │  ├─ 📄DCtwoPin2.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Enable
│  │  │  │     │  │  │  │  ├─ 📄Enable.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable1.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable1m.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable2.mo
│  │  │  │     │  │  │  │  ├─ 📄Enable2m.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PWMType.mo
│  │  │  │     │  │  │  ├─ 📄ReferenceType.mo
│  │  │  │     │  │  │  ├─ 📄SoftStarterModeOfOperation.mo
│  │  │  │     │  │  │  └─ 📄Voltage2AngleType.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄ACACConcept.mo
│  │  │  │     │  │  │  ├─ 📄ACDCConcept.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄DCACConcept.mo
│  │  │  │     │  │  │  ├─ 📄DCDCConcept.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁QuasiStatic
│  │  │  │     │  │  ├─ 📁Machines
│  │  │  │     │  │  │  ├─ 📁BasicMachines
│  │  │  │     │  │  │  │  ├─ 📁Components
│  │  │  │     │  │  │  │  │  ├─ 📄IdealCore.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄PartialCore.mo
│  │  │  │     │  │  │  │  ├─ 📁Transformers
│  │  │  │     │  │  │  │  │  ├─ 📁Dd
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd08.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dd10.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Dy
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy09.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dy11.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Dz
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz08.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Dz10.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📁Yd
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yd09.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yd11.mo
│  │  │  │     │  │  │  │  │  ├─ 📁Yy
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy00.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy02.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy04.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy06.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yy08.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yy10.mo
│  │  │  │     │  │  │  │  │  ├─ 📁Yz
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz01.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz03.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz05.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz07.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Yz09.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄Yz11.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄TransformerTestbench.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄PartialBasicTransformer.mo
│  │  │  │     │  │  │  ├─ 📁SpacePhasors
│  │  │  │     │  │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Polyphase
│  │  │  │     │  │  │  ├─ 📁Basic
│  │  │  │     │  │  │  │  ├─ 📄Admittance.mo
│  │  │  │     │  │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  │  ├─ 📄Delta.mo
│  │  │  │     │  │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiDelta.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiStar.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiStarResistance.mo
│  │  │  │     │  │  │  │  ├─ 📄MutualInductor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PlugToPins_n.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPins_p.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPin_n.mo
│  │  │  │     │  │  │  │  ├─ 📄PlugToPin_p.mo
│  │  │  │     │  │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  │  ├─ 📄Star.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  │  └─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📁Blocks
│  │  │  │     │  │  │  │  ├─ 📄FromSpacePhasor.mo
│  │  │  │     │  │  │  │  ├─ 📄FromSymmetricalComponents.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuasiRMS.mo
│  │  │  │     │  │  │  │  ├─ 📄SingleToPolyphase.mo
│  │  │  │     │  │  │  │  ├─ 📄SymmetricalComponents.mo
│  │  │  │     │  │  │  │  └─ 📄ToSpacePhasor.mo
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄BalancingDelta.mo
│  │  │  │     │  │  │  │  ├─ 📄BalancingStar.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄TestSensors.mo
│  │  │  │     │  │  │  │  └─ 📄UnsymmetricalLoad.mo
│  │  │  │     │  │  │  ├─ 📁Functions
│  │  │  │     │  │  │  │  ├─ 📄activePower.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄quasiRMS.mo
│  │  │  │     │  │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄NegativePlug.mo
│  │  │  │     │  │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Plug.mo
│  │  │  │     │  │  │  │  ├─ 📄PositivePlug.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSource.mo
│  │  │  │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │  │  │     │  │  │  │  ├─ 📄Source.mo
│  │  │  │     │  │  │  │  ├─ 📄TwoPlug.mo
│  │  │  │     │  │  │  │  └─ 📄TwoPlugElementary.mo
│  │  │  │     │  │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  │  ├─ 📄AronSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentQuasiRMSSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReactivePowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄VoltageQuasiRMSSensor.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  │  ├─ 📁Sources
│  │  │  │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ReferenceCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁SinglePhase
│  │  │  │     │  │  │  ├─ 📁Basic
│  │  │  │     │  │  │  │  ├─ 📄Admittance.mo
│  │  │  │     │  │  │  │  ├─ 📄Capacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄Conductor.mo
│  │  │  │     │  │  │  │  ├─ 📄Ground.mo
│  │  │  │     │  │  │  │  ├─ 📄Impedance.mo
│  │  │  │     │  │  │  │  ├─ 📄Inductor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Resistor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableAdmittance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableCapacitor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableConductor.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableImpedance.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableInductor.mo
│  │  │  │     │  │  │  │  └─ 📄VariableResistor.mo
│  │  │  │     │  │  │  ├─ 📁Examples
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄ParallelResonance.mo
│  │  │  │     │  │  │  │  ├─ 📄Rectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄SeriesBode.mo
│  │  │  │     │  │  │  │  ├─ 📄SeriesResonance.mo
│  │  │  │     │  │  │  │  └─ 📄Transformer.mo
│  │  │  │     │  │  │  ├─ 📁Ideal
│  │  │  │     │  │  │  │  ├─ 📄IdealClosingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealCommutingSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealIntermediateSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealOpeningSwitch.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealTransformer.mo
│  │  │  │     │  │  │  │  ├─ 📄Idle.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄Short.mo
│  │  │  │     │  │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄NegativePin.mo
│  │  │  │     │  │  │  │  ├─ 📄OnePort.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Pin.mo
│  │  │  │     │  │  │  │  ├─ 📄PositivePin.mo
│  │  │  │     │  │  │  │  ├─ 📄RelativeSensorElementary.mo
│  │  │  │     │  │  │  │  ├─ 📄Source.mo
│  │  │  │     │  │  │  │  ├─ 📄TwoPin.mo
│  │  │  │     │  │  │  │  └─ 📄TwoPinElementary.mo
│  │  │  │     │  │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  │  ├─ 📄CurrentSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySensor.mo
│  │  │  │     │  │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PotentialSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄ReferenceSensor.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSensor.mo
│  │  │  │     │  │  │  ├─ 📁Sources
│  │  │  │     │  │  │  │  ├─ 📄CurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄FrequencySweepVoltageSource.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄VariableCurrentSource.mo
│  │  │  │     │  │  │  │  ├─ 📄VariableVoltageSource.mo
│  │  │  │     │  │  │  │  └─ 📄VoltageSource.mo
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄GraetzRectifier.mo
│  │  │  │     │  │  │  │  ├─ 📄IdealACDCConverter.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Reference.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📁Overview
│  │  │  │     │  │  │  │  ├─ 📄ACCircuit.mo
│  │  │  │     │  │  │  │  ├─ 📄Introduction.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Power.mo
│  │  │  │     │  │  │  │  └─ 📄ReferenceSystem.mo
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Glossar.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  └─ 📄ReleaseNotes.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📄Digital.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  └─ 📄Spice3.mo
│  │  │  │     ├─ 📁Math
│  │  │  │     │  ├─ 📄BooleanVectors.mo
│  │  │  │     │  ├─ 📄Distributions.mo
│  │  │  │     │  ├─ 📄FastFourierTransform.mo
│  │  │  │     │  ├─ 📄isPowerOf2.mo
│  │  │  │     │  ├─ 📄Nonlinear.mo
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  ├─ 📄package.order
│  │  │  │     │  ├─ 📄Polynomials.mo
│  │  │  │     │  ├─ 📄Random.mo
│  │  │  │     │  ├─ 📄Special.mo
│  │  │  │     │  └─ 📄wrapAngle.mo
│  │  │  │     ├─ 📁Mechanics
│  │  │  │     │  ├─ 📁MultiBody
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Constraints
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PrismaticConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄RevoluteConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄SphericalConstraint.mo
│  │  │  │     │  │  │  │  └─ 📄UniversalConstraint.mo
│  │  │  │     │  │  │  ├─ 📁Elementary
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄sineSurface.mo
│  │  │  │     │  │  │  │  │  └─ 📄theoreticalNormalGravityWGS84.mo
│  │  │  │     │  │  │  │  ├─ 📄DoublePendulum.mo
│  │  │  │     │  │  │  │  ├─ 📄DoublePendulumInitTip.mo
│  │  │  │     │  │  │  │  ├─ 📄ForceAndTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄FreeBody.mo
│  │  │  │     │  │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  │  ├─ 📄InitSpringConstant.mo
│  │  │  │     │  │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Pendulum.mo
│  │  │  │     │  │  │  │  ├─ 📄PendulumWithSpringDamper.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravity.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravityWithPointMasses.mo
│  │  │  │     │  │  │  │  ├─ 📄PointGravityWithPointMasses2.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheelSetDriving.mo
│  │  │  │     │  │  │  │  ├─ 📄RollingWheelSetPulling.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamperSystem.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringMassSystem.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringWithMass.mo
│  │  │  │     │  │  │  │  ├─ 📄Surfaces.mo
│  │  │  │     │  │  │  │  ├─ 📄ThreeSprings.mo
│  │  │  │     │  │  │  │  └─ 📄UserDefinedGravityField.mo
│  │  │  │     │  │  │  ├─ 📁Loops
│  │  │  │     │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  ├─ 📄Cylinder.mo
│  │  │  │     │  │  │  │  │  ├─ 📄CylinderBase.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Cylinder_analytic_CAD.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Engine1Base.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Engine1bBase.mo
│  │  │  │     │  │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │  │  │     │  │  │  │  │  ├─ 📄GasForce2.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Engine1a.mo
│  │  │  │     │  │  │  │  ├─ 📄Engine1b.mo
│  │  │  │     │  │  │  │  ├─ 📄Engine1b_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄EngineV6.mo
│  │  │  │     │  │  │  │  ├─ 📄EngineV6_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar1.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar2.mo
│  │  │  │     │  │  │  │  ├─ 📄Fourbar_analytic.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PlanarFourbar.mo
│  │  │  │     │  │  │  │  └─ 📄PlanarLoops_analytic.mo
│  │  │  │     │  │  │  ├─ 📁Rotational3DEffects
│  │  │  │     │  │  │  │  ├─ 📄ActuatedDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄BevelGear1D.mo
│  │  │  │     │  │  │  │  ├─ 📄GearConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄GyroscopicEffects.mo
│  │  │  │     │  │  │  │  ├─ 📄MovingActuatedDrive.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Systems
│  │  │  │     │  │  │  │  ├─ 📁RobotR3
│  │  │  │     │  │  │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisControlBus.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisType1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄AxisType2.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄ControlBus.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Controller.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄GearType1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄GearType2.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄MechanicalStructure.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄Motor.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  │  ├─ 📄PathPlanning1.mo
│  │  │  │     │  │  │  │  │  │  ├─ 📄PathPlanning6.mo
│  │  │  │     │  │  │  │  │  │  └─ 📄PathToAxisControlBus.mo
│  │  │  │     │  │  │  │  │  ├─ 📄FullRobot.mo
│  │  │  │     │  │  │  │  │  ├─ 📄OneAxis.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Forces
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄BasicForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicWorldForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicWorldTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄standardGravityAcceleration.mo
│  │  │  │     │  │  │  │  └─ 📄ZeroForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄Force.mo
│  │  │  │     │  │  │  ├─ 📄ForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄LineForceWithMass.mo
│  │  │  │     │  │  │  ├─ 📄LineForceWithTwoMasses.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamperParallel.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamperSeries.mo
│  │  │  │     │  │  │  ├─ 📄Torque.mo
│  │  │  │     │  │  │  ├─ 📄WorldForce.mo
│  │  │  │     │  │  │  ├─ 📄WorldForceAndTorque.mo
│  │  │  │     │  │  │  └─ 📄WorldTorque.mo
│  │  │  │     │  │  ├─ 📁Frames
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent.mo
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent_d.mo
│  │  │  │     │  │  │  │  ├─ 📄maxWithoutEvent_dd.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄QuaternionBase.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1_der.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2_der.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveRelative_der.mo
│  │  │  │     │  │  │  │  └─ 📄TransformationMatrix.mo
│  │  │  │     │  │  │  ├─ 📁Quaternions
│  │  │  │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  │  └─ 📄to_T_inv.mo
│  │  │  │     │  │  │  ├─ 📁TransformationMatrices
│  │  │  │     │  │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  │  ├─ 📄axesRotations.mo
│  │  │  │     │  │  │  │  ├─ 📄axesRotationsAngles.mo
│  │  │  │     │  │  │  │  ├─ 📄axisRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄der_Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄from_nxy.mo
│  │  │  │     │  │  │  │  ├─ 📄from_nxz.mo
│  │  │  │     │  │  │  │  ├─ 📄from_Q.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄multipleResolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄planarRotationAngle.mo
│  │  │  │     │  │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveDyade1.mo
│  │  │  │     │  │  │  │  ├─ 📄resolveDyade2.mo
│  │  │  │     │  │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  │  ├─ 📄to_exy.mo
│  │  │  │     │  │  │  │  ├─ 📄to_Q.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  │  ├─ 📄to_T_inv.mo
│  │  │  │     │  │  │  │  └─ 📄to_vector.mo
│  │  │  │     │  │  │  ├─ 📄absoluteRotation.mo
│  │  │  │     │  │  │  ├─ 📄angularVelocity1.mo
│  │  │  │     │  │  │  ├─ 📄angularVelocity2.mo
│  │  │  │     │  │  │  ├─ 📄axesRotations.mo
│  │  │  │     │  │  │  ├─ 📄axesRotationsAngles.mo
│  │  │  │     │  │  │  ├─ 📄axis.mo
│  │  │  │     │  │  │  ├─ 📄axisRotation.mo
│  │  │  │     │  │  │  ├─ 📄from_nxy.mo
│  │  │  │     │  │  │  ├─ 📄from_nxz.mo
│  │  │  │     │  │  │  ├─ 📄from_Q.mo
│  │  │  │     │  │  │  ├─ 📄from_T.mo
│  │  │  │     │  │  │  ├─ 📄from_T2.mo
│  │  │  │     │  │  │  ├─ 📄from_T_inv.mo
│  │  │  │     │  │  │  ├─ 📄inverseRotation.mo
│  │  │  │     │  │  │  ├─ 📄nullRotation.mo
│  │  │  │     │  │  │  ├─ 📄Orientation.mo
│  │  │  │     │  │  │  ├─ 📄orientationConstraint.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄planarRotation.mo
│  │  │  │     │  │  │  ├─ 📄planarRotationAngle.mo
│  │  │  │     │  │  │  ├─ 📄relativeRotation.mo
│  │  │  │     │  │  │  ├─ 📄resolve1.mo
│  │  │  │     │  │  │  ├─ 📄resolve2.mo
│  │  │  │     │  │  │  ├─ 📄resolveDyade1.mo
│  │  │  │     │  │  │  ├─ 📄resolveDyade2.mo
│  │  │  │     │  │  │  ├─ 📄resolveRelative.mo
│  │  │  │     │  │  │  ├─ 📄smallRotation.mo
│  │  │  │     │  │  │  ├─ 📄to_exy.mo
│  │  │  │     │  │  │  ├─ 📄to_Q.mo
│  │  │  │     │  │  │  ├─ 📄to_T.mo
│  │  │  │     │  │  │  ├─ 📄to_T_inv.mo
│  │  │  │     │  │  │  └─ 📄to_vector.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  └─ 📄Surface.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄FlangeWithBearing.mo
│  │  │  │     │  │  │  ├─ 📄FlangeWithBearingAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄Frame.mo
│  │  │  │     │  │  │  ├─ 📄Frame_a.mo
│  │  │  │     │  │  │  ├─ 📄Frame_b.mo
│  │  │  │     │  │  │  ├─ 📄Frame_resolve.mo
│  │  │  │     │  │  │  ├─ 📄LineForceBase.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄partialColorMap.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryJoint.mo
│  │  │  │     │  │  │  ├─ 📄PartialForce.mo
│  │  │  │     │  │  │  ├─ 📄partialGravityAcceleration.mo
│  │  │  │     │  │  │  ├─ 📄PartialLineForce.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFrame_a.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFrame_b.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄partialSurfaceCharacteristic.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFrames.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFramesDoubleSize.mo
│  │  │  │     │  │  │  ├─ 📄PartialVisualizer.mo
│  │  │  │     │  │  │  └─ 📄ZeroPosition.mo
│  │  │  │     │  │  ├─ 📁Joints
│  │  │  │     │  │  │  ├─ 📁Assemblies
│  │  │  │     │  │  │  │  ├─ 📄JointRRP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointRRR.mo
│  │  │  │     │  │  │  │  ├─ 📄JointSSP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointSSR.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUPS.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUSP.mo
│  │  │  │     │  │  │  │  ├─ 📄JointUSR.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📁Constraints
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Prismatic.mo
│  │  │  │     │  │  │  │  ├─ 📄Revolute.mo
│  │  │  │     │  │  │  │  ├─ 📄Spherical.mo
│  │  │  │     │  │  │  │  └─ 📄Universal.mo
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄InitAngle.mo
│  │  │  │     │  │  │  │  ├─ 📄InitAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄InitPosition.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PrismaticWithLengthConstraint.mo
│  │  │  │     │  │  │  │  ├─ 📄RevoluteWithLengthConstraint.mo
│  │  │  │     │  │  │  │  └─ 📄RollingConstraintVerticalWheel.mo
│  │  │  │     │  │  │  ├─ 📄Cylindrical.mo
│  │  │  │     │  │  │  ├─ 📄FreeMotion.mo
│  │  │  │     │  │  │  ├─ 📄FreeMotionScalarInit.mo
│  │  │  │     │  │  │  ├─ 📄GearConstraint.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Planar.mo
│  │  │  │     │  │  │  ├─ 📄Prismatic.mo
│  │  │  │     │  │  │  ├─ 📄Revolute.mo
│  │  │  │     │  │  │  ├─ 📄RevolutePlanarLoopConstraint.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │  │  │     │  │  │  ├─ 📄Spherical.mo
│  │  │  │     │  │  │  ├─ 📄SphericalSpherical.mo
│  │  │  │     │  │  │  ├─ 📄Universal.mo
│  │  │  │     │  │  │  └─ 📄UniversalSpherical.mo
│  │  │  │     │  │  ├─ 📁Parts
│  │  │  │     │  │  │  ├─ 📄BevelGear1D.mo
│  │  │  │     │  │  │  ├─ 📄Body.mo
│  │  │  │     │  │  │  ├─ 📄BodyBox.mo
│  │  │  │     │  │  │  ├─ 📄BodyCylinder.mo
│  │  │  │     │  │  │  ├─ 📄BodyShape.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄FixedRotation.mo
│  │  │  │     │  │  │  ├─ 📄FixedTranslation.mo
│  │  │  │     │  │  │  ├─ 📄Mounting1D.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PointMass.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄RollingWheelSet.mo
│  │  │  │     │  │  │  └─ 📄Rotor1D.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄BasicAbsoluteAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicAbsolutePosition.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicCutForce.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicCutTorque.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicRelativeAngularVelocity.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicRelativePosition.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTransformAbsoluteVector.mo
│  │  │  │     │  │  │  │  ├─ 📄BasicTransformRelativeVector.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PartialAbsoluteBaseSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCutForceBaseSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialCutForceSensor.mo
│  │  │  │     │  │  │  │  ├─ 📄PartialRelativeBaseSensor.mo
│  │  │  │     │  │  │  │  └─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteAngles.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteAngularVelocity.mo
│  │  │  │     │  │  │  ├─ 📄AbsolutePosition.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄AbsoluteVelocity.mo
│  │  │  │     │  │  │  ├─ 📄CutForce.mo
│  │  │  │     │  │  │  ├─ 📄CutForceAndTorque.mo
│  │  │  │     │  │  │  ├─ 📄CutTorque.mo
│  │  │  │     │  │  │  ├─ 📄Distance.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Power.mo
│  │  │  │     │  │  │  ├─ 📄RelativeAngles.mo
│  │  │  │     │  │  │  ├─ 📄RelativeAngularVelocity.mo
│  │  │  │     │  │  │  ├─ 📄RelativePosition.mo
│  │  │  │     │  │  │  ├─ 📄RelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelativeVelocity.mo
│  │  │  │     │  │  │  ├─ 📄TransformAbsoluteVector.mo
│  │  │  │     │  │  │  └─ 📄TransformRelativeVector.mo
│  │  │  │     │  │  ├─ 📁Types
│  │  │  │     │  │  │  ├─ 📁Defaults
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Axis.mo
│  │  │  │     │  │  │  ├─ 📄AxisLabel.mo
│  │  │  │     │  │  │  ├─ 📄Color.mo
│  │  │  │     │  │  │  ├─ 📄GravityTypes.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RealColor.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameA.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameAB.mo
│  │  │  │     │  │  │  ├─ 📄ResolveInFrameB.mo
│  │  │  │     │  │  │  ├─ 📄RotationSequence.mo
│  │  │  │     │  │  │  ├─ 📄RotationTypes.mo
│  │  │  │     │  │  │  ├─ 📄ShapeExtra.mo
│  │  │  │     │  │  │  ├─ 📄ShapeType.mo
│  │  │  │     │  │  │  ├─ 📄SpecularCoefficient.mo
│  │  │  │     │  │  │  └─ 📄VectorQuantity.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📁Tutorial
│  │  │  │     │  │  │  │  ├─ 📁LoopStructures
│  │  │  │     │  │  │  │  │  ├─ 📄AnalyticLoopHandling.mo
│  │  │  │     │  │  │  │  │  ├─ 📄Introduction.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  └─ 📄PlanarLoops.mo
│  │  │  │     │  │  │  │  ├─ 📄ConnectionOfLineForces.mo
│  │  │  │     │  │  │  │  ├─ 📄FirstExample.mo
│  │  │  │     │  │  │  │  ├─ 📄OverView.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄Literature.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Visualizers
│  │  │  │     │  │  │  ├─ 📁Advanced
│  │  │  │     │  │  │  │  ├─ 📁SurfaceCharacteristics
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄pipeWithScalarField.mo
│  │  │  │     │  │  │  │  │  ├─ 📄rectangle.mo
│  │  │  │     │  │  │  │  │  └─ 📄torus.mo
│  │  │  │     │  │  │  │  ├─ 📄Arrow.mo
│  │  │  │     │  │  │  │  ├─ 📄DoubleArrow.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄PipeWithScalarField.mo
│  │  │  │     │  │  │  │  ├─ 📄Shape.mo
│  │  │  │     │  │  │  │  ├─ 📄Surface.mo
│  │  │  │     │  │  │  │  └─ 📄Vector.mo
│  │  │  │     │  │  │  ├─ 📁Colors
│  │  │  │     │  │  │  │  ├─ 📁ColorMaps
│  │  │  │     │  │  │  │  │  ├─ 📄autumn.mo
│  │  │  │     │  │  │  │  │  ├─ 📄gray.mo
│  │  │  │     │  │  │  │  │  ├─ 📄hot.mo
│  │  │  │     │  │  │  │  │  ├─ 📄jet.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  │  ├─ 📄spring.mo
│  │  │  │     │  │  │  │  │  ├─ 📄summer.mo
│  │  │  │     │  │  │  │  │  └─ 📄winter.mo
│  │  │  │     │  │  │  │  ├─ 📄colorMapToSvg.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  └─ 📄scalarToColor.mo
│  │  │  │     │  │  │  ├─ 📁Internal
│  │  │  │     │  │  │  │  ├─ 📄FixedLines.mo
│  │  │  │     │  │  │  │  ├─ 📄Lines.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  └─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄FixedArrow.mo
│  │  │  │     │  │  │  ├─ 📄FixedFrame.mo
│  │  │  │     │  │  │  ├─ 📄FixedShape.mo
│  │  │  │     │  │  │  ├─ 📄FixedShape2.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PipeWithScalarField.mo
│  │  │  │     │  │  │  ├─ 📄Rectangle.mo
│  │  │  │     │  │  │  ├─ 📄SignalArrow.mo
│  │  │  │     │  │  │  ├─ 📄Torus.mo
│  │  │  │     │  │  │  └─ 📄VoluminousWheel.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Rotational
│  │  │  │     │  │  ├─ 📁Components
│  │  │  │     │  │  │  ├─ 📄AngleToTorqueAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄BearingFriction.mo
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄Clutch.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄Disc.mo
│  │  │  │     │  │  │  ├─ 📄ElastoBacklash.mo
│  │  │  │     │  │  │  ├─ 📄ElastoBacklash2.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄Gearbox.mo
│  │  │  │     │  │  │  ├─ 📄GeneralAngleToTorqueAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralTorqueToAngleAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄IdealGear.mo
│  │  │  │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │  │  │     │  │  │  ├─ 📄IdealPlanetary.mo
│  │  │  │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄Inertia.mo
│  │  │  │     │  │  │  ├─ 📄InitializeFlange.mo
│  │  │  │     │  │  │  ├─ 📄LossyGear.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutch.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  └─ 📄TorqueToAngleAdaptor.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄DirectInertia.mo
│  │  │  │     │  │  │  │  ├─ 📄InverseInertia.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Backlash.mo
│  │  │  │     │  │  │  ├─ 📄CompareBrakingTorque.mo
│  │  │  │     │  │  │  ├─ 📄CoupledClutches.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │  │  │     │  │  │  ├─ 📄ElasticBearing.mo
│  │  │  │     │  │  │  ├─ 📄First.mo
│  │  │  │     │  │  │  ├─ 📄FirstGrounded.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │  │  │     │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo1.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo2.mo
│  │  │  │     │  │  │  ├─ 📄LossyGearDemo3.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutch.mo
│  │  │  │     │  │  │  ├─ 📄OneWayClutchDisengaged.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RollingWheel.mo
│  │  │  │     │  │  │  └─ 📄SimpleGearShift.mo
│  │  │  │     │  │  ├─ 📁Icons
│  │  │  │     │  │  │  ├─ 📄Clutch.mo
│  │  │  │     │  │  │  ├─ 📄Gear.mo
│  │  │  │     │  │  │  ├─ 📄Gearbox.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  └─ 📄package.order
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄Flange.mo
│  │  │  │     │  │  │  ├─ 📄Flange_a.mo
│  │  │  │     │  │  │  ├─ 📄Flange_b.mo
│  │  │  │     │  │  │  ├─ 📄InternalSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliant.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialFriction.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialTorque.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │  │  │     │  │  │  └─ 📄Support.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AccSensor.mo
│  │  │  │     │  │  │  ├─ 📄AngleSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAccSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAngleSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │  │  │     │  │  │  ├─ 📄SpeedSensor.mo
│  │  │  │     │  │  │  └─ 📄TorqueSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │  │  │     │  │  │  ├─ 📄ConstantTorque.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentTorque.mo
│  │  │  │     │  │  │  ├─ 📄InverseSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄LinearSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄Move.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Position.mo
│  │  │  │     │  │  │  ├─ 📄QuadraticSpeedDependentTorque.mo
│  │  │  │     │  │  │  ├─ 📄SignTorque.mo
│  │  │  │     │  │  │  ├─ 📄Speed.mo
│  │  │  │     │  │  │  ├─ 📄Torque.mo
│  │  │  │     │  │  │  ├─ 📄Torque2.mo
│  │  │  │     │  │  │  └─ 📄TorqueStep.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │  │  │     │  │  │  ├─ 📄ModelingOfFriction.mo
│  │  │  │     │  │  │  ├─ 📄Overview.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄References.mo
│  │  │  │     │  │  │  ├─ 📄RequirementsForSimulationTool.mo
│  │  │  │     │  │  │  ├─ 📄SignConventions.mo
│  │  │  │     │  │  │  ├─ 📄StateSelection.mo
│  │  │  │     │  │  │  ├─ 📄SupportTorques.mo
│  │  │  │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📁Translational
│  │  │  │     │  │  ├─ 📁Components
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄ElastoGap.mo
│  │  │  │     │  │  │  ├─ 📄Fixed.mo
│  │  │  │     │  │  │  ├─ 📄GeneralForceToPositionAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄GeneralPositionToForceAdaptor.mo
│  │  │  │     │  │  │  ├─ 📄IdealGearR2T.mo
│  │  │  │     │  │  │  ├─ 📄IdealRollingWheel.mo
│  │  │  │     │  │  │  ├─ 📄InitializeFlange.mo
│  │  │  │     │  │  │  ├─ 📄Mass.mo
│  │  │  │     │  │  │  ├─ 📄MassWithStopAndFriction.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄RelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Rod.mo
│  │  │  │     │  │  │  ├─ 📄RollingResistance.mo
│  │  │  │     │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  ├─ 📄SupportFriction.mo
│  │  │  │     │  │  │  └─ 📄Vehicle.mo
│  │  │  │     │  │  ├─ 📁Examples
│  │  │  │     │  │  │  ├─ 📁Utilities
│  │  │  │     │  │  │  │  ├─ 📄DirectMass.mo
│  │  │  │     │  │  │  │  ├─ 📄GenerateStribeckFrictionTable.mo
│  │  │  │     │  │  │  │  ├─ 📄InverseMass.mo
│  │  │  │     │  │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  │  ├─ 📄Spring.mo
│  │  │  │     │  │  │  │  ├─ 📄SpringDamper.mo
│  │  │  │     │  │  │  │  └─ 📄SpringDamperNoRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄Brake.mo
│  │  │  │     │  │  │  ├─ 📄CompareBrakingForce.mo
│  │  │  │     │  │  │  ├─ 📄Damper.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentBrake.mo
│  │  │  │     │  │  │  ├─ 📄ElastoGap.mo
│  │  │  │     │  │  │  ├─ 📄Friction.mo
│  │  │  │     │  │  │  ├─ 📄GenerationOfFMUs.mo
│  │  │  │     │  │  │  ├─ 📄HeatLosses.mo
│  │  │  │     │  │  │  ├─ 📄InitialConditions.mo
│  │  │  │     │  │  │  ├─ 📄Oscillator.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PreLoad.mo
│  │  │  │     │  │  │  ├─ 📄Sensors.mo
│  │  │  │     │  │  │  ├─ 📄SignConvention.mo
│  │  │  │     │  │  │  ├─ 📄Vehicle.mo
│  │  │  │     │  │  │  └─ 📄WhyArrows.mo
│  │  │  │     │  │  ├─ 📁Interfaces
│  │  │  │     │  │  │  ├─ 📄Flange.mo
│  │  │  │     │  │  │  ├─ 📄Flange_a.mo
│  │  │  │     │  │  │  ├─ 📄Flange_b.mo
│  │  │  │     │  │  │  ├─ 📄InternalSupport.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PartialAbsoluteSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliant.mo
│  │  │  │     │  │  │  ├─ 📄PartialCompliantWithRelativeStates.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryOneFlangeAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryRotationalToTranslational.mo
│  │  │  │     │  │  │  ├─ 📄PartialElementaryTwoFlangesAndSupport2.mo
│  │  │  │     │  │  │  ├─ 📄PartialForce.mo
│  │  │  │     │  │  │  ├─ 📄PartialFriction.mo
│  │  │  │     │  │  │  ├─ 📄PartialOneFlangeAndSupport.mo
│  │  │  │     │  │  │  ├─ 📄PartialRelativeSensor.mo
│  │  │  │     │  │  │  ├─ 📄PartialRigid.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlanges.mo
│  │  │  │     │  │  │  ├─ 📄PartialTwoFlangesAndSupport.mo
│  │  │  │     │  │  │  └─ 📄Support.mo
│  │  │  │     │  │  ├─ 📁Sensors
│  │  │  │     │  │  │  ├─ 📄AccSensor.mo
│  │  │  │     │  │  │  ├─ 📄ForceSensor.mo
│  │  │  │     │  │  │  ├─ 📄MultiSensor.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄PositionSensor.mo
│  │  │  │     │  │  │  ├─ 📄PowerSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelAccSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelPositionSensor.mo
│  │  │  │     │  │  │  ├─ 📄RelSpeedSensor.mo
│  │  │  │     │  │  │  └─ 📄SpeedSensor.mo
│  │  │  │     │  │  ├─ 📁Sources
│  │  │  │     │  │  │  ├─ 📄Accelerate.mo
│  │  │  │     │  │  │  ├─ 📄ConstantForce.mo
│  │  │  │     │  │  │  ├─ 📄ConstantSpeed.mo
│  │  │  │     │  │  │  ├─ 📄EddyCurrentForce.mo
│  │  │  │     │  │  │  ├─ 📄Force.mo
│  │  │  │     │  │  │  ├─ 📄Force2.mo
│  │  │  │     │  │  │  ├─ 📄ForceStep.mo
│  │  │  │     │  │  │  ├─ 📄InverseSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄LinearSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄Move.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄Position.mo
│  │  │  │     │  │  │  ├─ 📄QuadraticSpeedDependentForce.mo
│  │  │  │     │  │  │  ├─ 📄SignForce.mo
│  │  │  │     │  │  │  └─ 📄Speed.mo
│  │  │  │     │  │  ├─ 📁UsersGuide
│  │  │  │     │  │  │  ├─ 📄Contact.mo
│  │  │  │     │  │  │  ├─ 📄FlangeConnectors.mo
│  │  │  │     │  │  │  ├─ 📄Overview.mo
│  │  │  │     │  │  │  ├─ 📄package.mo
│  │  │  │     │  │  │  ├─ 📄package.order
│  │  │  │     │  │  │  ├─ 📄SignConventions.mo
│  │  │  │     │  │  │  ├─ 📄StateSelection.mo
│  │  │  │     │  │  │  ├─ 📄SupportForces.mo
│  │  │  │     │  │  │  └─ 📄UserDefinedComponents.mo
│  │  │  │     │  │  ├─ 📄package.mo
│  │  │  │     │  │  └─ 📄package.order
│  │  │  │     │  ├─ 📄package.mo
│  │  │  │     │  └─ 📄package.order
│  │  │  │     ├─ 📄.gitkeep
│  │  │  │     └─ 📄Untitled
│  │  │  ├─ 📄application-dev.yml
│  │  │  ├─ 📄application-prod.yml
│  │  │  └─ 📄application.yml
│  │  ├─ 📁generated-sources
│  │  │  └─ 📁annotations
│  │  │     └─ 📁com
│  │  │        └─ 📁modelcloud
│  │  │           └─ 📁modules
│  │  │              ├─ 📁business
│  │  │              │  └─ 📁model
│  │  │              │     └─ 📁domain
│  │  │              │        └─ 📁table
│  │  │              │           ├─ 📄BsComponentTableDef.java
│  │  │              │           ├─ 📄BsModelCollectTableDef.java
│  │  │              │           ├─ 📄BsModelingProjectTableDef.java
│  │  │              │           ├─ 📄BsModelLabelTableDef.java
│  │  │              │           ├─ 📄BsModelTableDef.java
│  │  │              │           ├─ 📄BsSimulationTaskTableDef.java
│  │  │              │           └─ 📄ModelLabelCategoryTableDef.java
│  │  │              └─ 📁sys
│  │  │                 └─ 📁model
│  │  │                    └─ 📁domain
│  │  │                       └─ 📁table
│  │  │                          ├─ 📄SysFileTableDef.java
│  │  │                          ├─ 📄SysPowerTableDef.java
│  │  │                          ├─ 📄SysRoleTableDef.java
│  │  │                          ├─ 📄SysSiteStatTableDef.java
│  │  │                          ├─ 📄SysUserRoleTableDef.java
│  │  │                          └─ 📄SysUserTableDef.java
│  │  ├─ 📁generated-test-sources
│  │  │  └─ 📁test-annotations
│  │  ├─ 📁maven-status
│  │  │  └─ 📁maven-compiler-plugin
│  │  │     └─ 📁compile
│  │  │        └─ 📁default-compile
│  │  │           ├─ 📄createdFiles.lst
│  │  │           └─ 📄inputFiles.lst
│  │  └─ 📁test-classes
│  ├─ 📄.gitignore
│  ├─ 📄pom.xml
│  └─ 📄技术报告.md
├─ 📁model-cloud-frontend
│  ├─ 📁public
│  │  ├─ 📄angle.png
│  │  ├─ 📄current.png
│  │  └─ 📄omega.png
│  ├─ 📁src
│  │  ├─ 📁api
│  │  │  ├─ 📄auth.ts
│  │  │  ├─ 📄model-deploy.ts
│  │  │  ├─ 📄model.ts
│  │  │  ├─ 📄request.ts
│  │  │  └─ 📄user.ts
│  │  ├─ 📁components
│  │  │  └─ 📁model
│  │  │     ├─ 📄ModelDeleteButton.vue
│  │  │     ├─ 📄ModelFilterBar.vue
│  │  │     ├─ 📄ModelicaComponentNode.vue
│  │  │     └─ 📄ModelUploadDialog.vue
│  │  ├─ 📁layouts
│  │  │  └─ 📄MainLayout.vue
│  │  ├─ 📁router
│  │  │  └─ 📄index.ts
│  │  ├─ 📁stores
│  │  │  └─ 📄user.ts
│  │  ├─ 📁utils
│  │  │  └─ 📄stats.ts
│  │  ├─ 📁views
│  │  │  ├─ 📁auth
│  │  │  │  ├─ 📄Login.vue
│  │  │  │  └─ 📄Register.vue
│  │  │  ├─ 📁business
│  │  │  │  ├─ 📄ComponentManage.vue
│  │  │  │  ├─ 📄ModelDeploy.vue
│  │  │  │  ├─ 📄ModelDetail.vue
│  │  │  │  ├─ 📄ModelList.vue
│  │  │  │  ├─ 📄ModelManage.vue
│  │  │  │  ├─ 📄MyCollects.vue
│  │  │  │  └─ 📄MyModels.vue
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
│  ├─ 📄vite.config.ts
│  └─ 📄技术报告.md
├─ 📁model-cloud-simulation
│  ├─ 📁app
│  │  ├─ 📁api
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁models
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁services
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁tasks
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁utils
│  │  │  ├─ 📁__pycache__
│  │  │  │  └─ 📄__init__.cpython-311.pyc
│  │  │  └─ 📄__init__.py
│  │  ├─ 📁__pycache__
│  │  │  ├─ 📄config.cpython-311.pyc
│  │  │  ├─ 📄main.cpython-311.pyc
│  │  │  └─ 📄__init__.cpython-311.pyc
│  │  ├─ 📄config.py
│  │  ├─ 📄main.py
│  │  └─ 📄__init__.py
│  ├─ 📄.gitignore
│  ├─ 📄README.md
│  └─ 📄requirements.txt
├─ 📁__pycache__
│  └─ 📄parse_modelica_components.cpython-311.pyc
├─ 📄.gitignore
├─ 📄database_full_init.sql
├─ 📄Modelica模型部署功能开发思路说明.md
├─ 📄README.md
└─ 📄技术报告.md
```