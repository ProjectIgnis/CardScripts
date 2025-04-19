--ローズ・ブリザード (Anime)
--Rose Blizzard (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Change attacking monster to Defense Position and negate attack
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc and tc:IsCanChangePosition() and not tc:IsDefensePos()  end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,0,0)>0 then
		Duel.NegateAttack()
	end
end