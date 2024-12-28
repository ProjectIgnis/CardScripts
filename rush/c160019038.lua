--ＳＰグラファガス・プラズマセイバー
--Super Graphagas Plasma Saber
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160012001,160210065)
	--Gains ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--Disable SpSummon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_FORCE_SPSUMMON_POSITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetValue(POS_FACEDOWN_DEFENSE)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsLevelAbove(7) and c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.val(e,c)
	local g=Duel.GetMatchingGroup(s.filter,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	local ct=g:GetSum(Card.GetLevel)
	return ct*200
end
function s.cfilter(c)
	return c:IsRace(RACE_PYRO|RACE_THUNDER|RACE_AQUA) and c:IsType(TYPE_MAXIMUM)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end
function s.target(e,c)
	return c:IsLocation(LOCATION_HAND) and not c:IsAttribute(ATTRIBUTE_FIRE)
end