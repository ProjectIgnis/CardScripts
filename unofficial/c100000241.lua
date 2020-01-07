--フォトン・エスケープ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={31801517}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a:IsOnField() and d and d:IsFaceup() and d:IsControler(tp)
	 and (d:IsSetCard(0x55) or d:IsCode(31801517)) and d:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttackTarget()
	if a:IsFaceup() and a:IsRelateToEffect(e) then
		Duel.Remove(a,POS_FACEUP,REASON_EFFECT)
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)		
	end
end
