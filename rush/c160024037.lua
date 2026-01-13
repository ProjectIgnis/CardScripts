--冥跡神イシリア
--Isyria, Deity of the Monumenthes
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--Cannot be destroyed
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3001)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE|EFFECT_FLAG_CLIENT_HINT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Prevent the activation of Traps when you Summon a Beast
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(s.sucop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_CHAIN_END)
	e5:SetOperation(s.cedop2)
	c:RegisterEffect(e5)
	--Atk
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetCode(EFFECT_UPDATE_ATTACK)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,0)
	e6:SetCondition(s.condition)
	e6:SetTarget(s.target)
	e6:SetValue(3000)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e7)
end
function s.splimit(e,se,sp,st)
	return se:GetHandler():IsCode(160024046)
end
function s.sucfilter(c,tp)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsFaceup() and c:IsControler(tp)
end
function s.sucop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.sucfilter,1,nil,tp) then
		Duel.SetChainLimit(s.chainlm)
	end
end
function s.cedop2(e,tp,eg,ep,ev,re,r,rp)
	local _,g=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
	if g and g:IsExists(s.sucfilter,1,nil,tp) and Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
		Duel.SetChainLimitTillChainEnd(s.chainlm)
	end
end
function s.chainlm(e,rp,tp)
	return tp==rp or (e:IsTrapEffect() and not e:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
function s.target(e,c)
	return c:IsRace(RACE_BEASTWARRIOR) and c:IsAttribute(ATTRIBUTE_EARTH) and c~=e:GetHandler()
end