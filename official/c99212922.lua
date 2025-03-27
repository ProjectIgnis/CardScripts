--白竜の忍者
--White Dragon Ninja
local s,id=GetID()
function s.initial_effect(c)
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(s.indes)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_series={SET_NINJITSU_ART}
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(SET_NINJITSU_ART)
end
function s.indes(e,c)
	return c:IsSpellTrap()
end