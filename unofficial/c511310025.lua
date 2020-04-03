--屍狼の遠吠え
--Howl of the Fallen Wolf
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON + CATEGORY_LEAVE_GRAVE + CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(card.spcon)
	e1:SetTarget(card.sptg)
	e1:SetOperation(card.spop)
	c:RegisterEffect(e1)
end

function card.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetTurnPlayer() ~= tp and Duel.GetAttackTarget() == nil and eg:GetFirst():IsLocation(LOCATION_MZONE)
end

function card.spfilter(c, e, tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function card.rescon(sg, e, tp, mg)
	return aux.ChkfMMZ(2)(sg, e, tp, mg) and sg:GetClassCount(Card.GetCode) == 1
end

function card.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end

function card.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local g = Duel.GetMatchingGroup(card.spfilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
	if chk == 0 then
		return aux.SelectUnselectGroup(g, e, tp, 2, 2, card.rescon, chk) and
			not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) and
			Duel.IsExistingMatchingCard(card.thfilter, tp, LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 2, 0, 0)
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function card.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) < 2 or Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
		return
	end
	local g = Duel.GetMatchingGroup(card.spfilter, tp, LOCATION_GRAVE, 0, nil, e, tp)
	local sg = aux.SelectUnselectGroup(g, e, tp, 2, 2, card.rescon, 1, tp, HINTMSG_SPSUMMON)
	if #sg > 0 and Duel.SpecialSummon(sg, 0, tp, tp, false, false, POS_FACEUP_DEFENSE) == 2 then
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
		local tg = Duel.SelectMatchingCard(tp, card.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil)
		if #tg > 0 then
			Duel.SendtoHand(tg, nil, REASON_EFFECT)
			Duel.ConfirmCards(1 - tp, tg)
		end
	end
end
