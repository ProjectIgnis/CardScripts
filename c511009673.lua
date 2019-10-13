--Sunvine Burial
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x574}
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x574)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFacedown() then
		Duel.ConfirmCards(tp,tc)
		if tc:IsType(TYPE_TRAP) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local g=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode())
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
