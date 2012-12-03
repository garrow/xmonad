import XMonad
import System.Exit

import XMonad.Hooks.FadeInactive

import XMonad.Config.Desktop -- super for gnome
import XMonad.Config.Gnome

-- set window name for Java Apps compat.
-- startupHook = startupHook desktopConfig >> setWMName "LG3D"

import XMonad.Hooks.SetWMName

import XMonad.Util.EZConfig
import qualified XMonad.StackSet as W

-- dzen!!
import XMonad.Hooks.DynamicLog
import XMonad.Util.Loggers
import Text.Printf

import System.IO
import XMonad.Hooks.UrgencyHook
import XMonad.Hooks.FadeInactive
import XMonad.Util.Run

-- Cycle between workspaces
import XMonad.Actions.CycleWS
import XMonad.Actions.GridSelect


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

-- Custom window managehooks
-- https://github.com/rangalo/dotfiles/blob/master/.xmonad/xmonad.hs
import XMonad.Hooks.ManageHelpers (isFullscreen, isDialog, doFullFloat, doCenterFloat)

import XMonad.Util.NamedScratchpad

--- Server mode for sending commands to xmonad 
-- http://hackage.haskell.org/packages/archive/xmonad-contrib/0.10/doc/html/XMonad-Hooks-ServerMode.html
import XMonad.Hooks.ServerMode
import XMonad.Actions.Commands

-- DynamicWorkspaces
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CopyWindow(copy)



------------------------------------------
-- Focus fix for java apps
-- http://mth.io/posts/xmonad-java-focus/
--
import Control.Monad
atom_WM_TAKE_FOCUS ::
  X Atom
atom_WM_TAKE_FOCUS =
  getAtom "WM_TAKE_FOCUS"

takeFocusX ::
  Window
  -> X ()
takeFocusX w =
  withWindowSet . const $ do
    dpy       <- asks display
    wmtakef   <- atom_WM_TAKE_FOCUS
    wmprot    <- atom_WM_PROTOCOLS
    protocols <- io $ getWMProtocols dpy w
    when (wmtakef `elem` protocols) $
      io . allocaXEvent $ \ev -> do
          setEventType ev clientMessage
          setClientMessageEvent ev w wmprot 32 wmtakef currentTime
          sendEvent dpy w False noEventMask ev

takeTopFocus ::
  X ()
takeTopFocus =
  withWindowSet $ maybe (setFocusX =<< asks theRoot) takeFocusX . W.peek
-- main = xmonad defaultConfig {
--    -- Modify the log hook of your configuration to include a call to
--    -- takeTopFocus before setWMNAme
--    logHook                 = takeTopFocus >> setWMName "LG3D"
-- }
----------------------------------------

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
--
myLogHook h = dynamicLogWithPP $ dzenPP
    {
        ppCurrent           =   dzenColor "#3EB5FF" "black" . wrap "[" "]"
      , ppVisible           =   dzenColor "white" "black" . wrap " " " "
      , ppHidden            =   dzenColor "#999999" "black"
      , ppHiddenNoWindows   =   dzenColor "#444444" "black"
      , ppUrgent            =   dzenColor "red" "black"
      , ppWsSep             =   "  "
      , ppSep               =   "  |  "
      , ppTitle             =   (" " ++) . dzenColor "white" "black" . dzenEscape
      , ppLayout            =  dzenColor "black" "#cccc" . pad
--      , ppLayout            =  ""
      , ppSort              =  mkWsSort getXineramaWsCompare -- [ left : right ] others
--      , ppExtra             =
      , ppOutput            =   hPutStrLn h
    }


xmlLogHook :: Handle -> X ()
xmlLogHook h = dynamicLogWithPP $ dzenPP
  {
      ppCurrent           =   wrap "<ws class='current'>" "</ws>"
    , ppVisible           =   wrap "<ws class='visible'>" "</ws>"
    , ppHidden            =   wrap "<ws class='hidden'>" "</ws>"
    , ppHiddenNoWindows   =   wrap "<ws class='empty'>" "</ws>"
    , ppUrgent            =   wrap "<ws class='urgent'>" "</ws>"
    --, ppWsSep             =   ""
    , ppSep               =   "<section />"
    , ppTitle             =  dzenEscape . wrap "<title>" "</title>"
    , ppLayout            =  dzenColor "black" "#cccc" . pad 
--      , ppLayout            =  ""
    , ppSort              =  mkWsSort getXineramaWsCompare -- [ left : right ] others
    , ppOutput            =  hPutStrLn h
    --, ppExtras = [ padL loadAvg, logCmd "fortune -n 40 -s" ]
  }


_Tall = Tall nmaster delta ratio
  where
    nmaster  = 1
    ratio    = 1/2
    delta    = 3/100


myManageHook = composeAll
    [
-- className =? "MPlayer"        --> doFloat
--     , className =? "Smplayer"       --> doFloat
--     , className =? "Gimp"           --> doFloat
--     , className =? "Gimp"           --> doFloat
--     , className =? "IDEA"           --> doFloat
--     , className =? "Picasa"         --> doFloat
--     , className =? "Eclipse"        --> doCenterFloat
--   , resource  =? "desktop_window" --> doIgnore
     className =? "Keepassx"       --> doCenterFloat
    ,className =? "jetbrains-pycharm" --> doFloat
    ,resource  =? "Do"             --> doIgnore
    ,isFullscreen                  --> doFullFloat
    ,isDialog                      --> doCenterFloat
    ,manageHook gnomeConfig
    ]

