--魔法大学
--Magical Academy
--scripted by: UnknownGuest
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon 1 Spellcaster from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE|TIMING_SUMMON)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true 
end
function s.costfilter(c,e,tp)
    	return c:IsDiscardable(REASON_COST) and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,c,e,tp)
end
function s.spfilter(c,e,tp)
    	if not (c:IsRace(RACE_SPELLCASTER) and c:IsSummonableCard() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
    	local mi,ma=c:GetTributeRequirement()
    	return (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and mi==0) or (ma>=mi and ma>0 and Duel.CheckTribute(c,mi))
end
function s.rescon(sg,e,tp,mg)
    	return #sg==2 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,sg,e,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    	local c=e:GetHandler()
    	if chk==0 then
        	if e:GetLabel()~=0 then
        		e:SetLabel(0)
            		local exc=c:IsLocation(LOCATION_HAND) and c or nil
            		local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,exc)
            		return #g>=2 and aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,0)
        	else
            		return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,e,tp)
		end
	end
    	if e:GetLabel()~=0 then
        	e:SetLabel(0)
        	local exc=c:IsLocation(LOCATION_HAND) and c or nil
        	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,exc)
        	local cost=aux.SelectUnselectGroup(g,e,tp,2,2,s.rescon,1,tp,HINTMSG_DISCARD)
        	Duel.SendtoGrave(cost,REASON_DISCARD|REASON_COST)
    	end
    	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local mi,ma=tc:GetTributeRequirement()
		if mi>0 then
			local g=Duel.SelectTribute(tp,tc,mi,ma)
			Duel.Release(g,REASON_EFFECT)
		end
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(500)
		tc:RegisterEffect(e2,true)
		--Negate opponent's Spell/Traps that target the Summoned monster
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_DISABLE)
		e3:SetTargetRange(0,LOCATION_SZONE)
		e3:SetLabelObject(tc)
		e3:SetTarget(function(e,c) return c:IsHasCardTarget(e:GetLabelObject()) end)
		e3:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e3,tp)
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_CHAIN_SOLVING)
		e4:SetOperation(s.disop)
		e4:SetLabelObject(tc)
		e4:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e4,tp)
		local e5=Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e5:SetCode(EVENT_CHAINING)
		e5:SetOperation(s.disop)
		e5:SetLabelObject(tc)
		e5:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e5,tp)
		Duel.SpecialSummonComplete()
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not (re:IsSpellTrapEffect() and re:GetHandler():IsControler(1-tp) and re:IsHasProperty(EFFECT_FLAG_CARD_TARGET)) then return end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or not g:IsContains(tc) or not Duel.IsChainDisablable(ev) then return false end
	Duel.NegateEffect(ev)
end