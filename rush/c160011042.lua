--クウェルティ・キーブレード
--QWERTY Keyblade
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(s.condition)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and not c:IsMaximumModeSide()
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_SPELL),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*200
end
function s.condition(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsAttribute(ATTRIBUTE_DARK)
end