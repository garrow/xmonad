#!/usr/bin/env ruby 

Screen = Struct.new :x, :y

left_screen = Screen.new 1920, 1200 
right_screen = Screen.new 1920 , 1080

bar_height = 18

fg = '#FFFFFF'
bg = '#000000'


BarOpts = Struct.new :x, :y, :height, :width, :fg_colour, :bg_colour do 
  def command
    "dzen2 -x #{x} -y #{y} -h '#{height}' -w #{width} -ta 'l' -fg '#{fg_colour}' -bg '#{bg_colour}' -m  -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-1'"
  end
end





#bg = '#C0BCB4' #greyish

# specifically set the height to match the fake gnome panel that provides the struts
# dzen wont set struts on bars not on the edges of the monitor, so uneven
# desktop size wont strut on the smaller monitor 
right_height = bar_height + 1

left_bar = BarOpts.new 0, left_screen.y - bar_height, bar_height, left_screen.x, fg, bg
right_bar = BarOpts.new left_screen.x, right_screen.y - right_height,  right_height, right_screen.x, fg, bg


left = IO.popen( left_bar.command , 'r+' ) 
right = IO.popen( right_bar.command , 'r+' ) 

ARGF.each_line do |l| 
  left << l 
  right << l 
end


