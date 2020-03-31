--ネクロバレーの祭殿
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--disable spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	--self destroy
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_SELF_DESTROY)
	e3:SetCondition(s.sdcon)
	c:RegisterEffect(e3)
end
s.listed_series={0x2e}
s.listed_names={CARD_NECROVALLEY}
function s.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x2e)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
--Debug.Message(tostring(Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)).."|"..tostring(Duel.IsEnvironment(CARD_NECROVALLEY)))
return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) 
		and Duel.IsEnvironment(CARD_NECROVALLEY)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return not c:IsSetCard(0x2e)
end
function s.sdcon(e)
	return not Duel.IsExistingMatchingCard(s.cfilter1,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		or not Duel.IsEnvironment(CARD_NECROVALLEY)
end
