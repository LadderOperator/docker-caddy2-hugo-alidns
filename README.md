# Docker-Caddy2-Hugo-AliDNS

Caddy2+Hugo+AliDNS的Dockerfile， 含git webhook更新与阿里云自动申请SSL证书。

## 使用方式

鉴于网上比较多都是 Caddy v1 的版本，或者没有dockerize的版本，再不然就是没有阿里云DNS。于是东拼西凑做此镜像。

一般来说，你只需要：

南大 Git（特殊时期可能无法校外访问，懂得都懂）：
```
git https://git.nju.edu.cn/ladderoperator/docker-caddy2-hugo-alidns.git
```
GitHub：
```
git https://github.com/LadderOperator/docker-caddy2-hugo-alidns.git
```
之后
```
cd docker-caddy2-hugo-alidns
docker-compose up -d
```
便可以简单克隆一个博客。

对于你自己的博客来说，只需要相应替换博客的仓库链接就可以。

## 配置

由于大量教程都是采用`Caddyfile`这样喜闻乐见的简单格式，在尝试按照官方并不好懂的 JSON 结构撰写给 Caddy API 的配置时，踩了不少坑。

以下是我的示例文件，作为一种还算可行的尝试，你或许只需要修改`config.json`即可。

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