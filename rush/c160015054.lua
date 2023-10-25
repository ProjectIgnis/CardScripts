--波涛融合
--Wave Fusion
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,s.filter,s.mfilter,s.fextra,Fusion.ShuffleMaterial)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsRace(RACE_FISH)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,5,nil)
end
function s.mfilter(c)
	return s.filter(c) and c:IsLocation(LOCATION_GRAVE|LOCATION_MZONE) and c:IsAbleToDeck()
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_GRAVE|LOCATION_MZONE,0,nil)
end
