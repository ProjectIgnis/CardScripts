--炎装フレットベルジュ
--Flame Arms - Fretberge
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter)
	--atk up
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	--cannot be battle target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.tg)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:GetOriginalRace()==RACE_PSYCHIC and not c:IsMaximumModeSide()
end
function s.tg(e,c)
	local g=c:GetEquipGroup()
	return c:IsFaceup() and not g:IsExists(Card.IsSpell,1,nil)
end