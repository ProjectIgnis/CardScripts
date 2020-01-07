--Forbidden Beast Bronn
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
function s.con(e)
	return Duel.IsPlayerAffectedByEffect(e:GetHandlerPlayer(),511000380)
end
