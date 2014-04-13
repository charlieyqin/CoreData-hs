-- | Main entry point to the application.
module Main where
import Data.Char
import System.Process
import System.Cmd as S
import System.Exit
import Text.XML.Light
import Data.Maybe
import Data.List
-- | The main entry point.
data Attribute = Attribute {
                              attrName :: (Maybe String)
                            , attrType :: (Maybe String)
                           } deriving Show
data Entity = Entity {
                        entityName :: (Maybe String)
                      , entityAttributes :: [(Maybe String)]
                      , entityRelationships :: [(Maybe String)]
                     } deriving Show

simpleName s = QName s Nothing Nothing

nameAttr :: Element -> (Maybe String)
nameAttr e = (findAttr $ simpleName "name") e

children :: Element -> [Element]
children e = (findChildren $ simpleName "attribute") e

relChild :: Element -> [Element]
relChild e = (findChildren $ simpleName "relationship") e

relationships :: Element -> [(Maybe String)]
relationships e = (map nameAttr (relChild e))

buildEntity :: Element -> Entity
buildEntity e = (Entity (nameAttr e) (entityAttrs e)  (relationships e))

entityAttrs :: Element -> [(Maybe String)]
entityAttrs e = (map nameAttr (children e))

findEntity :: String -> [Entity] -> (Maybe Entity)
findEntity "" _ = Nothing
findEntity _ [] = Nothing
findEntity s e = find (\(Entity (Just name) _ _) -> name == s) e

main :: IO ()

main = do
  xml <- readFile "TLKCustomerToolKit.xcdatamodeld/TLKCustomerToolKit.xcdatamodel/contents"
  let content     = parseXML xml
      allEntities = concatMap (findElements $ simpleName "entity") (onlyElems content)
      entities    = map buildEntity allEntities
  print entities
