--魔法封印の呪符
--Talisman of Spell Sealing
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.actcon)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(s.descon)
	c:RegisterEffect(e2)
	--cannot trigger
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_HAND|LOCATION_SZONE,LOCATION_HAND|LOCATION_SZONE)
	e3:SetTarget(s.distg)
	c:RegisterEffect(e3)
	--disable
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--disable effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVING)
	e5:SetRange(LOCATION_SZONE)
	e5:SetOperation(s.disop)
	c:RegisterEffect(e5)
end
s.listed_names={2468169}
function s.filter(c)
	return c:IsFaceup() and c:IsCode(2468169)
end
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.descon(e)
	return not Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
function s.distg(e,c)
	return c:IsSpell()
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if (tl&LOCATION_SZONE)~=0 and re:IsSpellEffect() then
		Duel.NegateEffect(ev)
	end
end