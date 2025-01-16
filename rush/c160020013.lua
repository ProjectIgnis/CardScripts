--昆遁忍虫 迷網のクモ
--Evasive Chaos Ninsect Labyrinth Spider
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Opponent can only target the monster with the highest ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.cond)
	e1:SetValue(s.tg)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:GetOriginalRace()~=RACE_INSECT
end
function s.cond(e)
	return not Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.tg(e,c)
	local pg=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local _,atk=pg:GetMaxGroup(Card.GetAttack)
	return c:IsFaceup() and c:GetAttack()<atk
end