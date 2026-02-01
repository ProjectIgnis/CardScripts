--サイボーグ・ナイル
--Mech Misairuzame
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.condtion)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_FISH))
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	--"Tistina" monsters can attack directly
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsCode,62337487))
	c:RegisterEffect(e2)
end
function s.condtion(e)
	return Duel.IsBattlePhase()
end
function s.value(e,c)
	return Duel.GetFieldGroupCountRush(e:GetHandlerPlayer(),LOCATION_MZONE,0)*400
end