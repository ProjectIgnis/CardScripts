--ミラクル・コンタクト
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff(c,s.spfilter,Card.IsAbleToDeck,s.fextra,Fusion.ShuffleMaterial,nil,nil,nil,0,nil,FUSPROC_NOTFUSION))
end
s.listed_series={0x3008}
s.listed_names={CARD_NEOS}
function s.spfilter(c)
	return c:IsSetCard(0x3008) and aux.IsMaterialListCode(c,CARD_NEOS)
end
function s.fextra(e,tp,mg)
	return Duel.GetMatchingGroup(Fusion.IsMonsterFilter(Card.IsAbleToDeck),tp,LOCATION_GRAVE,0,nil)
end
