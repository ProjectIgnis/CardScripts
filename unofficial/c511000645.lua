--サービスエース
--Service Ace
local s,id=GetID()
function s.initial_effect(c)
	--remove
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetTargetCard(g)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
		local op=Duel.SelectOption(1-tp,70,71,72)
		Duel.ConfirmCards(1-tp,tc)
		Duel.ShuffleHand(tp)
		if (op~=0 and tc:IsMonster()) or (op~=1 and tc:IsSpell()) or (op~=2 and tc:IsTrap()) then
			Duel.Damage(1-tp,1500,REASON_EFFECT)
		end
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end