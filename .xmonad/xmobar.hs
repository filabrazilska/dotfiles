-- xmobar config used by Vic Fryzel
-- Author: Vic Fryzel
-- http://github.com/vicfryzel/xmonad-config

Config {
    font = "xft:Inconsolata\ for\ powerline:size=11:antialias=true"
  , bgColor = "#fdf6e3"
  , fgColor = "#939496"
    position = BottomSize L 92 16,
    lowerOnStart = True,
    commands = [
        Run MultiCpu ["-t","Cpu: <total0> <total1> <total2> <total3>","-L","30","-H","60","-h","#DC322F","-l","#859900","-n","#268BD2","-w","3"] 10,
        Run Memory ["-t","Mem: <usedratio>%","-H","8192","-L","4096","-h","#DC322F","-l","#859900","-n","#268BD2"] 10,
        Run BatteryP ["BAT0"] ["-t", "Batt: <timeleft>"] 10,
        Run Date "%a %b %_d %l:%M" "date" 10,
        Run StdinReader
    ],
    sepChar = "%",
    alignSep = "}{",
    template = "%StdinReader% }{ %multicpu%   %memory%   %battery%   <fc=#939496>%date%</fc> "
}
