--ミラクル・コンタクト
--Miracle Contact (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:ListsCodeAsMaterial(CARD_NEOS)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
