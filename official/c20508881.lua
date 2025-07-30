--絢嵐たる見神
--Magnifistorming Sight Trance
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Set this card
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp) return re:GetHandler():IsCode(CARD_MYSTICAL_SPACE_TYPHOON) end)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_MYSTICAL_SPACE_TYPHOON}
s.listed_series={SET_MAGNIFISTORM}
function s.tgfilter(c)
	return c:IsSetCard(SET_MAGNIFISTORM) and c:IsMonster() and c:IsAbleToGrave()
end
function s.thfilter(c)
	return c:IsCode(CARD_MYSTICAL_SPACE_TYPHOON) and c:IsAbleToHand()
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not Duel.HasFlagEffect(tp,id) and Duel.IsPlayerCanDraw(tp,2)
	local b2=not Duel.HasFlagEffect(tp,id+1)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,1,tp,2)
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
	elseif op==2 then
		e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
		Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE|PHASE_END,0,1)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	end
end
function s.discardfilter(c)
	return (c:IsSetCard(SET_MAGNIFISTORM) or c:IsQuickPlaySpell()) and c:IsDiscardable(REASON_EFFECT)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Draw 2 cards, then discard 1 "Magnifistorm" card or 1 Quick-Play Spell, or, if you do not have any in your hand, discard your entire hand
		if Duel.Draw(tp,2,REASON_EFFECT)>0 then
			Duel.ShuffleHand(tp)
			Duel.BreakEffect()
			local handg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
			if handg:IsExists(s.discardfilter,1,nil) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
				local dg=handg:FilterSelect(tp,s.discardfilter,1,1,nil)
				if #dg>0 then
					Duel.SendtoGrave(dg,REASON_EFFECT|REASON_DISCARD)
				end
			else
				Duel.SendtoGrave(handg,REASON_EFFECT|REASON_DISCARD)
			end
		end
	elseif op==2 then
		--Add 1 "Mystical Space Typhoon" from your Deck or GY to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	if c:IsLocation(LOCATION_GRAVE) then
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,tp,0)
	end
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end