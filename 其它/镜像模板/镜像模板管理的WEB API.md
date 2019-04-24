### 1. 分页查询镜像模板
URL：/cbb/clouddesktop/imageTemplate/list

**描述**

分页查询镜像模板

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|page|int|是|大于0|当前页码|
|limit|int|是|大于0|当前页最大数量|


**返回值**

|名称 | 类型 | 描述
|---|---|---
|imageTemplateId | uuid | 镜像模板ID
|imageTemplateName | string | 文件名
|osType | enum | WIN_7_32/WIN_7_64
|systemDiskSize | int| 系统盘大小，单位GB
|imageTemplateState | enum | 镜像模板状态：CREATING/AVALIABLE/EDITING/DELETING



**请求参数示例**


```json
{
	"page":1,
	"limit":10,
}
```

**响应**

```json
{
    "content": {
        "itemArr": [
            {
                "imageTemplateId": "ff968ce1-3f2f-4fde-9461-13f4a330d2d9",
                "imageTemplateName": "win7",
                "osType": "WIN_7_32",
                "systemDiskSize": 3,
                "imageTemplateState": "AVALIABLE",
            }
        ],
        "total": 11
    },
    "message": null,
    "status": "SUCCESS"
}
```


### 2. 导入预制镜像
URL：/cbb/clouddesktop/imageTemplate/uploadImage

**描述**

导入预制镜像

**请求**

上传请求


**返回值**

无

**请求参数示例**

M/A

**响应**
``` json
{
    "status"："SUCESS",
    "message": "<成功或出错的提示>"
}
```

### 3. 使用已有镜像克隆新镜像
URL：/cbb/clouddesktop/imageTemplate/prepareClone

**描述**

使用已有镜像克隆新镜像

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|oldImageTemplateId | uuid | 是 | NotNull | 旧的镜像模板ID
|newImageTemplateName | string | 是 | NotBlank/TextName | 新的镜像模板名


**返回值**

无


**请求参数示例**

```json
{
	"oldImageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
	"newImageTemplateName": "win7镜像",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 4. 配置编辑镜像的虚机参数
URL：/cbb/clouddesktop/imageTemplate/configVm

**描述**

配置编辑镜像的虚机参数

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID
|cpuCoreCount | int | 是 | NotNull/Range(1~8) | CPU核数
|memorySize | int | 是 | NotNull/Range(2~16) | 内存大小
|diskSize | int | 是 | NotNull/Range(20~100) | 磁盘大小
|deskNetworkId | uuid | 是 | NotNull | 网络模板ID
|expectVmIp | string | 是 | NotBlank/IpAddress | 虚机的IP地址


**返回值**

无


**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
	"cpuCoreCount": 2,
	"memorySize": 4,
	"diskSize": 40,
	"deskNetworkId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
	"expectVmIp": "192.168.5.25",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 5. 启动编辑镜像的虚机
URL：/cbb/clouddesktop/imageTemplate/startVm

**描述**

启动编辑镜像的虚机

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID


**返回值**

无


**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 6. 查询VNC地址
URL：/cbb/clouddesktop/imageTemplate/queryVncURL

**描述**

启动编辑镜像的虚机

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID


**返回值**

|名称 | 类型 | 描述
|---|---|---
|vucUrl | string | vnc地址



**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS",
	"content": {
	  "vucUrl": "http://xxxxx"
	}
}
```

### 7. 发布镜像
URL：/cbb/clouddesktop/imageTemplate/publishVm

**描述**

发布镜像

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID


**返回值**

无


**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 8. 放弃编辑镜像
URL：/cbb/clouddesktop/imageTemplate/abort

**描述**

放弃编辑镜像

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID


**返回值**

无

**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 9. 删除镜像
URL：/cbb/clouddesktop/imageTemplate/delete

**描述**

删除镜像

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateIdArr | uuid数组 | 是 | NotEmpty | 镜像模板ID


**返回值**

无


**请求参数示例**

```json
{
	"imageTemplateIdArr": ["ef968ce1-3f2f-4fde-9461-13f4a330d2d9"],
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 10. 更新镜像其他参数
URL：/cbb/clouddesktop/imageTemplate/update

**描述**

更新镜像其他参数

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID
|imageTemplateName | string | 是 | NotBlank/TextName | 镜像名


**返回值**

无


**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
	"imageTemplateName": "镜像新名称"
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```

### 11. 查询编辑中的镜像状态
URL：/cbb/clouddesktop/imageTemplate/queryEditState

**描述**

查询编辑中的镜像状态

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|imageTemplateId | uuid | 是 | NotNull | 镜像模板ID


**返回值**

|名称 | 类型 | 描述
|---|---|---
|imageTemplateState | enum | 镜像模板状态：CREATING/AVALIABLE/EDITING/DELETING
|imageTemplateEditState | enum | 镜像模板编辑的：PREPARING/PREPARE_SUCCESS/VM_CONFIG_PARAM_ING/VM_CONFIG_PARAM_READY/VM_CREATE_ING/VM_CREATE_READY/ABORTING/PUBLISHING
|guestToolReady | boolean | 和GuestTool的交互是否完成


**请求参数示例**

```json
{
	"imageTemplateId": "ef968ce1-3f2f-4fde-9461-13f4a330d2d9",
	"imageTemplateName": "镜像新名称"
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```