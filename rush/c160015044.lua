--暗黒波導砲ニュートロン・マグロム
--Dark Hydro Cannon Neutron Bluefin
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160002032,160015016)
	--Direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
	--Cannot activate
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(s.condition2)
	e2:SetValue(function(e,re,tp) return re:IsMonsterEffect() end)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsFaceup() and not c:IsType(TYPE_FUSION)
end
function s.condition(e)
	return not Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.condition2(e)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_MAXIMUM),e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end