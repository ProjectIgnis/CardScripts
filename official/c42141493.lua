--マルチャミー・フワロス
--Mulcharmy Fuwalos
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects for the rest of the turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)==0 end)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Keep track of the activations of a "Mulcharmy" monster's effect
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,function(re) return not (re:GetHandler():IsSetCard(SET_MULCHARMY) and re:IsMonsterEffect()) end)
end
s.listed_series={SET_MULCHARMY}
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)<2 end
	Duel.SendtoGrave(c,REASON_COST|REASON_DISCARD)
	--You can only activate 1 other "Mulcharmy" monster effect, the turn you activate this effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(function(e) return Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>=2 end)
	e1:SetValue(function(e,re,tp) return re:GetHandler():IsSetCard(SET_MULCHARMY) and re:IsMonsterEffect() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Draw 1 card each time your opponent Special Summons a monster(s) from the Deck and/or Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.drcon)
	e1:SetOperation(s.drop)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Shuffle random cards from your hand to the Deck during the End Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetOperation(s.tdop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.drconfilter(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsSummonLocation(LOCATION_DECK|LOCATION_EXTRA)
end
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.drconfilter,1,nil,tp)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsChainSolving() then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Draw(tp,1,REASON_EFFECT)
	else
		local eff=e:GetLabelObject()
		if eff and not eff:IsDeleted() then
			eff:SetLabel(eff:GetLabel()+1)
		else
			local c=e:GetHandler()
			--Draw cards when the current Chain Link finishes resolving
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetOperation(s.chainsolvedop)
			e1:SetLabel(1)
			e1:SetLabelObject(e)
			e1:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e1,tp)
			e:SetLabelObject(e1)
			--Reset "e1" and the label object of "e" at the end of the Chain Link
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVED)
			e2:SetOperation(function() e:SetLabelObject(nil) e1:Reset() end)
			e2:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
	e:Reset()
	e:GetLabelObject():SetLabelObject(nil)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local dif=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)-(Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)+6)
	if dif>0 then
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Match(Card.IsAbleToDeck,nil):RandomSelect(tp,dif)
		if #g==0 then return end
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end