@echo off
acme -v3 MAIN.S > BUILD.LOG
TYPE BUILD.LOG | MORE
pause
