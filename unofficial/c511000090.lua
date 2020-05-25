--大地の浸蝕
--Ground Erosion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.reset)
	c:RegisterEffect(e1)
	--Negate effect/Decrease ATK
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--turn
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
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
	c:SetTurnCounter(c:GetTurnCounter()+1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.getflag(g,p)
	local flag = 0
	for c in aux.Next(g) do
		flag = flag|((1<<c:GetSequence())<<16*(c:IsControler(p) and 1 or 0))
	end
	return ~flag
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetTurnCounter()>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local zone=Duel.SelectFieldZone(tp,1,0,LOCATION_MZONE,s.getflag(Duel.GetFieldGroup(tp,0,LOCATION_MZONE),1-tp))
	Duel.SetTargetParam(math.log(zone,2)-16)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	local seq=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local tc=Duel.GetFieldCard(1-tp,LOCATION_MZONE,seq)
	if tc then Duel.NegateRelatedChain(tc,RESET_TURN_SET) end
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
	e2:SetCode(EFFECT_DISABLE_EFFECT)
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
