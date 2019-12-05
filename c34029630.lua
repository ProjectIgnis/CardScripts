--漆黒のパワーストーン
--Pitch-Black Power Stone
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	--Activate
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--counter
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target2)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
	--self destroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EFFECT_SELF_DESTROY)
	e4:SetCondition(s.descon)
	c:RegisterEffect(e4)
end
s.counter_place_list={COUNTER_SPELL}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	local c=e:GetHandler()
	if chk==0 then return Duel.IsCanAddCounter(tp,COUNTER_SPELL,3,c) end
	c:AddCounter(COUNTER_SPELL,3)
	if Duel.GetTurnPlayer()==tp and c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
		Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	else
		e:SetProperty(0)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and c:IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT) and tc:IsCanAddCounter(COUNTER_SPELL,1) then
		c:RemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT)
		tc:AddCounter(COUNTER_SPELL,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_SPELL,1)
end
function s.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.filter(chkc) end
	if chk==0 then return e:GetHandler():GetFlagEffect(id)==0 and e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,1,REASON_EFFECT)
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
end
function s.descon(e)
	return e:GetHandler():GetCounter(COUNTER_SPELL)==0
end
