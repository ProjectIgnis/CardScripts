--ラヴ・セーフティ
--Love Safety
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Psychic monster
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Cannot be destroyed by the opponent's card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_STZONE,0)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Opponent cannot target monsters without equip cards as battle target
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.cond)
	e3:SetValue(s.tg)
	c:RegisterEffect(e3)
end
function s.indtg(e,c)
	return c:IsFacedown()
end
function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetOwnerPlayer()
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetBaseAttack()==0 and c:GetBaseDefense()==0 and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.cond(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:GetControler()==e:GetHandlerPlayer()
end
function s.tg(e,c)
	return #c:GetEquipGroup()==0
end