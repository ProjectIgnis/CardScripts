--Solar Gun Frame - Spear
function c210001504.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c210001504.activate)
	c:RegisterEffect(e1)
	--target and Equip
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c210001504.etg)
	e2:SetOperation(c210001504.eop)
	c:RegisterEffect(e2)
	--attack gain
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	--effect gain
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(210001504,1))
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetHintTiming(TIMING_BATTLE_START)
	e4:SetCondition(c210001504.stdcon)
	e4:SetTarget(c210001504.stdtg)
	e4:SetOperation(c210001504.stdop)
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c210001504.eftg)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
function c210001504.filter(c)
	return c:IsCode(210001500)
end
function c210001504.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c210001504.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	if g and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(210001504,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
	end
end
function c210001504.dfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1f69)
end
function c210001504.etg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return end
	if chk==0 then return Duel.IsExistingTarget(c210001504.dfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	local tc=Duel.SelectTarget(tp,c210001504.dfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function c210001504.eop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local eg=tc:GetEquipGroup()
		if eg and eg:IsExists(Card.IsSetCard,1,nil,0x1f70) then
			Duel.Destroy(eg:Filter(Card.IsSetCard,nil,0x1f70),REASON_EFFECT)
		end
		Duel.BreakEffect()
		Duel.Equip(tp,c,tc)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+0x1fe0000)
		e1:SetLabelObject(tc)
		e1:SetValue(c210001504.eqlimit)
		c:RegisterEffect(e1)
	end
end
function c210001504.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function c210001504.eftg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec==c
end
function c210001504.stdcon()
	return Duel.GetCurrentPhase()==PHASE_BATTLE_START
end
function c210001504.stdf(c,g)
	return g:IsContains(c)
end
function c210001504.stdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cg=e:GetHandler():GetColumnGroup()
	if chkc then return chkc:IsOnField() and c210001504.stdf(chkc,cg) end
	if chk==0 then return Duel.IsExistingTarget(c210001504.stdf,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil,cg) end
	local tc=Duel.SelectTarget(tp,c210001504.stdf,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil,cg)
end
function c210001504.stdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end