--Japanese name
--Release Brainwashing
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Take control of a monster, or negate its effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_TOHAND+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_RELEASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.effcon)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.effconfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE|LOCATION_HAND) and c:IsMonster()
end
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.effconfilter,1,nil)
end
function s.tgfilter(c,tp)
	return c:IsFaceup() and ((c:IsOwner(tp) and c:IsAbleToChangeControler()) or (c:IsOwner(1-tp) and c:IsNegatableMonster()))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.tgfilter(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectTarget(tp,s.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
	if tc:IsOwner(tp) then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,tc,1,tp,0)
	else
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	if tc:IsOwner(tp) then
		if not Duel.GetControl(tc,tp) then return end
		--Return it to the hand during the End Phase
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.SendtoHand(ag,nil,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,1))
	else
		tc:NegateEffects(e:GetHandler(),RESET_PHASE|PHASE_END)
	end
end