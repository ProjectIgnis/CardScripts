--Ａｉラブ融合 (Anime)
--A.I. Love Fusion (Anime)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_IGNISTER),nil,s.fextra)
	c:RegisterEffect(e1)
end
s.listed_series={0x135}
function s.filter(c,e)
	return c:IsFaceup() and c:IsLinkMonster() and c:IsAbleToGrave() and c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsImmuneToEffect(e) 
end
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsControler,nil,1-tp)<=1
end
function s.fextra(e,tp,mg)
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil,e)
	if g and #g>0 then
			return g,s.fcheck
	end
	return nil
end