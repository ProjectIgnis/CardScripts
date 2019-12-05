--「A」細胞培養装置
--"A" Cell Incubator
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_REMOVE_COUNTER+0x100e)
	e2:SetOperation(s.ctop1)
	c:RegisterEffect(e2)
	--counter2
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.ctcon2)
	e3:SetOperation(s.ctop2)
	c:RegisterEffect(e3)
end
s.counter_place_list={0x100e}
function s.ctop1(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_NEED_ENABLE+0x100e,1)
end
function s.ctcon2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(0x100e)
	e:SetLabel(ct)
	return e:GetHandler():IsReason(REASON_DESTROY) and ct>0
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g==0 then return end
	for i=1,ct do
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		local sg=g:Select(tp,1,1,nil)
		sg:GetFirst():AddCounter(0x100e,1)
	end
end
