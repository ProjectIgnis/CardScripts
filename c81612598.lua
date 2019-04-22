--メタルフォーゼ・アダマンテ
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xe1),aux.FilterBoolFunction(Card.IsAttackBelow,2500))
end
s.material_setcode=0xe1
