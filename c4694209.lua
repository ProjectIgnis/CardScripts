--カードガード
--Card Guard
local s,id=GetID()
function s.initial_effect(c)
	--summon success
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.addct)
	e1:SetOperation(s.addc)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--attackup
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(s.attackup)
	c:RegisterEffect(e3)
	--destroy rep
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetTarget(s.addct2)
	e4:SetOperation(s.addc2)
	c:RegisterEffect(e4)
end
s.counter_place_list={0x1021}
function s.addct(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,0x1021)
end
function s.addc(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():AddCounter(0x1021+COUNTER_NEED_ENABLE,1)
	end
end
function s.attackup(e,c)
	return c:GetCounter(0x1021)*300
end
function s.addct2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc:IsFaceup() end
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x1021,1,REASON_EFFECT)
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
end
function s.addc2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetCounter(0x1021)==0 then return end
	c:RemoveCounter(tp,0x1021,1,REASON_EFFECT)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		tc:AddCounter(0x1021,1)
		if tc:GetFlagEffect(id)~=0 then return end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EFFECT_DESTROY_REPLACE)
		e1:SetTarget(s.reptg)
		e1:SetOperation(s.repop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
	end
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_REPLACE+REASON_RULE) and e:GetHandler():GetCounter(0x1021)>0 end
	return true
end
function s.repop(e,tp,eg,ep,ev,re,r,rp,chk)
	e:GetHandler():RemoveCounter(tp,0x1021,1,REASON_EFFECT)
end
