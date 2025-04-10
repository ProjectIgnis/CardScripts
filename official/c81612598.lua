--メタルフォーゼ・アダマンテ
--Metalfoes Adamante
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_METALFOES),aux.FilterBoolFunction(Card.IsAttackBelow,2500))
end
s.listed_series={SET_METALFOES}
s.material_setcode=SET_METALFOES