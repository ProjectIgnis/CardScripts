--E・HERO ネクロダークマン (Anime)
--Elemental HERO Necroshade (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Once while this card is in the GY, you can Normal Summon 1 "Elemental HERO" monster without Tributing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCountLimit(1)
	e1:SetCondition(s.ntcon)
	e1:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO}
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsSetCard(SET_ELEMENTAL_HERO)
end
