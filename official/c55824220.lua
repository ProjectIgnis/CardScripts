--輝石融合
--Pyroxene Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,SET_GEM_KNIGHT)))
end
s.listed_series={SET_GEM_KNIGHT}