--Zefranji, Prime of the Yang Zing
--AlphaKretin
function c210210503.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,c210210503.matfilter,1,1,c210210503.matfilter,1,99)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c,false)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c210210503.descon)
	e1:SetTarget(c210210503.destg)
	e1:SetOperation(c210210503.desop)
	c:RegisterEffect(e1)
	--to scale
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c210210503.pencon)
	e2:SetTarget(c210210503.pentg)
	e2:SetOperation(c210210503.penop)
	c:RegisterEffect(e2)
	--tuner
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c210210503.tuntg)
	e3:SetOperation(c210210503.tunop)
	c:RegisterEffect(e3)
end
function c210210503.matfilter(c,lc,stype,tp)
	return c:IsSetCard(0xc4,lc,stype,tp) or c:IsSetCard(0x9e,lc,stype,tp)
end
function c210210503.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) or e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
function c210210503.desfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0xc4) or c:IsSetCard(0x9e))
end
function c210210503.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and c210210503.desfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210210503.desfilter,tp,LOCATION_ONFIELD,0,1,nil) and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,c210210503.desfilter,tp,LOCATION_ONFIELD,0,1,3,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
function c210210503.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local num=Duel.Destroy(g,REASON_EFFECT)
	if num>0 and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) then
		local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,num,nil)
		if tg:GetCount()>0 then
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
		end
	end
end
function c210210503.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
function c210210503.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
function c210210503.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckLocation(tp,LOCATION_PZONE,0) and not Duel.CheckLocation(tp,LOCATION_PZONE,1) then return end
	Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function c210210503.tunfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x9e) or c:IsSetCard(0xc4)) and not c:IsType(TYPE_TUNER)
end
function c210210503.tuntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c210210503.tunfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c210210503.tunfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,c210210503.tunfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c210210503.tunop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
		e1:SetValue(TYPE_TUNER)
		tc:RegisterEffect(e1)
	end
end