--人界発獣界行きパークガイド
--Park Guide of Humanity
--Scripted by Eerie Code
function c120401052.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--immunity
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_ALWAYS_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c120401052.immtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_DISABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetTarget(c120401052.immtg)
	c:RegisterEffect(e2)
	--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(120401052,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,120401052)
	e3:SetCost(c120401052.thcost)
	e3:SetTarget(c120401052.thtg)
	e3:SetOperation(c120401052.thop)
	c:RegisterEffect(e3)
	--destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c120401052.breptg)
	c:RegisterEffect(e4)
end
c120401052.toss_coin=true
function c120401052.immtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end
function c120401052.thcfilter(c,tp,sc)
	if not (c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()) then return false end
	if sc then
		return Duel.IsExistingMatchingCard(c120401052.thfilter,tp,LOCATION_DECK,0,1,nil,c,sc)
	else
		return Duel.IsExistingMatchingCard(c120401052.thcfilter,tp,LOCATION_HAND,0,1,c,tp,c)
	end
end
function c120401052.thfilter(c,sc1,sc2)
	return c:GetType()==TYPE_SPELL and c:IsAbleToHand()
		and not c:IsCode(sc1:GetCode())
		and not c:IsCode(sc2:GetCode())
end
function c120401052.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c120401052.thcfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc1=Duel.SelectMatchingCard(tp,c120401052.thcfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc2=Duel.SelectMatchingCard(tp,c120401052.thcfilter,tp,LOCATION_HAND,0,1,1,nil,tp,tc1):GetFirst()
	local g=Group.FromCards(tc1,tc2)
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabelObject(Duel.GetOperatedGroup())
end
function c120401052.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c120401052.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g or g:GetCount()~=2 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,c120401052.thfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst(),g:GetNext()):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT) then
		Duel.ConfirmCards(1-tp,tc)
		tc:RegisterFlagEffect(120401052,RESET_EVENT+0x5c0000+RESET_PHASE+PHASE_END,0,1)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EFFECT_SEND_REPLACE)
		e2:SetTarget(c120401052.reptg)
		e2:SetReset(RESET_EVENT+0x5c0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_CHAINING)
		e3:SetCondition(c120401052.actcon)
		e3:SetOperation(c120401052.actop)
		e3:SetLabelObject(tc)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(e:GetHandler())
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVED)
		e4:SetCondition(c120401052.damcon)
		e4:SetOperation(c120401052.damop)
		e4:SetLabelObject(tc)
		e4:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e4,tp)
	end
end
function c120401052.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_COST) and c:GetControler()~=c:GetOwner() end
	c:ResetFlagEffect(120401052+100)
	Duel.Damage(c:GetControler(),2000,REASON_EFFECT)
	return false
end
function c120401052.actcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler()==e:GetLabelObject() and re:GetHandler():GetFlagEffect(120401052)~=0
end
function c120401052.actop(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():RegisterFlagEffect(120401052+100,RESET_CHAIN,0,1)
	e:Reset()
end
function c120401052.damcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetHandler()==e:GetLabelObject() and re:GetHandler():GetFlagEffect(120401052+100)~=0
end
function c120401052.damop(e,tp,eg,ep,ev,re,r,rp)
	re:GetHandler():ResetFlagEffect(120401052+100)
	Duel.Damage(tp,2000,REASON_EFFECT)
	e:Reset()
end
function c120401052.breptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReason(REASON_BATTLE) end
	if Duel.SelectYesNo(tp,aux.Stringid(120401052,1)) then
		local res=Duel.TossCoin(tp,1)
		return res==0
	else return false end
end
