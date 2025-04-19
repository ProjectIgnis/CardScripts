--道化傀儡王 パントミーメ
--Jester Puppet King Pantomime
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.atkcon)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(s.ind)
	c:RegisterEffect(e2)
end
function s.atkcon(e)
	local bc=e:GetHandler():GetBattleTarget()
	return bc and not bc:IsControler(e:GetHandlerPlayer()) and bc:IsFaceup() and bc:IsRelateToBattle() and e:GetHandler():IsRelateToBattle()
end
function s.atkval(e,c)
	return e:GetHandler():GetBattleTarget():GetAttack()
end
function s.ind(e,c)
	return c:IsType(TYPE_SYNCHRO)
end