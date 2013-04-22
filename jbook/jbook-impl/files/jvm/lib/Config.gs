module Config where

import Lex
import IO
import BinSearch

data ConfigItem = CAttribute String String String              
                | CUnique
                | CKey String String
                | CValue String
   deriving Show

type Configuration = Mapping String [ConfigItem]


getConfiguration :: String -> IO Configuration
getConfiguration filename = do
  let str = openfile filename
  result $ mapping (getConfigs_from_str str)

config_values :: Configuration -> String -> [String]
config_values config section = 
   case maplookup config section of
    Just cs -> map f $ filter isCValue cs
    Nothing -> []
 where f (CValue x) = x
       f (CKey k x) = k ++ " " ++ x

getConfigs_from_str :: String -> [(String,[ConfigItem])]
getConfigs_from_str str = 
  let f1 (x : xs) = (tail x, map (f2 . words) xs)
      f2 ["attribute", typ, name, init] = CAttribute typ name init
      f2 ["external_value"]             = CUnique
      f2 (key : entry : entries)        = CKey key (unwords (entry : entries))
      f2 [name]                         = CValue name
      f2 xs                             = CValue (unwords xs)
      f2 xs       = error ("option " ++ show xs ++ " not supported")
  in map (f1 . filter (not.null) . lines) (seperate '[' str)

isCAttribute :: ConfigItem -> Bool
isCAttribute (CAttribute _ _ _) = True
isCAttribute _                  = False

isCValue :: ConfigItem -> Bool
isCValue (CValue ('#': _ )) = False
isCValue (CKey _ _)         = True
isCValue (CValue _)         = True
isCValue _                  = False

isCUnique :: ConfigItem -> Bool
isCUnique CUnique = True
isCUnique _       = False

isCKey :: String -> ConfigItem -> Bool
isCKey key (CKey key' _) = key == key'
isCKey key _             = False 


cfgGetKey :: Configuration -> String -> String -> String -> String
cfgGetKey config section key otherwise =
   case maplookup config section of
     Just cs -> case filter (isCKey key) cs of
                 (CKey _ name : _) -> name
                 _                 -> otherwise
     _       -> otherwise

