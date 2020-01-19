--偽物のわな
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,tp)
	return c:IsType(TYPE_TRAP) and c:IsControler(tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and #tg==tc and tg:IsExists(s.cfilter,1,e:GetHandler(),tp)
end
function s.cffilter(c,tp)
	return c:IsFacedown() and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	local fg=tg:Filter(s.cffilter,nil,tp)
	Duel.ConfirmCards(1-tp,fg)
	local reg=tg:Filter(s.cfilter,e:GetHandler(),tp)
	local tc=reg:GetFirst()
	for tc in aux.Next(reg) do
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTarget(s.reptg)
	e1:SetValue(s.repvalue)
	e1:SetOperation(s.repop)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
function s.repfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re==e:GetLabelObject() and eg:IsExists(s.repfilter,1,nil) end
	return true
end
function s.repvalue(e,c)
	return c:GetFlagEffect(id)~=0
end
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
