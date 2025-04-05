--アステカの石像
--Stone Statue of the Aztecs
local s,id=GetID()
function s.initial_effect(c)
	--Double damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetCondition(s.dcon)
	e1:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e1)
end
function s.dcon(e)
	return Duel.GetAttackTarget()==e:GetHandler()
end