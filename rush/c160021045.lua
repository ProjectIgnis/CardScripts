--超頸竜エラスモーター
--Super Cervical Dragon Elasmotar
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3001)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Gains 1200 ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.con)
	e2:SetValue(1200)
	c:RegisterEffect(e2)
	--pierce
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(s.con)
	c:RegisterEffect(e3)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DINOSAUR,fc,sumtype,tp)
end
function s.filter(c)
	return c:IsRace(RACE_DINOSAUR) and c:IsType(TYPE_FUSION) and not c:IsType(TYPE_EFFECT)
end
function s.con(e)
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end