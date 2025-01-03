--悪魔の聲
--Dimonno Vaalmonica
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)
	--Can place Resonance Counters on it
	c:EnableCounterPermit(COUNTER_RESONANCE,LOCATION_PZONE)
	--Place 1 Resonance Counter on this card each time you take effect damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return ep==tp and r&REASON_EFFECT>0 and Duel.IsExistingMatchingCard(Card.IsOriginalRace,tp,LOCATION_PZONE,0,1,e:GetHandler(),RACE_FAIRY) end)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--Opponent's monsters lose 100 ATK for each Resonance Counter on your field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(function(e) return Duel.GetCounter(e:GetHandlerPlayer(),LOCATION_ONFIELD,0,COUNTER_RESONANCE)*-100 end)
	c:RegisterEffect(e2)
	--Place both this card and 1 "Angello Vaalmonica" from your Deck in your Pendulum Zone
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,{id,0})
	e3:SetCost(s.pzcost)
	e3:SetTarget(s.pztg)
	e3:SetOperation(s.pzop)
	c:RegisterEffect(e3)
	--Apply the damage-inflicting effect of 1 "Vaalmonica" Normal Spell/Trap
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,1})
	e4:SetCondition(function(e) return e:GetHandler():HasFlagEffect(id) end)
	e4:SetCost(s.cpcost)
	e4:SetTarget(s.cptg)
	e4:SetOperation(s.cpop)
	c:RegisterEffect(e4)
	--Register flag on summon
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetOperation(aux.sumreg)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(ge2,0)
	end)
end
s.listed_names={3048768} --"Angello Vaalmonica"
s.listed_series={SET_VAALMONICA}
s.counter_place_list={COUNTER_RESONANCE}
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	else
		--Place 1 Resonance Counter on this card at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_PZONE)
		e1:SetOperation(s.addcounter)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.addcounter(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:AddCounter(COUNTER_RESONANCE,1)
	Duel.RaiseEvent(c,EVENT_CUSTOM+39210885,e,0,tp,tp,1)
end
function s.pzcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST|REASON_DISCARD,c)
end
function s.pzfilter(c)
	return c:IsCode(3048768) and not c:IsForbidden()
end
function s.pztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1)
		and Duel.IsExistingMatchingCard(s.pzfilter,tp,LOCATION_DECK,0,1,nil) end
end
function s.pzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (Duel.CheckLocation(tp,LOCATION_PZONE,0) and Duel.CheckLocation(tp,LOCATION_PZONE,1) and c:IsRelateToEffect(e)) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
	local tc=Duel.SelectMatchingCard(tp,s.pzfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	Duel.MoveToField(tc,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
end
function s.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	return true
end
function s.cpfilter(c)
	return c:IsSetCard(SET_VAALMONICA) and (c:IsNormalSpell() or c:IsNormalTrap()) and c:IsAbleToRemoveAsCost()
		--and c:CheckActivateEffect(false,true,false)
end
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.cpfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.cpfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	Duel.Remove(tc,POS_FACEUP,REASON_COST)
	e:SetLabelObject(tc)
end
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc then return end
	local eff=tc:GetActivateEffect()
	local op=eff:GetOperation()
	--Additional parameter checked in the script of "Vaalmonica" Normal Spells/Traps to correctly apply the damage-inflicting effect
	if op then op(e,tp,eg,ep,ev,re,r,rp,2) end
end