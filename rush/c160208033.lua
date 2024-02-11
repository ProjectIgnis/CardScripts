--楽姫の演舞
--Music Princess's Dance
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsRace(RACE_WARRIOR)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,5,nil)
end
function s.mfilter(c)
	return c:IsLocation(LOCATION_GRAVE|LOCATION_HAND) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_HAND,0,nil)
end