--セブンス・ワンダー・フュージョン
--Sevens Wonder Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,nil,s.mfilter,s.fextra,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE+LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.checkmat(tp,sg,fc)
	return sg:IsExists(Card.IsCode,1,nil,CARD_SEVENS_ROAD_MAGICIAN)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE+LOCATION_MZONE,0,nil),s.checkmat
end