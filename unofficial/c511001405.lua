--D/D Swirl Slime (anime)
--rescripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--fusion summon
	local params = {nil,Fusion.CheckWithHandler(Fusion.InHandMat(aux.FilterBoolFunction(Card.IsSetCard,SET_DD))),nil,nil,Fusion.ForcedHandler}
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(Fusion.SummonEffTG(table.unpack(params)))
	e1:SetOperation(Fusion.SummonEffOP(table.unpack(params)))
	c:RegisterEffect(e1)
end
s.listed_series={0xaf}