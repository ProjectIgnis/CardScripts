--ブロック・ダグアウト
--Block Dugout
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Cannot declare attacks
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(s.atcon)
	c:RegisterEffect(e2)
end
function s.atcon(e)
	local g1=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),LOCATION_MZONE,0,nil)
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	return g1:GetSum(Card.GetLevel)>g2:GetSum(Card.GetLevel)
end