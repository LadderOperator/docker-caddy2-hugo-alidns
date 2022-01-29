# Docker-Caddy2-Hugo-AliDNS

Caddy2+Hugo+AliDNS的Dockerfile， 含git webhook更新与阿里云自动申请SSL证书。

## 使用方式

鉴于网上比较多都是 Caddy v1 的版本，或者没有dockerize的版本，再不然就是没有阿里云DNS。于是东拼西凑做此镜像。

一般来说，你只需要：

南大 Git（特殊时期可能无法校外访问，懂得都懂）：
```
git clone https://git.nju.edu.cn/ladderoperator/docker-caddy2-hugo-alidns.git
```
GitHub：
```
git clone https://github.com/LadderOperator/docker-caddy2-hugo-alidns.git
```
配置好`config.json`文件之后，
```
docker-compose up -d
```
便可以简单搭建起你的 Hugo 博客。

## 配置

由于大量教程都是采用`Caddyfile`这样喜闻乐见的简单格式，在尝试按照官方并不好懂的 JSON 结构撰写给 Caddy API 的配置时，踩了不少坑。

以下是我的示例文件，作为一种还算可行的尝试，你或许只需要修改`config.json`即可。

```json
{
    "apps": {
        "tls": {
            "certificates": {
                // 需要自动更新证书的域名
                "automate": [
                    "example.com"
                ]
            },
            // 阿里云设置
            "automation": {
                "policies": [
                    {
                        "issuers": [
                            {
                                "module": "acme",
                                "challenges": {
                                    "dns": {
                                        "provider": {
                                            "name": "alidns",
                                            // 阿里云账户的访问ID
                                            "access_key_id": "access_key_id",
                                            // 阿里云账户的访问密钥
                                            "access_key_secret": "access_key_secret"
                                        }
                                    }
                                }
                            }
                        ]
                    }
                ]
            }
        },
        "http": {
            "servers": {
                "caddy-hugo": {
                    "listen": [
                        ":443"
                    ],
                    "automatic_https": {
                        "disable": false
                    },
                    "routes": [
                        // 配置静态网站访问路由
                        {
                            "handle": [
                                {
                                    "handler": "file_server",
                                    "root": "/public"
                                }
                            ],
                            // 与下方 webhook 的 router 分隔开
                            // webhook 插件无法置于静态页面之前
                            // 所以 router 配置顺序貌似会导致 webhook 请求被截胡
                            "match": [
                              {
                                "not": [
                                  {
                                    "path": [
                                        "/webhook"
                                    ]
                                  }
                                ]
                              }
                            ]
                        },
                        {
                            "handle": [
                                {
                                    "handler": "subroute",
                                    "routes": [
                                        {
                                            "handle": [
                                                {
                                                    // 需要填写与你一致的分支
                                                    "branch": "master",
                                                    "command": [
                                                        "hugo",
                                                        "--destination=/public"
                                                    ],
                                                    "handler": "webhook",
                                                    "path": "/blog",
                                                    // 需要填写与你一致的 hugo 仓库
                                                    "repo": "https://gitee.com/example/example-blog.git",
                                                    // 需要填写与你一致的 webhook 密码
                                                    "secret": "example",
                                                    // 如果含有子模块需要设置为“true”
                                                    "submodule": true,
                                                    // 需要填写你使用的 webhook 服务
                                                    "type": "gitee"
                                                }
                                                // 实测原作者例子中的 depth 和自动更新会冲突，似乎是因为浅克隆的原因，因此这里没写
                                            ]
                                        }
                                    ]
                                }
                            ],
                            // 用作 webhook 请求的路径，本例子中就是 https://example.com/webhook
                            "match": [
                                {
                                    "path": [
                                        "/webhook"
                                    ]
                                }
                            ]
                        }
                    ]
                }
            }
        }
    }
}
```

## 致谢

Caddy V2 插件：
- alidns插件：https://github.com/caddy-dns/alidns
- webhook：https://github.com/WingLim/caddy-webhook

Dockerfile 参考：
- Caddy V1 的一个封装：https://github.com/hyacinthus/docker-hugo-caddy

参考博客：
- https://catcat.cc/post/h9bti/
- https://mritd.com/2021/01/07/lets-start-using-caddy2/
- https://triples.cc/posts/set-up-blog/

没有上述大佬的无私贡献，我也不可能几天凑出来这个镜像。