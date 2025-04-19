--ゴゴゴデクシア (Manga)
--Gogogo Dexia (Manga)
--Scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
	--Pos change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_POSITION)
	e1:SetCondition(s.condition)
	e1:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e1)
	--Cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetCondition(s.condition)
	e2:SetValue(s.atlimit)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511005624),e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.atlimit(e,c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_EARTH)
end