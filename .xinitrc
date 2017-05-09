#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# backlight
#sudo echo > /sys/class/backlight/intel_backlight/brightness

# Set the locale for X-windows
export LANG=zh_CN.UTF-8
export LC_COLLATE=C
export LC_TIME=en_US.UTF-8
export LC_MESSAGES=zh_CN.UTF-8
export LANGUAGE=zh_CN:en_US

# Set the input method
export XIM=fcitx 
export XIM_PROGRAM=fcitx 
export GTK_IM_MODULE=fcitx
export QT_IM_MODULE=fcitx
export XMODIFIERS="@im=fcitx"
fcitx -d 

# My Status Bar
while true ; do
    batt=$(acpi -b)
    case $batt in
        *Discharging*)
        batt="<$(echo $batt | awk '{print $4}' | tr -d ',')"
            ;;
    *Charging*)
        batt=">$(echo $batt | awk '{print $4}' | tr -d ',')"
        ;;
        *)
        batt="$(echo $batt | awk '{print $4}' | tr -d ',')"
            ;;
    esac

    ##echo user nice system idle iowait irq softirq  
    CPULOG_1=$(cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')  
    SYS_IDLE_1=$(echo $CPULOG_1 | awk '{print $4}')  
    Total_1=$(echo $CPULOG_1 | awk '{print $1+$2+$3+$4+$5+$6+$7}')

    sleep 3
    
    CPULOG_2=$(cat /proc/stat | grep 'cpu ' | awk '{print $2" "$3" "$4" "$5" "$6" "$7" "$8}')  
    SYS_IDLE_2=$(echo $CPULOG_2 | awk '{print $4}')  
    Total_2=$(echo $CPULOG_2 | awk '{print $1+$2+$3+$4+$5+$6+$7}')  
 
    SYS_IDLE=`expr $SYS_IDLE_2 - $SYS_IDLE_1`  
 
    Total=`expr $Total_2 - $Total_1`  
    SYS_USAGE=`expr $SYS_IDLE/$Total*100 |bc -l`  
 
    SYS_Rate=`expr 100-$SYS_USAGE |bc -l`  
 
    Disp_SYS_Rate=`expr "scale=2; $SYS_Rate/1" |bc`

    xsetroot -name "$batt $( date +"%F %R" ) $Disp_SYS_Rate%"
    sleep 57
done &

# Mutil windows manager
session=${1:-dwm}
case $session in
    dwm             )
        exec startdwm;;
    xfce|xfce4      ) 
        exec startxfce4;;
    # No known session, try to run it as default
    *) exec $1;;
esac
