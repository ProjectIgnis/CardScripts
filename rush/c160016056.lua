-- 電脳加速器
-- Accelerator
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(300)
	c:RegisterEffect(e1)
	--Amplifier replacing effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(303660)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
	--Effect cannot be negated
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_DISABLE)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.con(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsOriginalCodeRule(CARD_JINZO)
end