--氷結界の御庭番
--Secret Guards of the Ice Barrier
local s,id=GetID()
function s.initial_effect(c)
	--untargetable
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_ICE_BARRIER))
	e1:SetValue(s.tgval)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ICE_BARRIER}
function s.tgval(e,re,rp)
	return rp~=e:GetHandlerPlayer() and re:IsMonsterEffect()
end