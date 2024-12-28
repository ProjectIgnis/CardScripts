--夢中のラーヴァ
--Delirium Larva
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_INSECT))
	e1:SetValue(800)
	c:RegisterEffect(e1)
	--Spells/Traps cannot be returned
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_TO_DECK)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcond)
	e2:SetTarget(s.indtg)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e3)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_INSECT,fc,sumtype,tp) and c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.indcond(e)
	return Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.indtg(e,c)
	return c:IsSpellTrap()
end
function s.value(e,re,rp)
	return nil~=re
end