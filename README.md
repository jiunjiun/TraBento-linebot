# TraBento-linebot
Taiwan Railways Administration Bento (Unofficial)

#### 台鐵訂便當 Bot
Line bot：[@jhp8774x](https://line.me/R/ti/p/%40jhp8774x)

---

### 介紹

* 本專案使用 Rails 開發
* 本專案API使用 [Chan Wei Wu](https://www.facebook.com/chanwei.wu) 提供 http://bentobox.goodideas-campus.com/

---

### 基本設定

設定 Heroku

```
git push heroku master
```

設定Line SECRET and TOKEN to Heroku

從這邊[https://developers.line.me/](https://developers.line.me/)後台找到 `Channel Secret`, `Channel Access Token` 加入Heroku

```
heroku config:set LINE_CHANNEL_SECRET=<Channel Secret>
heroku config:set LINE_CHANNEL_TOKEN=<Channel Access Token>
```

在Heroku 增加 Redis 功能

```
heroku plugins:install heroku-redis
```

設定 Heroku 網址
```
heroku config:set BASE_URL=https://<HEROKU_APP>.herokuapp.com/
```


---
### 感謝

* [Chan Wei Wu](https://www.facebook.com/chanwei.wu) API提供


## Copyright / License
* Copyright (c) 2017 jiunjiun (quietmes At gmail.com)
* Licensed under [MIT](https://github.com/jiunjiun/TraBento-linebot/blob/master/LICENSE) licenses.

