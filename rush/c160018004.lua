--ダークマター・ディープバジャー
--Dark Matter Deep Badger
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetRange(LOCATION_HAND)
	e0:SetCondition(s.spcon)
	c:RegisterEffect(e0)
	--Face-up Attack Position DARK Galaxy monsters you control cannot be destroyed by your opponent's attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.indcon)
	e1:SetTarget(s.indtg)
	e1:SetValue(s.indes)
	c:RegisterEffect(e1)
	--Face-up Attack Position DARK Galaxy monsters you control gain ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.indcon)
	e2:SetTarget(s.indtg)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.GetMatchingGroupCount(s.cfilter,c:GetControler(),LOCATION_GRAVE,0,nil)>=5
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(Card.IsFacedown,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsAttackPos() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_GALAXY)
end
function s.indes(e,c)
	return Duel.GetAttacker():IsControler(1-e:GetHandlerPlayer())
end
function s.val(e,c)
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)*300
end