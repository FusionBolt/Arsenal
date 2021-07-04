module JSONParser (
    JSONVal(..)
  , parseJSON
)where

import Control.Monad
import Text.ParserCombinators.Parsec

data JSONVal = Array [JSONVal]
        | Dict [(String,JSONVal)]
        | String String
        | Bool Bool
        | Number Integer
        | Null
        deriving (Show, Eq)

interval :: Parser ()
interval = skipMany space >> char ',' >> skipMany space

parseList :: Parser JSONVal
parseList = do
    let parseL = liftM Array $ sepBy parseJSON interval
    char '['
    list <- parseL
    char ']'
    return list

parsePair :: Parser JSONVal
parsePair = do
    String key <- parseString
    skipMany space
    char ':'
    skipMany space
    val <- parseJSON
    return $ Dict [(key,val)]

parseDict :: Parser JSONVal
parseDict = do
              let parseD = liftM Array $ sepBy parsePair interval
              char '{'
              skipMany space
              dict <- parseD
              char '}'
              return dict

parseEscape :: Parser Char
parseEscape = do char '\\'
                 x <- oneOf "\\\"nrt"
                 return $ case x of
                     '\\' -> x
                     '"'  -> x
                     'n'  -> '\n'
                     'r'  -> '\r'
                     't'  -> '\t'

parseString :: Parser JSONVal
parseString = do
                char '"'
                x <- many $ parseEscape <|> noneOf "\"\\"
                char '"'
                return $ String x

parseBool :: Parser JSONVal
parseBool = (string "true" >> return (Bool True))
        <|> (string "false" >> return (Bool False))

parseNumber :: Parser JSONVal
parseNumber = liftM (Number . read) $ many1 digit

parseNull :: Parser JSONVal
parseNull = string "null" >> return Null

parseJSON :: Parser JSONVal
parseJSON = parseList
        <|> parseDict
        <|> parseString
        <|> parseBool
        <|> parseNumber
        <|> parseNull

readJSON :: String -> String
readJSON input = case parse parseJSON "json" input of
    Left err  -> "No match: " ++ show err
    Right val -> "Found value" ++ show val

