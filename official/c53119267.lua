--魔力の棘
--Magical Thorn
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)
end
function s.filter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:GetControler()~=tp and not c:IsPreviousControler(tp)
		and c:IsReason(REASON_DISCARD)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:FilterCount(s.filter,nil,tp)
	Duel.Damage(1-tp,ct*500,REASON_EFFECT)
end
