--とどまらぬ大地
--Shifting Land
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.lpregister)
	c:RegisterEffect(e1)
	--Your LP becomes equal to the total ATK of all monsters you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.lpop)
	c:RegisterEffect(e2)
	--Your LP become equal to the value at activation when this card leaves the field
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.leavecon)
	e3:SetOperation(s.leaveop)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	--Loop prevention (Ravenous Tarantual handling)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_CANNOT_TRIGGER)
	e4:SetCondition(s.excon)
	c:RegisterEffect(e4)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EFFECT_CANNOT_SUMMON)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(1,1)
	e5:SetTarget(s.sumlimit)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e6)
	local e7=e5:Clone()
	e7:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	c:RegisterEffect(e7)
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
	e8:SetCode(EFFECT_CANNOT_ACTIVATE)
	e8:SetRange(LOCATION_SZONE)
	e8:SetTargetRange(1,1)
	e8:SetValue(s.aclimit)
	c:RegisterEffect(e8)
end
function s.lpregister(e,tp,eg,ep,ev,re,r,rp)
	local lp=Duel.GetLP(tp)
	e:SetLabel(lp)
end
function s.filter(c,tid)
	return c:IsHasEffect(90162951) and c:GetFieldID()>tid
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	Duel.AdjustInstantly()
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
function s.leavecon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,id),tp,LOCATION_SZONE,0,1,e:GetHandler())
end
function s.leaveop(e,tp,eg,ep,ev,re,r,rp)
	local lp=e:GetLabelObject():GetLabel()
	Duel.SetLP(tp,lp)
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