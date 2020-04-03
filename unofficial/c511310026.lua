--マジェスティ・オブ・ファイア
--Majesty of Fire
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(card.spcon)
	e1:SetTarget(card.sptg)
	e1:SetOperation(card.spop)
	c:RegisterEffect(e1)
end

function card.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetFieldGroupCount(tp, LOCATION_MZONE, 0) == 0
end

function card.filter(c, e, tp)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end

function card.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(card.filter, tp, LOCATION_HAND, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND)
end

function card.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, card.filter, tp, LOCATION_HAND, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
	end
end
