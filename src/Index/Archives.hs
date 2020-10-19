module Index.Archives (
    buildArchives
) where

import Hakyll

import qualified Data.Map.Lazy as Map
import qualified Data.Set as Set

import Control.Monad

import Util
import Index

type Archives = Map.Map (String, String) (Set.Set Identifier)

getArchives :: MonadMetadata m => m Archives
getArchives = getMatches postPattern
    >>= return . foldr insertArchive Map.empty

insertArchive :: Identifier -> Archives -> Archives
insertArchive post archives =
    Map.insertWith Set.union (getYearAndMonth post) (Set.singleton post) archives

getYearAndMonth :: Identifier -> (String, String)
getYearAndMonth post = case splitAll "/" $ toFilePath post of
    (_md:_blog:yyyy:mm:_xs) -> (yyyy, mm)
    _  -> error "記事は\"markdown/blog/YYYY/MM/\"内に置いてください"

buildYearlyArchives :: String -> Set.Set Identifier -> Rules()
buildYearlyArchives year posts =
    create [fromFilePath $ "blog/" ++ year ++ "/index.html"] $ do
        route idRoute
        compile $ postIndexCompiler ("Archive: " ++ year) $ fromList $ Set.toList posts

buildMonthlyArchives :: String -> String -> Set.Set Identifier -> Rules()
buildMonthlyArchives year month posts =
    create [fromFilePath $ "blog/" ++ year ++ "/" ++ month ++ "/index.html"] $ do
        route idRoute
        compile $ postIndexCompiler ("Archive: " ++ year ++ "/" ++ month) $ fromList $ Set.toList posts

buildArchives :: Rules()
buildArchives = do
    create [fromFilePath "blog/index.html"] $ do
        route idRoute
        compile $ postIndexCompiler "Blog" postPattern

    archives <- getArchives
    forM_ (Map.toList archives) (\((year, month), posts) -> buildMonthlyArchives year month posts)
