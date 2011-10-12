#!/usr/bin/env ruby 

debug = false

class Screen 
    attr_accessor :x, :y
    def initialize (x,y)
        @x = x
        @y = y
    end
end





left = Screen.new 1920, 1080
right = Screen.new 1280, 1024



height = 15

# specifically set the height to match the fake gnome panel that provides the struts
# dzen wont set struts on bars not on the edges of the monitor, so uneven
# desktop size wont strut on the smaller monitor 
right_height =  height + 4

dzen_left = "dzen2 -x 0 -y #{left.y - height} -h '15' -w #{left.x} -ta 'l' -fg '#FFFFFF' -bg '#000000' -m  -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-1'" 
dzen_right = "dzen2 -xs 2 -x '0' -y '#{right.y - right_height}' -h #{right_height} -w '#{right.x}' -ta 'l' -fg '#FFFFFF' -bg '#000000' -m   -fn '-*-fixed-medium-r-*-*-11-*-*-*-*-*-*-1'"

#puts dzen_left unless false
#puts dzen_right unless false

left = IO.popen( dzen_left , 'r+' ) 
right = IO.popen( dzen_right , 'r+' ) 
#IO.popen( dzen_right_mask , 'r+' ) 

#puts height
#puts right_height

ARGF.each_line do |l| 
  left << l 
  right << l 
end


