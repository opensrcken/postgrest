module Feature.DeleteSpec where

import Test.Hspec
import Test.Hspec.Wai
import Text.Heredoc

import Network.HTTP.Types
import Network.Wai (Application)

spec :: SpecWith Application
spec =
  describe "Deleting" $ do
    context "existing record" $ do
      it "succeeds with 204 and deletion count" $
        request methodDelete "/items?id=eq.1" [] ""
          `shouldRespondWith` ResponseMatcher {
            matchBody    = Nothing
          , matchStatus  = 204
          , matchHeaders = ["Content-Range" <:> "*/1"]
          }

      it "actually clears items ouf the db" $ do
        _ <- request methodDelete "/items?id=lt.15" [] ""
        get "/items"
          `shouldRespondWith` ResponseMatcher {
            matchBody    = Just [str|[{"id":15}]|]
          , matchStatus  = 200
          , matchHeaders = ["Content-Range" <:> "0-0/1"]
          }

    context "known route, unknown record" $
      it "fails with 404" $
        request methodDelete "/items?id=eq.101" [] "" `shouldRespondWith` 404

    context "totally unknown route" $
      it "fails with 404" $
        request methodDelete "/foozle?id=eq.101" [] "" `shouldRespondWith` 404
