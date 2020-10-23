module Index.Archives (
    buildArchives
) where

import Hakyll

import qualified Data.Map.Lazy as Map

import qualified Data.Time as Time

import Data.List

import Control.Monad

import Util
import Index

type Archives = Map.Map String [Identifier]

getArchives :: (MonadMetadata m, MonadFail m) => m Archives
getArchives = getMatches postPattern
    >>= mapM archivesElem
    >>= return . Map.fromListWith union

archivesElem :: (MonadMetadata m, MonadFail m) => Identifier -> m (String, [Identifier])
archivesElem post = do
    ym <- getYearAndMonth post
    return (ym, [post])

getYearAndMonth :: (MonadMetadata m, MonadFail m) => Identifier -> m String
getYearAndMonth post = getItemUTC Time.defaultTimeLocale post
    >>= return . Time.formatTime Time.defaultTimeLocale "%Y/%m" . Time.utctDay

archivesRules :: Archives -> Rules()
archivesRules ac = forM_ (Map.toList ac) archivesElemRules

archivesElemRules :: (String, [Identifier]) -> Rules()
archivesElemRules (date, posts) =
    create [fromFilePath $ "blog/" ++ date ++ "/index.html"] $ do
        route idRoute
        compile $ postIndexCompiler ("Archive: " ++ date) $ fromList posts

toYearly :: Archives -> Archives
toYearly ac =
    Map.fromListWith union $ map (\(date, posts) -> (takeWhile (\a -> a /= '/') date, posts)) $ Map.toList ac

buildArchives :: Rules()
buildArchives = do
    create [fromFilePath "blog/index.html"] $ do
        route idRoute
        compile $ postIndexCompiler "Blog" postPattern

    monthly <- getArchives
    archivesRules monthly

    archivesRules $ toYearly monthly
