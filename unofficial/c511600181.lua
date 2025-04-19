--フュージョン・オブ・ファイア (Anime)
--Fusion of Fire (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_SALAMANGREAT),nil,s.fextra))
end
s.listed_series={0x119}
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsFaceup),tp,0,LOCATION_ONFIELD,nil)
end