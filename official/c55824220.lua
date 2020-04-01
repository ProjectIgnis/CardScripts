--輝石融合
--Pyroxene Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	c:RegisterEffect(Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0x1047)))
end
s.listed_series={0x1047}
