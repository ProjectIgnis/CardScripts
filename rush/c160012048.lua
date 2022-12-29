--バイスラッシャー
--Vice Slasher
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--cannot direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and not c:IsMaximumModeSide()
		and Duel.IsExistingMatchingCard(s.eqfilter2,c:GetControler(),LOCATION_MZONE,0,1,c,c:GetCode())
end
function s.eqfilter2(c,code)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_NORMAL) and c:IsCode(code) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.value(e,c)
	local c=e:GetHandler():GetEquipTarget()
	return c:GetBaseAttack()
end