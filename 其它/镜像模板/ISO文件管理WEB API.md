### 1. 分页查询ISO文件
URL：/cbb/clouddesktop/osIsoFile/list

**描述**

分页查询ISO文件

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|page|int|是|大于0|当前页码|
|limit|int|是|大于0|当前页最大数量|


**返回值**

|名称 | 类型 | 描述
|---|---|---
|osIsoFileId | uuid | ISO文件的ID
|fileName | string | 文件名
|fileMd5 | string | 文件MD5
|fileSize | long| 文件大小，单位byte
|fileState | enum | 文件状态：UPLOADING/AVALIABLE/DELETING



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
                "osIsoFileId": "ff968ce1-3f2f-4fde-9461-13f4a330d2d9",
                "fileName": "win7.iso",
                "fileMd5": "00d0e0fleidhl",
                "fileSize": 1257582,
                "fileState": "AVALIABLE",
            }
        ],
        "total": 11
    },
    "message": null,
    "status": "SUCCESS"
}
```


### 2. 导入ISO文件
URL：/cbb/clouddesktop/osIsoFile/upload

**描述**

导入ISO文件

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

### 3. 删除ISO文件
URL：/cbb/clouddesktop/osIsoFile/delete

**描述**

删除ISO文件

**请求**

|名称|类型|必填|校验规则|描述|
|----|----|------|-------|----|
|osIsoFileIdArr | uuid | 是 | NotEmpty | ISO文件ID


**返回值**

无


**请求参数示例**

```json
{
	"osIsoFileIdArr": ["ef968ce1-3f2f-4fde-9461-13f4a330d2d9"],
}
```

**响应**

```json
{
    "message": null,
    "status": "SUCCESS"
}
```
