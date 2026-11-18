--サイン・ビークル
--Sign Vehicle
local s,id=GetID()
function s.initial_effect(c)
	--Send 1 card from your hand to the Graveyard to negate the attack of 1 monster on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--While in Defense Position, this card can attack your opponent directly.
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(function(e) return e:GetHandler():IsDefensePos() end)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e3)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	local tgct=Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(Card.IsAbleToGrave,nil)
	if chkc then return chkc==a end
	if chk==0 then return not c:IsStatus(STATUS_CHAINING) and tgct>0 and a:IsOnField() and a:IsCanBeEffectTarget(e) end
	Duel.SetTargetCard(tg)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	local tgct=Duel.GetFieldGroup(tp,LOCATION_HAND,0):FilterCount(Card.IsAbleToGrave,nil)
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tgct>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local sc=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		Duel.SendtoGrave(sc,REASON_EFFECT)
		Duel.NegateAttack()
	end
end
