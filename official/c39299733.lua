--運命の戦車
--Fortune Chariot
--scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	aux.AddUnionProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_FAIRY),false)
	--Direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--Damage reduce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(aux.ChangeBattleDamage(1,HALF_DAMAGE))
	c:RegisterEffect(e2)
end
function s.rdcon(e)
	local c,tp=e:GetHandler():GetEquipTarget(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end