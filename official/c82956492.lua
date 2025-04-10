--DDD神託王ダルク
--D/D/D Oracle King d'Arc
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	Fusion.AddProcMixN(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_DD),2)
	c:EnableReviveLimit()
	--damage conversion
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(s.rev)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DD}
s.material_setcode=SET_DD
function s.rev(e,re,r,rp,rc)
	return (r&REASON_EFFECT)~=0
end