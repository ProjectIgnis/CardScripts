--暴君の暴力
--Tyrant's Tantrum
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	c:RegisterEffect(e1)
	--Players must send 1 Spell card from the Deck to activate Spell cards
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_ACTIVATE_COST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCost(s.actcost)
	e2:SetTarget(s.actcosttarget)
	e2:SetOperation(s.actcostop)
	c:RegisterEffect(e2)
	--Accumulation
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(id)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(0,1)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,2,nil) end
	local rg=Duel.SelectReleaseGroup(tp,nil,2,2,nil)
	Duel.Release(rg,REASON_COST)
end
function s.actvcostfilter(c)
	return c:IsSpell() and c:IsAbleToGraveAsCost()
end
function s.actcost(e,te,tp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	return Duel.IsExistingMatchingCard(s.actvcostfilter,tp,LOCATION_DECK,0,ct,nil)
end
function s.actcosttarget(e,te,tp)
	return te:IsSpellEffect() and te:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function s.actcostop(e,tp,eg,ep,ev,re,r,rp)
	local ct=#{Duel.GetPlayerEffect(tp,id)}
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.actvcostfilter,tp,LOCATION_DECK,0,ct,ct,nil)
	Duel.SendtoGrave(g,REASON_COST)
end