myLogHook2 :: X ()
myLogHook2 = fadeInactiveLogHook fadeAmount
	where fadeAmount = 0xdddddddd

main = do
    workspaceBar <- spawnPipe myStatusBar
    xmonad $ gnomeConfig {

        workspaces = myWorkspaces
        , handleEventHook = serverModeEventHook -- ServerMode
        , startupHook = startupHook desktopConfig >> setWMName "LG3D"
        , normalBorderColor = "#dddddd"
--        , focusedBorderColor = "#C8FF63"
        , focusedBorderColor = "#ff0000"
        , modMask = mod4Mask -- windows key
--        , layoutHook = avoidStruts $ noBorders $ layoutHook gnomeConfig ||| simpleTabbed -- avoidStruts for dzen(slightly broken) composed with default gnomeConfig
        , layoutHook = smartBorders (layoutHook gnomeConfig)
--       , layoutHook = avoidStruts $ desktopLayoutModifiers $ (Tall) ||| ( Mirror _Tall)  ||| ( noBorders Full )
--        , layoutHook = avoidStruts $ Tall |||  Mirror _Tall  ||| ( noBorders Full )
--        , layoutHook = layoutHook gnomeConfig ||| Dishes ||| simpleTabbed
        ,manageHook = myManageHook
        , logHook = do
            takeTopFocus
            setWMName "LG3D"
            myLogHook workspaceBar
--	    myLogHook2
            logHook desktopConfig -- send data to Gnome
        } `additionalKeysP` myKeys

myWorkspaces = ["1","2","3","4","5","6","7","8","9","10"]
spawnApps =
  [
  "rubymine",
  "pycharm",
  "evolution",
  "pidgin",
  "virtualbox",
  "gnome-terminal",
  "chrome",
  "netbeans",
  "gedit",
  "sublime",
  "firefox",
  "rhythmbox",
  "pgadmin3",
  "gnome-screenshot --interactive",
  "keepassx",
  "speedcrunch"
  ]

myKeys =
    [
    -- other additional keys
    ( "M-S-q" ,io (exitWith ExitSuccess))
    , ( "M-S-l" , spawn "gnome-screensaver-command --lock" )
    ,( "M-q" , spawn "xmonad --recompile && xmonad --restart") -- Manually force this due to failing on not being in path, despite being in PATH. FIXME
    ,("M-g",  spawn "chrome")
    ,("M-y",  spawn "chrome 'http://www.youtube.com/view_all_playlists'")
--    , ( "M-n", namedScratchpadAction scratchpads "notes" )
--    , ( "M-o", namedScratchpadAction scratchpads "calc" )
    , ( "M-f",  promptSearch P.defaultXPConfig google )
    , ( "M-S-t",  promptSearch P.defaultXPConfig ticketwise )
    , ( "M-`",  toggleWS )
    , ( "M-<Tab>", nextWS )
    , ( "M-S-<Tab>", prevWS )
    , ( "M1-<Tab>",  windows W.focusDown )
    , ( "M1-S-<Tab>",  windows W.focusUp )
    , ( "M-S-s", goToSelected gsconfig2 )
    , ( "M-S-a", bringSelected gsconfig3 )
    , ( "M-x", spawnSelected defaultGSConfig spawnApps  )
--      , ( "M-S-d", gridSelectWindow defaultGSConfig )
    --,("M-t",  spawn "gnome-terminal")
    , ( "M-i", addWorkspace "dummy" )
    , ( "M-S-<Backspace>", removeWorkspace)
    , ( "M-v" , selectWorkspace P.defaultXPConfig)
    , ( "M-m" , withWorkspace P.defaultXPConfig (windows . W.shift))
    , ( "M-S-m", withWorkspace P.defaultXPConfig (windows . copy))
    , ( "M-S-r",  renameWorkspace P.defaultXPConfig)
    ]
    ++ -- important since ff. is a list itself, can't just put inside above list
    [
    (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "1234567890"
         , (otherModMasks, action) <- [ ("", windows . W.greedyView) -- was W.greedyView
                                      , ("S-", windows . W.shift)]
    ]

gsconfig3 = (buildDefaultGSConfig bwColorizer) { gs_cellheight = 50, gs_cellwidth = 200, gs_navigate = navNSearch }
gsconfig2 = (buildDefaultGSConfig customAColorizer) { gs_cellheight = 50, gs_cellwidth = 200,  gs_navigate = navNSearch, gs_originFractX = 1, gs_originFractY = 0.5 }

customAColorizer :: Window -> Bool -> X (String, String)
--customAColorizer w active = 
--    do classname <- runQuery className w
--      if active
--        then return ("#FFFFFF", "#FFFFFF")
--        else return (printf "%02x" "#CCCCCC")
customAColorizer w active = return ("#FFFFFF", "#CCCCCC")
        --else return (printf "%02x" "#CCCCCC")


        --if active 
        --    then return "#FFFFFF"
        --    else return "#CCCCCC"


 -- | A green monochrome colorizer based on window class
greenColorizer = colorRangeFromClassName
                      black            -- lowest inactive bg
                      (0x70,0xFF,0x70) -- highest inactive bg
                      black            -- active bg
                      white            -- inactive fg
                      white            -- active fg
   where black = minBound
         white = maxBound

bwColorizer = colorRangeFromClassName
                      black            -- lowest inactive bg
                      (0xAA,0xAA,0xAA) -- highest inactive bg
                      white            -- active bg
                      white            -- inactive fg
                      (0xFF, 0x00,0x00)             -- active fg
   where black = minBound
         white = maxBound
