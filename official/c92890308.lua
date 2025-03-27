--ディフォーム
--Morphtransition
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MORPHTRONIC}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d:IsControler(tp) and d:IsFaceup() and d:IsSetCard(SET_MORPHTRONIC)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ta=Duel.GetAttacker()
	local td=Duel.GetAttackTarget()
	if chkc then return chkc==ta end
	if chk==0 then return ta:IsOnField() and ta:IsCanBeEffectTarget(e)
		and td:IsOnField() and td:IsCanBeEffectTarget(e) end
	local g=Group.FromCards(ta,td)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,td,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ta=Duel.GetAttacker()
	local td=Duel.GetAttackTarget()
	if ta:IsRelateToEffect(e) and Duel.NegateAttack() and td:IsFaceup() and td:IsRelateToEffect(e) then
		Duel.ChangePosition(td,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end