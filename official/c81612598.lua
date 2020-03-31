--メタルフォーゼ・アダマンテ
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xe1),aux.FilterBoolFunction(Card.IsAttackBelow,2500))
end
s.listed_series={0xe1}
s.material_setcode=0xe1
