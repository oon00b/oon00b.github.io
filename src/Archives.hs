module Archives (
    Frequency(..)
    , Archives(..)
    , getDate
    , formatDate
    , getArchives
    , renderArchives
    , archivesRules
) where

import Hakyll

import qualified Data.Map.Lazy as Map

import qualified Data.Time as Time

import Control.Monad

data Frequency = Monthly | Yearly deriving (Enum, Eq, Ord, Bounded)

data Archives = Archives {
    frequency :: Frequency
    , archivesMakeId :: (Frequency -> Time.Day -> Identifier)
    , archivesMap :: [(Time.Day, [Identifier])]
}

getDate :: (MonadMetadata m, MonadFail m) => Identifier -> m Time.Day
getDate post = getItemUTC Time.defaultTimeLocale post
    >>= return . Time.utctDay

formatDate :: Time.Day -> String -> String
formatDate date format = Time.formatTime Time.defaultTimeLocale format date

getArchives :: (MonadMetadata m, MonadFail m) =>
    Pattern
    -> Frequency
    -> (Frequency -> Time.Day -> Identifier)
    -> m Archives
getArchives pattern freq makeid = do
    let acelem post = do
            date <- fmap tokey $ getDate post
            return (date, [post])

        tokey date =
            let (y, m, _d) = Time.toGregorian date
            in case freq of
                Yearly -> Time.fromGregorian y 1 1
                Monthly -> Time.fromGregorian y m 1

    amap <- getMatches pattern
        >>= fmap (Map.toList . Map.fromListWith (++)) . mapM acelem

    return $ Archives freq makeid amap

renderArchives ::
    (Frequency -> Time.Day -> [Identifier] -> FilePath -> Compiler String)
    -> Archives
    -> Compiler String
renderArchives renderhtml Archives {
    frequency = freq,
    archivesMakeId = makeid,
    archivesMap = amap} =
    let recentarchives = Map.toDescList $ Map.fromList amap
        f (date, posts) =
            renderhtml freq date posts $ toUrl $ toFilePath $ makeid freq date
    in fmap concat $ mapM f recentarchives

archivesRules :: Archives -> (Frequency -> Time.Day -> Pattern -> Rules()) -> Rules()
archivesRules Archives {
    frequency = freq,
    archivesMakeId = makeid,
    archivesMap = amap} rules = do
    forM_ amap $ \(date, posts) ->
        create [makeid freq date] $ rules freq date $ fromList posts
