{-# LANGUAGE OverloadedStrings #-}

module Model.DbPlayer.Query (
  Region (..),
  Service (..),
  createService,
  regionToInt,
  regionToText,
) where

import qualified Environment.Config as Config

import App (App, AppT (runApp))
import Control.Monad.IO.Class (liftIO)
import Data.Text (Text)
import Database.Persist (selectList, (==.))
import Database.Persist.Sqlite (runSqlite)
import Database.Persist.TH ()
import Model.DbPlayer.Adaptor (fromEntityToDbPlayer)
import Model.DbPlayer.Types

newtype Service = Service
  { getPlayersByRegion :: Region -> App [DbPlayer]
  }

createService :: App Service
createService = do
  pure
    Service
      { getPlayersByRegion = getPlayersByRegion_
      }

data Region
  = NA
  | EU
  | KR

regionToInt :: Region -> Int
regionToInt region =
  case region of
    NA -> 1
    EU -> 2
    KR -> 3

regionToText :: Region -> Text
regionToText region =
  case region of
    NA -> "1"
    EU -> "2"
    KR -> "3"

getPlayersByRegion_ :: Region -> App [DbPlayer]
getPlayersByRegion_ region =
  liftIO $ runSqlite Config.databaseName $ do
    let playerRegion = regionToInt region

    players <- selectList [DbPlayerRegion ==. playerRegion] []

    let dbPlayers = fmap fromEntityToDbPlayer players

    return dbPlayers
