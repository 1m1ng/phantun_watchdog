下载文件

```bash
curl https://git.1m1ng.top/Huiji/phantun_watchdog/raw/branch/main/phantun_watchdog.sh -o /usr/local/bin/phantun_watchdog
```

给予权限

```bash
chmod +x /usr/local/bin/phantun_watchdog
```

写入到crond中

```bash
echo '* * * * * root /usr/local/bin/phantun_watchdog' >> /etc/crontab
```
