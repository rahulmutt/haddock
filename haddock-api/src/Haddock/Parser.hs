{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE StandaloneDeriving
             , FlexibleInstances, UndecidableInstances
             , IncoherentInstances #-}
{-# LANGUAGE LambdaCase #-}
-- |
-- Module      :  Haddock.Parser
-- Copyright   :  (c) Mateusz Kowalczyk 2013,
--                    Simon Hengel      2013
-- License     :  BSD-like
--
-- Maintainer  :  haddock@projects.haskell.org
-- Stability   :  experimental
-- Portability :  portable

module Haddock.Parser ( parseParas
                      , parseString
                      , parseIdent
                      ) where

import qualified Documentation.Haddock.Parser as P
import ETA.Main.DynFlags (DynFlags)
import ETA.Utils.FastString (mkFastString)
import Documentation.Haddock.Types
import ETA.Parser.Lexer (mkPState, unP, ParseResult(POk))
import ETA.Parser.Parser (parseIdentifier)
import ETA.BasicTypes.RdrName (RdrName)
import ETA.BasicTypes.SrcLoc (mkRealSrcLoc, unLoc)
import ETA.Utils.StringBuffer (stringToStringBuffer)

parseParas :: DynFlags -> String -> MetaDoc mod RdrName
parseParas d = overDoc (P.overIdentifier (parseIdent d)) . P.parseParas

parseString :: DynFlags -> String -> DocH mod RdrName
parseString d = P.overIdentifier (parseIdent d) . P.parseString

parseIdent :: DynFlags -> String -> Maybe RdrName
parseIdent dflags str0 =
  let buffer = stringToStringBuffer str0
      realSrcLc = mkRealSrcLoc (mkFastString "<unknown file>") 0 0
      pstate = mkPState dflags buffer realSrcLc
  in case unP parseIdentifier pstate of
    POk _ name -> Just (unLoc name)
    _ -> Nothing
