--Kyoko's Spear
function c210533314.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsCode,210533305))
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c210533314.damcon)
	e3:SetOperation(c210533314.damop)
	c:RegisterEffect(e3)
	--actlimit
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,1)
	e4:SetValue(1)
	e4:SetCondition(c210533314.actcon)
	c:RegisterEffect(e4)
end
c210533314.listed_names={210533305}
function c210533314.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cet=c:GetEquipTarget()
	return ep~=tp and cet==Duel.GetAttacker() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsPosition(POS_DEFENSE)
end
function c210533314.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=Duel.GetBattleDamage(ep)
	Duel.ChangeBattleDamage(ep,dam*2)
end
function c210533314.actcon(e)
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget() or Duel.GetAttackTarget()==e:GetHandler():GetEquipTarget()
end