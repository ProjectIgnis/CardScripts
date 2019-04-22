--メタルフォーゼ・カーディナル
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,0xe1),1,aux.FilterBoolFunction(Card.IsAttackBelow,3000),2)
end
s.material_setcode=0xe1
