--Shifting Land
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.lpop)
	c:RegisterEffect(e1)
	--copy
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	--loop prevention
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetCondition(s.excon)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetTargetRange(1,1)
	e4:SetCode(EFFECT_CANNOT_SUMMON)
	e4:SetTarget(s.sumlimit)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e5)
	local e6=e4:Clone()
	e6:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e6)
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_SZONE)
	e6:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetTargetRange(1,1)
	e6:SetCode(EFFECT_CANNOT_ACTIVATE)
	e6:SetValue(s.aclimit)
	c:RegisterEffect(e6)
end
function s.excon(e)
	return Duel.IsExistingMatchingCard(Card.IsHasEffect,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,90162951)
end
function s.sumlimit(e,c)
	return c:IsHasEffect(90162951)
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsHasEffect(90162951)
end
function s.filter(c,tid)
	return c:IsHasEffect(90162951) and c:GetFieldID()>tid
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,c:GetFieldID())
	Duel.SendtoGrave(sg,REASON_RULE)
	if Duel.IsExistingMatchingCard(Card.IsHasEffect,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,90162951) then Duel.SendtoGrave(c,REASON_RULE) end
	if not c:IsDisabled() then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local sum=g:GetSum(Card.GetAttack)
		Duel.SetLP(tp,sum,REASON_EFFECT)
	end
end
