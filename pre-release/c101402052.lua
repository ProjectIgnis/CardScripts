--時の黒魔術師
--Dark Time Wizard
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects (but you can only use each effect of "Dark Time Wizard" once per turn);
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(TIMING_END_PHASE,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.toss_coin=true
function s.deckthfilter(c)
	return c:ListsCode(id) and not c:IsCode(id) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Add 1 card that mentions "Dark Time Wizard" from your Deck to your hand, except "Dark Time Wizard", also add 1 "Dark Time Wizard" from your GY to your hand during the End Phase of this turn
	local b1=not Duel.HasFlagEffect(tp,id)
		and Duel.IsExistingMatchingCard(s.deckthfilter,tp,LOCATION_DECK,0,1,nil)
	--● Toss a coin and call it. If you call it right, destroy as many monsters your opponent controls as possible, and if you do, inflict damage to your opponent equal to half the total original ATK of those monsters. If you call it wrong, destroy all monsters you control
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local b2=not Duel.HasFlagEffect(tp,id+100) and #g>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	else
		Duel.RegisterFlagEffect(tp,id+100,RESET_PHASE|PHASE_END,0,1)
		e:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DAMAGE)
		Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,1,1-tp,0)
	end
end
function s.gythfilter(c)
	return c:IsCode(id) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--● Add 1 card that mentions "Dark Time Wizard" from your Deck to your hand, except "Dark Time Wizard", also add 1 "Dark Time Wizard" from your GY to your hand during the End Phase of this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.deckthfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
		local c=e:GetHandler()
		aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,3))
		--Add 1 "Dark Time Wizard" from your GY to your hand during the End Phase of this turn
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
			Duel.Hint(HINT_CARD,0,id)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.gythfilter),tp,LOCATION_GRAVE,0,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				Duel.SendtoHand(g,nil,REASON_EFFECT)
			end
		end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	elseif op==2 then
		--● Toss a coin and call it. If you call it right, destroy as many monsters your opponent controls as possible, and if you do, inflict damage to your opponent equal to half the total original ATK of those monsters. If you call it wrong, destroy all monsters you control
		if Duel.CallCoin(tp) then
			local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
			if #g>0 and Duel.Destroy(g,REASON_EFFECT)>0 then
				local dam=Duel.GetOperatedGroup():GetSum(Card.GetBaseAttack)
				if dam>0 then
					Duel.Damage(1-tp,dam/2,REASON_EFFECT)
				end
			end
		else
			local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
			if #g>0 then
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end