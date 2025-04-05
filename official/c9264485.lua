--ホルスのしもべ
--Horus' Servant
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent cannot target "Horus the Black Flame Dragon" monsters on the field with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsSetCard(SET_HORUS_BLACK_FLAME_DRAGON) end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
end
s.listed_series={SET_HORUS_BLACK_FLAME_DRAGON}