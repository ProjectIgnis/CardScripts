--電磁双剣
--Magnet Twin Saber
--Scripted by YoshiDuels
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
	--extra attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetCondition(s.condition)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={160211025}
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ROCK) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.condition(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsCode(160211025)
end