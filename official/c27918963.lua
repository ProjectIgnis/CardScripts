--修験の妖社
--Yosen Training Grounds
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0x33)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--counter
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.ctcon)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	--counter
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,id)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
end
s.listed_series={0xb3}
s.counter_place_list={0x33}
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FilterFaceupFunction(Card.IsSetCard,0xb3),1,nil)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x33,1)
end
function s.filter1(c)
	return c:IsFaceup() and c:IsSetCard(0xb3)
end
function s.filter2(c)
	return c:IsSetCard(0xb3) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=e:GetHandler():IsCanRemoveCounter(tp,0x33,1,REASON_COST)
		and Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_MZONE,0,1,nil)
	local b2=e:GetHandler():IsCanRemoveCounter(tp,0x33,3,REASON_COST)
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif b1 then
		op=Duel.SelectOption(tp,aux.Stringid(id,1))
	else
		op=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:GetHandler():RemoveCounter(tp,0x33,1,REASON_COST)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:GetHandler():RemoveCounter(tp,0x33,3,REASON_COST)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if e:GetLabel()==0 then
		local g=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_MZONE,0,nil)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(300)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter2),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
