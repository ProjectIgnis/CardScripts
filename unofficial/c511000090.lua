--Ground Erosion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.reset)
	c:RegisterEffect(e1)
	--turn
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.turncon)
	e3:SetOperation(s.turnop)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(1082946)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(s.turnop)
	c:RegisterEffect(e4)
	--Negate effect/Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(799183,0))
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabelObject(e1)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	if e:GetHandler():IsLocation(LOCATION_SZONE) then
		e:GetHandler():SetTurnCounter(0)
	end
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()+1
	c:SetTurnCounter(ct)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	if chk==0 then return ct>0 and c:IsAbleToGraveAsCost() end
	Duel.SendtoGrave(c,REASON_COST)
end
function s.getflag(g,tp)
	local flag = 0
	for c in aux.Next(g) do
		flag = flag|((1<<c:GetSequence())<<16*c:GetControler())
	end
	return ~flag
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetTurnCounter()
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_MZONE,s.getflag(Duel.GetFieldGroup(tp,0,LOCATION_MZONE)))
	e:SetLabel(math.log(zone,2)-16)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,0,-ct*500)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	local seq=e:GetLabel()
	local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,seq)
	--effect gain
	Duel.NegateRelatedChain(tc,RESET_TURN_SET)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetLabel(seq)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetTarget(s.eftg)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DISABL_EFFECT)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(-ct*500)
	Duel.RegisterEffect(e3,tp)
end
function s.eftg(e,c)
	return c:GetSequence()==e:GetLabel()
end