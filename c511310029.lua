--３Ｄバイオ・スキャナー
--3D Bio Scanner
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(card.spcost)
	e1:SetTarget(card.sptg)
	e1:SetOperation(card.spop)
	c:RegisterEffect(e1)
end

function card.cfilter(c)
	return not c:IsPublic() and c:IsType(TYPE_MONSTER) and c:IsRace(RACE_MACHINE)
end

function card.rescon(sg, e, tp, mg)
	return sg:GetClassCount(Card.GetCode) == 1
end

function card.spcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local g = Duel.GetMatchingGroup(card.cfilter, tp, LOCATION_HAND, 0, nil, e, tp, tid)
	if chk == 0 then
		return aux.SelectUnselectGroup(g, e, tp, 3, 3, card.rescon, chk)
	end
	local tg = aux.SelectUnselectGroup(g, e, tp, 3, 3, card.rescon, 1, tp, HINTMSG_CONFIRM)
	Duel.ConfirmCards(1 - tp, tg)
end

function card.spfilter(c, e, tp)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function card.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(card.spfilter, tp, LOCATION_DECK, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function card.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local sc = Duel.SelectMatchingCard(tp, card.spfilter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp):GetFirst()
	if sc and Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP) then
		local c=e:GetHandler()
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD)
		sc:RegisterEffect(e1, true)
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		sc:RegisterEffect(e2, true)
		local e3 = Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT + RESETS_STANDARD)
		sc:RegisterEffect(e3, true)
		local e4 = Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE + PHASE_END)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetCountLimit(1)
		e4:SetOperation(card.tdop)
		e4:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		sc:RegisterEffect(e4, true)
		Duel.SpecialSummonComplete()
	end
end

function card.tdop(e, tp, eg, ep, ev, re, r, rp)
	Duel.SendtoDeck(e:GetHandler(), nil, 2, REASON_EFFECT)
end
