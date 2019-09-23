@echo off
set ChromeDir="C:\Users\%UserName%\AppData\Local\Google\Chrome\user data"
Del /q /s /f '%ChromeDir%'
rd /s /q '%ChromeDir%'