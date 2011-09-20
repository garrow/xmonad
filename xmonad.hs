-- make sure to edit paths to xmobar and .xmobarrc to match your system.
-- If xmobar is in your $PATH, and its config is in ~/.xmobarrc you don't
-- need the xmobar path or config file, use: xmproc <- spawnPipe "xmobar"
 
--main = do
--    xmproc <- spawnPipe "/usr/bin/xmobar /home/garrowb/.xmonad/xmobarrc"
--    xmonad $ defaultConfig
--        { manageHook = manageDocks <+> manageHook defaultConfig
--        , layoutHook = avoidStruts  $  layoutHook defaultConfig
--        , logHook = dynamicLogWithPP xmobarPP
--                        { ppOutput = hPutStrLn xmproc
--                        , ppTitle = xmobarColor "green" "" . shorten 50
--                        }
--        , modMask = mod4Mask     -- Rebind Mod to the Windows key
--        } `additionalKeys`
--        [ ((mod4Mask .|. shiftMask, xK_z), spawn "xscreensaver-command -lock")
--        , ((controlMask, xK_Print), spawn "sleep 0.2; scrot -s")
--        , ((0, xK_Print), spawn "scrot")
--        ]
--

import XMonad
import XMonad.Config.Gnome

main = xmonad gnomeConfig 
    { 
    modMask = mod4Mask -- windows key
    }

{-
import XMonad
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig
 
main = do
    xmonad $ defaultConfig {
        workspaces = myWorkspaces
        -- skipped
        } `additionalKeysP` myKeys
 
myWorkspaces = ["1","2","3","4","5","6","7","8","9"]
 
myKeys =
    [
    -- other additional keys
    ]
    ++ -- important since ff. is a list itself, can't just put inside above list
    [ (otherModMasks ++ "M-" ++ [key], action tag)
         | (tag, key)  <- zip myWorkspaces "123456789"
         , (otherModMasks, action) <- [ ("", windows . W.view) -- was W.greedyView
                                      , ("S-", windows . W.shift)]
    ]
-}

