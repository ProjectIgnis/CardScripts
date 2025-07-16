--聖なる解呪師
--Disenchanter
local s,id=GetID()
function s.initial_effect(c)
	--Remove 1 Spell Counter from anywhere on the field, and if you do, return 1 face-up Spell on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.rthtg)
	e1:SetOperation(s.rthop)
	c:RegisterEffect(e1)
end
s.counter_list={COUNTER_SPELL}
function s.rthfilter(c)
	return c:IsSpell() and c:IsFaceup() and c:IsAbleToHand()
end
function s.rthtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rthfilter(chkc) end
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_SPELL,1,REASON_EFFECT)
		and Duel.IsExistingTarget(s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,s.rthfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
end
function s.rthop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if Duel.RemoveCounter(tp,1,1,COUNTER_SPELL,1,REASON_EFFECT) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end