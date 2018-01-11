Gdip_ImageSearch(pBitmapHayStack, pBitmapNeedle, ByRef x, ByRef y, Variation=0, sx="", sy="", w="", h="")
{
   static _ImageSearch1, _ImageSearch2
   if !_ImageSearch1
   {
      MCode_ImageSearch1 := "83EC108B44242C9983E20303C28BC88B4424309983E20303C253C1F80255894424148B44244056C1F9023B44244C578944244"
      . "80F8DCA0000008B7C24348D148D000000000FAFC88B442444895424148B54242403C88D1C8A8B4C244C895C24183BC1894424407D7A895C24108D6424"
      . "008B6C2428C744243C000000008D6424008B44243C3B4424380F8D9400000033C985FF7E178BD58BF38B063B02752283C10183C20483C6043BCF7CED8"
      . "B44241C035C24148344243C0103C003C003E8EBC08B4424408B5C24108B4C244C83C00183C3043BC189442440895C24107C928B4424448B5424488B5C"
      . "2418035C241483C2013B54245089542448895C24180F8C5DFFFFFF8B5424548B4424585F5EC702FFFFFFFF5DC700FFFFFFFF83C8FF5B83C410C38B4C2"
      . "4548B5424408B4424585F89118B4C24445E5D890833C05B83C410C3"

      VarSetCapacity(_ImageSearch1, StrLen(MCode_ImageSearch1)//2)
      Loop % StrLen(MCode_ImageSearch1)//2      ;%
         NumPut("0x" SubStr(MCode_ImageSearch1, (2*A_Index)-1, 2), _ImageSearch1, A_Index-1, "char")
   }

   if !_ImageSearch2
   {
      MCode_ImageSearch2 :="83EC1C8B4424443B44244C535556578944241C0F8D760100008B4C24488B5424580FAFC88B4424608B742440894C24188B4C24"
      . "503BCA894C24140F8D320100008B54241833FF897C24108B5C24103B5C2444897C2428895424240F8D4E01000085F6C7442420000000000F8ECD00000"
      . "08B7424348D148A8B4C243003F7897424548D1C0AEB0A8DA424000000008D49008B6C2454B9030000000FB60C19BE030000000FB6342E8D2C013BF50F"
      . "8FA20000002BC83BF10F8C980000008B4C24300FB64C0A028B7424340FB67437028D2C013BF57F7F2BC83BF17C798B4C24300FB64C0A018B7424340FB"
      . "67437018D2C013BF57F602BC83BF17C5A0FB60B8B7424540FB6368D2C013BF57F492BC83BF17C438B4C24208B742440834424540483C10183C20483C3"
      . "0483C7043BCE894C24200F8C5BFFFFFF8B4C24148B7C24288B542424035424488344241001037C244CE9F7FEFFFF8B4C24148B5424588B74244083C10"
      . "13BCA894C24140F8CD2FEFFFF8B4C24508B7C241C8B5C2448015C241883C7013B7C245C897C241C0F8CA5FEFFFF8B5424648B4424685F5EC702FFFFFF"
      . "FF5DC700FFFFFFFF83C8FF5B83C41CC38B5424648B4424685F890A8B4C24185E5D890833C05B83C41CC3"

      VarSetCapacity(_ImageSearch2, StrLen(MCode_ImageSearch2)//2)
      Loop % StrLen(MCode_ImageSearch2)//2      ;%
         NumPut("0x" SubStr(MCode_ImageSearch2, (2*A_Index)-1, 2), _ImageSearch2, A_Index-1, "char")
   }
   
   if (Variation > 255 || Variation < 0)
      return -2

   Gdip_GetImageDimensions(pBitmapHayStack, hWidth, hHeight), Gdip_GetImageDimensions(pBitmapNeedle, nWidth, nHeight)
   
   if !(hWidth && hHeight && nWidth && nHeight)
      return -3
   if (nWidth > hWidth || nHeight > hHeight)
      return -4
   
   sx := (sx = "") ? 0 : sx
   sy := (sy = "") ? 0 : sy
   w := (w = "") ? hWidth-sx : w
   h := (h = "") ? hHeight-sy : h
   
   if (sx+w > hWidth-nWidth)
      w := hWidth-sx-nWidth+1
   
   if (sy+h > hHeight-nHeight)
      h := hHeight-sy-nHeight+1
      
   E1 := Gdip_LockBits(pBitmapHayStack, 0, 0, hWidth, hHeight, Stride1, Scan01, BitmapData1)
   E2 := Gdip_LockBits(pBitmapNeedle, 0, 0, nWidth, nHeight, Stride2, Scan02, BitmapData2)
   if (E1 || E2)
      return -5

   x := y := 0
   if (Variation = 0)
   {
      E := DllCall(&_ImageSearch1, "uint", Scan01, "uint", Scan02, "int", hWidth, "int", hHeight, "int", nWidth, "int", nHeight, "int", Stride1
      , "int", Stride2, "int", sx, "int", sy, "int", w, "int", h, "int*", x, "int*", y)
   }
   else
   {
      E := DllCall(&_ImageSearch2, "uint", Scan01, "uint", Scan02, "int", hWidth, "int", hHeight, "int", nWidth, "int", nHeight, "int", Stride1
      , "int", Stride2, "int", sx, "int", sy, "int", w, "int", h, "int", Variation, "int*", x, "int*", y)
   }
   Gdip_UnlockBits(pBitmapHayStack, BitmapData1), Gdip_UnlockBits(pBitmapNeedle, BitmapData2)
   return (E = "") ? -6 : E
}
