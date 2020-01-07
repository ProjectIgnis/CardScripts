--ポセイドン・オオカブト
local s,id=GetID()
function s.initial_effect(c)
	--chain attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(s.atcon)
	e1:SetOperation(s.atop)
	c:RegisterEffect(e1)
end
function s.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c==Duel.GetAttacker() and bc and  bc:IsRelateToBattle()
		and bc:GetBattlePosition()==POS_FACEUP_ATTACK and c:CanChainAttack(3)
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack(e:GetHandler():GetBattleTarget())
end
