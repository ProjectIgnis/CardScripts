--JP name
--Lunalight Scarlet Tiger
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--If you activate a "Lunalight" monster's effect (except during the Damage Step): You can Special Summon this card from your hand, then if you activated this effect during the turn your opponent activated a card or effect, you can add 1 "Polymerization" from your Deck or GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,{id,0})
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return rp==tp and re:IsCardSetcode(SET_LUNALIGHT) and re:IsMonsterEffect()
	end)
	e1:SetTarget(s.selfsptg)
	e1:SetOperation(s.selfspop)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,aux.FALSE)
	--If this card is sent to the GY by card effect: You can Special Summon 1 "Lunalight" monster from your face-up Extra Deck or GY, except a Level 5 monster, but it cannot activate its effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():IsReason(REASON_EFFECT)
	end)
	e2:SetTarget(s.exgysptg)
	e2:SetOperation(s.exgyspop)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_POLYMERIZATION}
s.listed_series={SET_LUNALIGHT}
function s.selfsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	e:GetChainData().extra_effect=Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsCode(CARD_POLYMERIZATION) and c:IsAbleToHand()
end
function s.selfspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and e:GetChainData().extra_effect then
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if sc then
				if sc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(sc) end
				Duel.BreakEffect()
				Duel.SendtoHand(sc,nil,REASON_EFFECT)
				if sc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,sc) end
			end
		end
	end
end
function s.exgyspfilter(c,e,tp,mmz_chk)
	if not (c:IsSetCard(SET_LUNALIGHT) and not c:IsLevel(5) and c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	elseif c:IsLocation(LOCATION_GRAVE) then
		return mmz_chk
	end
end
function s.exgysptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		return Duel.IsExistingMatchingCard(s.exgyspfilter,tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,nil,e,tp,mmz_chk)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_GRAVE)
end
function s.exgyspop(e,tp,eg,ep,ev,re,r,rp)
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.exgyspfilter),tp,LOCATION_EXTRA|LOCATION_GRAVE,0,1,1,nil,e,tp,mmz_chk):GetFirst()
	if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
		--But it cannot activate its effects
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3302)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		sc:RegisterEffect(e1)
	end
	Duel.SpecialSummonComplete()
end