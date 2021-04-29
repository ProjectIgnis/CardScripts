--幻影融合
--Vision Fusion (Manga)
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x5008),aux.FALSE,s.fextra,nil,nil,nil,2)
	c:RegisterEffect(e1)
end
s.listed_series={0x5008}
function s.mfilter(c)
	return c:IsAbleToGrave() and c:IsFaceup() and c:IsSetCard(0x5008)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_SZONE,0,nil)
end
