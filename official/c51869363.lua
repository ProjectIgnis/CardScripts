--超電導閃輝プラズマ・ブラスト
--Plasma Blast
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Activate this effect depending on whose turn it is;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
	--Keep track of a monster being destroyed by battle or card effect
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(s.descheckop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.descheckfilter(c)
	return (c:IsPreviousLocation(LOCATION_MZONE) or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsMonsterCard()))
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.descheckop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.descheckfilter,1,nil) then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.thfilter(c)
	return c:IsRace(RACE_THUNDER|RACE_ROCK) and c:IsAbleToHand() and (c:IsFaceup() or c:IsLocation(LOCATION_DECK))
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local op=Duel.IsTurnPlayer(tp) and 1 or 2
	local locations=LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED
	if Duel.HasFlagEffect(0,id) then locations=locations|LOCATION_DECK end
	if chk==0 then
		if op==1 then
			return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1
				and Duel.IsExistingMatchingCard(Card.IsRace,tp,LOCATION_DECK,0,1,nil,RACE_THUNDER|RACE_ROCK)
		elseif op==2 then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,locations,0,1,nil)
		end
	end
	e:SetLabel(op)
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,op))
	if op==1 then
		e:SetCategory(CATEGORY_DESTROY)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND|CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,locations)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Yours: Place 1 Thunder or Rock monster from your Deck on top of your Deck, then if a Thunder or Rock monster is in your field or GY, you can destroy 1 card on the field
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		local sc=Duel.SelectMatchingCard(tp,Card.IsRace,tp,LOCATION_DECK,0,1,1,nil,RACE_THUNDER|RACE_ROCK):GetFirst()
		if not sc then return end
		Duel.ShuffleDeck(tp)
		Duel.MoveSequence(sc,0)
		Duel.ConfirmDecktop(tp,1)
		local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)-e:GetHandler()
		if #g>0 and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_THUNDER|RACE_ROCK),tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local dg=g:Select(tp,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg)
				Duel.BreakEffect()
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	elseif op==2 then
		--● Opponent's: Add 1 Thunder or Rock monster from your field, GY, or banishment to the hand, or if a monster(s) was destroyed by battle or card effect this turn, you can add from your Deck instead
		local locations=LOCATION_MZONE|LOCATION_GRAVE|LOCATION_REMOVED
		if Duel.HasFlagEffect(0,id) then locations=locations|LOCATION_DECK end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local hc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,locations,0,1,1,nil):GetFirst()
		if hc then
			if not hc:IsLocation(LOCATION_DECK) then Duel.HintSelection(hc) end
			Duel.SendtoHand(hc,nil,REASON_EFFECT)
			if hc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,hc) end
		end
	end
end