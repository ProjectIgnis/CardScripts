--はぐれネコジェラシー
--Straynge Cat Jealousy
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Negate attack and destroy the attacking monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_STRAYNGE_CAT,160209016}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	return a and a:IsControler(1-tp) and
		((tc and tc:IsFaceup() and tc:IsAttack(0) and tc:IsControler(tp)) or (Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_STRAYNGE_CAT,160209016)))
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local a=Duel.GetAttacker()
	local tc=Duel.GetAttackTarget()
	Duel.NegateAttack()
	if tc and tc:IsCanChangePositionRush() and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)>0 then
			local ct=Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)
			Duel.Damage(1-tp,200*ct,REASON_EFFECT)
		end
	end
end
