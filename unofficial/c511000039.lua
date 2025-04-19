--Synchro Monument
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot disable summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE_SPSUMMON)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTarget(s.target)
	c:RegisterEffect(e2)
	--summon success
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCondition(s.sumcon)
	e3:SetOperation(s.sumsuc)
	c:RegisterEffect(e3)
end
function s.limfilter(c)
	return c:GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.target(e,c)
	return c:GetSummonType()==SUMMON_TYPE_SYNCHRO
end
function s.sumcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.limfilter,1,nil)
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.elimit)
end
function s.elimit(re,rp,tp)
	return not (re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE))
end