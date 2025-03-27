--ジュラック・ギガノト
--Jurrac Giganoto
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTunerEx(Card.IsRace,RACE_DINOSAUR),1,99)
	c:EnableReviveLimit()
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,SET_JURRAC))
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
end
s.listed_series={SET_JURRAC}
function s.filter(c)
	return c:IsSetCard(SET_JURRAC) and c:IsMonster()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,nil)*200
end