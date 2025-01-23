--カオス・センチネル
--Chaos Sentinel
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsAttackAbove,1500),aux.FilterBoolFunctionEx(Card.IsAttackBelow,1500))
	--Must be Fusion Summoned, or Special Summoned by "The Eye of Timaeus"
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--Spells/Traps cannot be returned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_DECK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcond)
	e1:SetTarget(s.indtg)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetValue(s.value)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_TO_HAND)
	c:RegisterEffect(e2)
	c:AddSideMaximumHandler(e2)
end
s.listed_cards={160020003,160020051} --Sentinel Officer, Galaxy Chaos Fusion
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(160020003,160020051)
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