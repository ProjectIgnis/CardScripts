--グレート・モス (Anime)
--Great Moth (Anime)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetCountLimit(1)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={40240595,58192742}
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE_START+PHASE_DRAW)
	e1:SetOperation(s.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_PHASE_START+PHASE_MAIN1)
	c:RegisterEffect(e3)
	local e4=e1:Clone()
	e4:SetCode(EVENT_PHASE_START+PHASE_BATTLE_START)
	c:RegisterEffect(e4)
	local e5=e1:Clone()
	e5:SetCode(EVENT_PHASE_START+PHASE_MAIN2)
	c:RegisterEffect(e5)
	local e6=e1:Clone()
	e6:SetCode(EVENT_PHASE_START+PHASE_END)
	c:RegisterEffect(e6)
end
function s.atkval(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	for c in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
function s.eqfilter(c)
	return c:IsCode(40240595) and c:GetTurnCounter()>=4
end
function s.rfilter(c)
	return c:IsCode(58192742) and c:GetEquipGroup():IsExists(s.eqfilter,1,nil)
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(c:GetControler(),s.rfilter,1,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(c:GetControler(),s.rfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.atkfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_EARTH)
end