--炎装フレットベルジュ
--Flame Arms - Fretberge
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Equip only to a Psychic monster
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Increase ATK by 4000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--Opponent cannot target monsters without equip cards as battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.cond)
	e2:SetValue(s.tg)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:GetOriginalRace()==RACE_PSYCHIC and not c:IsMaximumModeSide()
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