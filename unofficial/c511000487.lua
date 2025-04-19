--ヒーロー・ダイス
--Hero Dice
local s,id=GetID()
function s.initial_effect(c)
	--Roll die to apply effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ELEMENTAL_HERO}
s.roll_dice=true
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() and chkc:IsSetCard(SET_ELEMENTAL_HERO) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsSetCard,SET_ELEMENTAL_HERO),tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsSetCard,SET_ELEMENTAL_HERO),tp,LOCATION_MZONE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local dice=Duel.TossDice(tp,1)
		--Take damage equal to target monster's ATK
		if dice==1 then
			Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)
		--Destroy 1 Spell you control
		elseif dice==2 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell),tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSpell),tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
			Duel.Destroy(dg,REASON_EFFECT)
		--Destroy 1 monster you control
		elseif dice==3 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_MZONE,0,1,e:GetHandler()) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,LOCATION_MZONE,0,1,1,nil)
			Duel.Destroy(dg,REASON_EFFECT)
		--Destroy 1 monster your opponent controls
		elseif dice==4 and Duel.IsExistingMatchingCard(Card.IsMonster,tp,0,LOCATION_MZONE,1,nil) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,Card.IsMonster,tp,0,LOCATION_MZONE,1,1,nil)
			Duel.Destroy(dg,REASON_EFFECT)
		--Destroy 1 Spell your opponent controls
		elseif dice==5 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD,1,e:GetHandler()) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSpell),tp,0,LOCATION_ONFIELD,1,1,e:GetHandler())
			Duel.Destroy(dg,REASON_EFFECT)
		--Target monster can attack directly this turn
		elseif dice==6 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end