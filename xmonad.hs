import XMonad

import XMonad.Config.Desktop -- super for gnome
import XMonad.Config.Gnome

-- set window name for Java Apps compat.
-- startupHook = startupHook desktopConfig >> setWMName "LG3D"

import XMonad.Hooks.SetWMName

import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W
-- dzen!!
import XMonad.Hooks.DynamicLog
import System.IO
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.FadeInactive
import XMonad.Util.Run

-- Cycle between workspaces
import XMonad.Actions.CycleWS


-- workspace sorting for dzen 
import XMonad.Util.WorkspaceCompare
-- http://xmonad.org/xmonad-docs/xmonad-contrib/XMonad-Util-WorkspaceCompare.html

import XMonad.Hooks.ManageDocks -- for avoidStruts

-- Prebuilt Layouts 
import XMonad.Layout.Tabbed
import XMonad.Layout.NoBorders
import XMonad.Layout.Dishes
import XMonad.Layout.Roledex

-- Search bar and prompts
import XMonad.Actions.Search 
import qualified XMonad.Prompt as P



import XMonad.Util.NamedScratchpad

--scratchpads = [
--     NS "notes" "gvim --role notes ~/notes.txt" (role =? "notes") nonFloating
--   , NS "calc" "speedcrunch" (title =? "SpeedCrunch") defaultFloating
--   ] where role = stringProperty "WM_WINDOW_ROLE"
--


ticketwise :: SearchEngine
ticketwise = searchEngine "ticketwise" "https://intranet.hitwise.com/ticketwise/view.php?id=" 



-- myXFont = " -fn '-*-fixed-medium-r-*-*-13-*-*-*-*-*-*-1'"

--myStatusBar = "dzen2 -x '0' -y '1065' -h '15' -w '800' -ta 'l' -fg '#FFFFFF' -bg '#000000' -m" ++ myXFont 
-- myStatusBar2 = "dzen2 -xs 2 -x '30' -y '' -h '24' -w '800' -ta 'l' -fg '#FFFFFF' -bg '#000000' -m" ++ myXFont 
--myStatusBar = "cat > /tmp/xmonad.bar.txt"
myStatusBar = "/home/garrowb/.xmonad/multipipe.rb"

myLogHook :: Handle -> X ()
--myLogHook h = dynamicLogWithPP $ dzenPP { ppOutput = hPutStrLn h , ppSort              =  mkWsSort getXineramaWsCompare }
--myLogHook h = dynamicLogWithPP $ defaultPP { ppOutput = hPutStrLn h , ppSort              =  mkWsSort getXineramaWsCompare }

myLogHook h = dynamicLogWithPP $ dzenPP
    {
        ppCurrent           =   dzenColor "#3EB5FF" "black" . pad . wrap "[" "]"
      , ppVisible           =   dzenColor "white" "black" . pad . wrap " " " "
      , ppHidden            =   dzenColor "#999999" "black" . pad
      , ppHiddenNoWindows   =   dzenColor "#444444" "black" . pad
      , ppUrgent            =   dzenColor "red" "black" . pad
      , ppWsSep             =   ""
      , ppSep               =   "  |  "
      , ppTitle             =   (" " ++) . dzenColor "white" "black" . dzenEscape
      , ppLayout            =  dzenColor "black" "#cccc" . pad 
--      , ppLayout            =  ""
      , ppSort              =  mkWsSort getXineramaWsCompare -- [ left : right ] others
--      , ppExtra             =  
      , ppOutput            =   hPutStrLn h
    }


main = do
    workspaceBar <- spawnPipe myStatusBar
    xmonad $ gnomeConfig {
        
        workspaces = myWorkspaces
        , startupHook = startupHook desktopConfig >> setWMName "LG3D"
        , normalBorderColor = "#dddddd"
--        , focusedBorderColor = "#C8FF63"
        , focusedBorderColor = "#ff0000"
        , modMask = mod4Mask -- windows key
--        , layoutHook = avoidStruts $ noBorders $ layoutHook gnomeConfig ||| simpleTabbed -- avoidStruts for dzen(slightly broken) composed with default gnomeConfig
        , layoutHook = avoidStruts $ desktopLayoutModifiers $ layoutHook defaultConfig 
--        , layoutHook = layoutHook gnomeConfig ||| Dishes ||| simpleTabbed
        , logHook = do 
            myLogHook workspaceBar 
            logHook desktopConfig -- send data to Gnome
        } `additionalKeysP` myKeys
 
myWorkspaces = ["1","2","3","4","5","6.music","7.mail","8.chat","9","10"]
 
myKeys =
    [
    -- other additional keys
    ("M-g",  spawn "chrome")
--    , ( "M-n", namedScratchpadAction scratchpads "notes" )
--    , ( "M-o", namedScratchpadAction scratchpads "calc" )
    , ( "M-f",  promptSearch P.defaultXPConfig google )
    , ( "M-S-t",  promptSearch P.defaultXPConfig ticketwise )
    , ( "M-`",  toggleWS )
    , ( "M-<Tab>",  nextWS )
    , ( "M-S-<Tab>",  prevWS )
    , ( "<Alt>-<Tab>",  windows W.focusDown )
    , ( "<Alt>-S-<Tab>",  windows W.focusUp )
    
    --,("M-t",  spawn "gnome-terminal")
    ]
    ++ -- important since ff. is a list itself, can't just put inside above list
    [ 
    (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "1234567890"
         , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- was W.greedyView
                                      , ("S-", windows . W.shift)]
    ]


