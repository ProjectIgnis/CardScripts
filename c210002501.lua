--Dark Magic Aurora
--designed and scripted by Larry126
function c210002501.initial_effect(c)
	c:SetUniqueOnField(1,0,210002501)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,210002501)
	e1:SetOperation(c210002501.activate)
	c:RegisterEffect(e1)
	--leave replace
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SEND_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTarget(c210002501.reptg)
	e2:SetValue(c210002501.repval)
	e2:SetOperation(c210002501.repop)
	c:RegisterEffect(e2)
end
c210002501.listed_names={46986414,210002501,0xa1,0x10a2}
function c210002501.filter(c)
	return (c:IsSetCard(0x10a2) and c:IsType(TYPE_MONSTER)
		or c:IsSetCard(0xa1) and c:IsType(TYPE_SPELL))
		and c:IsAbleToHand() and not c:IsCode(210002501)
end
function c210002501.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(c210002501.filter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and Duel.SelectEffectYesNo(tp,e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c210002501.cfilter(c)
	return c:IsFaceup() and c:IsCode(46986414)
end
function c210002501.tfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and aux.IsCodeListed(c,46986414)
		and c:IsControler(tp) and c:IsLocation(LOCATION_ONFIELD)
		and not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
end
function c210002501.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(c210002501.tfilter,1,nil,tp)
		and Duel.GetFlagEffect(e:GetHandlerPlayer(),210002501)==0
		and Duel.IsExistingMatchingCard(c210002501.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c,96)
end
function c210002501.repval(e,c)
	return c210002501.tfilter(c,e:GetHandlerPlayer())
end
function c210002501.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,210002501,RESET_PHASE+PHASE_END,0,1)
	Duel.DiscardHand(tp,Card.IsAbleToGrave,1,1,REASON_EFFECT+REASON_REPLACE,nil)
end