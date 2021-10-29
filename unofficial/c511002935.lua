--妖精ジョー
--Joe the Pixie
local s,id=GetID()
function s.initial_effect(c)
	--0 damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetCondition(s.atkcon)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not bc or (c:GetEffectCount(EFFECT_INDESTRUCTABLE_BATTLE)>0 and not c:IsHasEffect(511010508)) then return false end
	if c:IsAttackPos() and bc:IsAttackPos() and c:GetAttack()<=bc:GetAttack() then return true end
	if c:IsDefensePos() and c:GetDefense()<bc:GetAttack() then return true end
	return false
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(e:GetHandler():GetControler(),0)
end
