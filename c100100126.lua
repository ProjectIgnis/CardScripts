--Ｓｐ－スロウダウン・マシーン
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local d=math.floor(ev/300)
	local tc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
	if not tc then return end
	if tc:GetCounter(0x91)<d then tc:RemoveCounter(tp,0x91,tc:GetCounter(0x91),REASON_RULE)	
	else tc:RemoveCounter(tp,0x91,d,REASON_RULE) end	
end
