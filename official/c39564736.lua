--重錬装融合
--Fullmetalfoes Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Fusion.CreateSummonEff(c,aux.FilterBoolFunction(Card.IsSetCard,0xe1))
	c:RegisterEffect(e1)
end
s.listed_series={0xe1}
