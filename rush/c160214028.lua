--超魔導騎士－ブラック・キャバルリー
--Dark Cavalry (Rush)
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,CARD_DARK_MAGICIAN,1,s.ffilter,1)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
	--Effect protection
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.indtg)
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsRace(RACE_WARRIOR,scard,sumtype,tp) and c:IsDefense(2100)
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(Card.IsSpellTrap,0,LOCATION_GRAVE,LOCATION_GRAVE,nil)*100
end
function s.condition(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)>=1
end
function s.indtg(e,c)
	return c~=e:GetHandler()
end