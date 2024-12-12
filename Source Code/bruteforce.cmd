@echo off
set allowed_char_list="ABCDEFGHIJKLMNOPRSTUVYZWXQabcdefghijklmnoprstuvyzwxq0123456789-_"
cd BF_Files
title The WI-FI Brute Forcer - Developed By TUX
set /a attempt=1
del attempt.xml
del infogate.xml
cls
set targetwifi=No WI-FI Selected
set interface_description=Not Selected
set interface_id=Not Selected
set interface_mac=Not Selected
set interface_state=notdefined
setlocal enabledelayedexpansion
mode con: cols=80 lines=35
color 0f

call :interface_detection

if !interface_number!==1 (
    echo.
    call colorchar.exe /0b " Interface Detection"
    echo.
    echo.
    call colorchar.exe /0e " Only '1' Interface Found!"
    echo.
    echo.
    call colorchar.exe /0f " !interface_1_description!("
    call colorchar.exe /09 "!interface_1_mac!"
    call colorchar.exe /0f ")"
    echo.
    echo.
    echo  Making !interface_1_description! as default Interface...
    set interface_id=!interface_1!
    set interface_description=!interface_1_description!
    set interface_mac=!interface_1_mac!
    timeout /t 3 >nul
)

if !interface_number! gtr 1 (
    echo.
    call colorchar.exe /0b " Interface Detection"
    echo.
    echo.
    call colorchar.exe /0e " Multiple '!interface_number!' Interfaces Found!"
    echo.
    timeout /t 3 >nul
    call :interface_selection
)

if !interface_number!==0 (
    echo.
    call colorchar.exe /0b " Interface Detection"    
    echo.
    echo.
    call colorchar.exe /0e " WARNING"
    echo.
    echo  No interfaces found on this device^^!
    echo.
    echo  Press any key to continue...
    timeout /t 5 >nul
    cls
)

goto :main

:wifiscan
set /a keynumber=0
set choice=
cls

if "!interface_id!"=="Not Selected" (
    echo.
    call colorchar.exe /0c " You have to select an interface to perform a scan..."
    echo.
    echo.
    echo  Press any key to continue...
    timeout /t 5 >nul
    cls
    goto :main
)

if !interface_number!==0 (
    echo.
    call colorchar.exe /0c " You have at least '1' WI-FI interface to perform a scan..."
    echo.
    echo.
    echo  Press any key to continue...
    timeout /t 5 >nul
    cls
    goto :main
)

for /f "tokens=1-3 skip=7" %%a in ('netsh wlan show interfaces') do (
    if %%a==State (
        if %%c==connected (
            echo.
            echo  Disconnecting from current network...
            netsh wlan disconnect interface="!interface_id!">nul
            timeout /t 3 /nobreak >nul
        )
    )
)

:skip_disconnection
cls

del wifilist.txt
cls
set /a keynumber=0
echo.
call colorchar.exe /0b " Possible WIFI Networks"
echo.
echo.
call colorchar.exe /0f " Using "
call colorchar.exe /0e "!interface_description!"
call colorchar.exe /0f " for scanning..."
echo.
echo  Low Signal Strength WI-FIs are not recommended
echo.
for /f "tokens=1-4" %%a in ('netsh wlan show networks mode^=bssid interface^="!interface_id!" ') do (
    if %%a==SSID (
        set /a keynumber=!keynumber! + 1
        set current_ssid=%%d

        if "!current_ssid!"=="" (
            set "current_ssid=Hidden_Network"
        )

        if "!current_ssid!"=="Hidden_Network" (
            set text_available=false
        ) else (
            call :character_finder_2 "!current_ssid!"
        )
    )

    if %%a==Signal (
        set current_signal=%%c
        if !text_available!==true (
            call colorchar.exe /08 " !keynumber! - "
            call colorchar.exe /0f "!current_ssid!"
            call colorchar.exe /03 " - !current_signal:~1,5!"
            echo.

            echo !keynumber! - !current_ssid! - !current_signal:~1,4!>>wifilist.txt
            if !keynumber!==24 (
                goto :skip_scan
            )
        )
    )
)
:skip_scan
set /a keynumber=!keynumber!+1
set choice_cancel=!keynumber!
call colorchar.exe /08 " !keynumber! - "
call colorchar.exe /07 "Cancel Selection"
echo.
echo.
call colorchar.exe /0b " Please choice a wifi or cancel(1-!keynumber!)"
echo.
set choice=
call colorchar.exe /0e " wifi"
call colorchar.exe /0f "@"
call colorchar.exe /08 "select"
call colorchar.exe /0f "[]-"
set /p choice=

if !choice!==!choice_cancel! (
    set choice=
    set choice_cancel=
    cls
    goto :main
)

if !choice! gtr !keynumber! (
    call colorchar.exe /0c " Invalid input"
    echo.
    timeout /t 2 >nul
    cls
    set choice=
    goto :skip_disconnection
)

if !choice! lss 1 (
    call colorchar.exe /0c " Invalid input"
    echo.
    timeout /t 2 >nul
    cls
    set choice=
    goto :skip_disconnection
)

for /f "tokens=1-5" %%a in ( wifilist.txt ) do (
    if %%a==!choice! (
        set temp_signal_strength=%%e
        set signal_strength=!temp_signal_strength:~0,-1!
        if %%c==Unsupported (
            call colorchar.exe /0c " This SSID is unsupported..."
            timeout /t 3 >nul
            cls
            goto :skip_disconnection
        ) else (
            if !signal_strength! lss 50 (
                echo.
                call colorchar.exe /0c " Low signal[!signal_strength!] strengths are not recommended."
                echo.
                echo  Do you want to continue anyway?[Y-N]
                set choice=
                call colorchar.exe /0e " continue"
                call colorchar.exe /0f "@"
                call colorchar.exe /08 "select"
                call colorchar.exe /0f "[]-"
                set /p choice=
                if !choice!==N (
                    cls
                    goto :skip_disconnection
                )
                if !choice!==Y (
                    set targetwifi=%%c
                    goto :skip_target_wifi
                )
                call colorchar.exe /0c " Invalid input"
                echo.
                timeout /t 2 >nul
                cls
                set choice=
                goto :skip_disconnection            
            )

            set targetwifi=%%c
            :skip_target_wifi
            echo Test >nul
        )
    )
)

del wifilist.txt
cls
goto :eof
