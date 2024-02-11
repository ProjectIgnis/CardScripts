--幻壊剣チクエディア
--Demolition Sword Constructedea
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	--atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(s.condition)
	e3:SetValue(500)
	c:RegisterEffect(e3)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WYRM) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
	return c:IsFaceup()
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(Card.IsRace,e:GetHandlerPlayer(),LOCATION_GRAVE,0,5,nil,RACE_WYRM)
end