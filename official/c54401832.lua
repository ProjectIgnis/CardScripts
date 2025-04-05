--メタルフォーゼ・カーディナル
--Metalfoes Crimsonite
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_METALFOES),1,aux.FilterBoolFunction(Card.IsAttackBelow,3000),2)
end
s.listed_series={SET_METALFOES}
s.material_setcode=SET_METALFOES