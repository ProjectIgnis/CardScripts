--隠し通路
--Hidden Passage
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.attg)
	c:RegisterEffect(e2)
end
function s.attg(e,c)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	local _,atk=Group.GetMinGroup(g,Card.GetAttack)
	return c:IsMonster() and c:IsFaceup() and c:IsLevelBelow(2) and c:IsRace(RACE_SPELLCASTER)
		and not c:IsHasEffect(EFFECT_CANNOT_ATTACK) and c:GetAttack()<atk
end