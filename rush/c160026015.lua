--ラワンシスター・ハート
--Lauan Sister Heart
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Monsters on your opponent's field lose ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsEquipSpell),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-500
end
function s.condition(e)
	return Duel.IsBattlePhase()
end