--屍狼の包囲網
--Surrounded by Fallen Wolves
--Scripted by AlphaKretin
local s, id = GetID()
function s.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end

function s.spcon(e, tp, eg, ep, ev, re, r, rp)
	return Duel.GetCurrentPhase() <= PHASE_MAIN1 or Duel.GetCurrentPhase() >= PHASE_MAIN2
end

function s.spfilter(c, e, tp, tid)
	return c:IsRace(RACE_ZOMBIE) and c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) and
		c:IsCanBeEffectTarget(e) and
		(c:GetReason() & 0x41) == 0x41 and
		c:GetTurnID() == tid
end

function s.rescon(sg, e, tp, mg)
	return aux.ChkfMMZ(#sg)(sg, e, tp, mg) and sg:GetClassCount(Card.GetCode) == 1
end

function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	local tid = Duel.GetTurnCount()
	local g = Duel.GetMatchingGroup(s.spfilter, tp, LOCATION_GRAVE, 0, nil, e, tp, tid)
	if chkc then
		return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and s.spfilter(c, e, tp, tid)
	end
	if chk == 0 then
		return aux.SelectUnselectGroup(g, e, tp, 2, 3, s.rescon, chk) and
			not Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT)
	end
	local tg = aux.SelectUnselectGroup(g, e, tp, 2, 3, s.rescon, 1, tp, HINTMSG_SPSUMMON)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, tg, #tg, 0, 0)
end

function s.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local ft = Duel.GetLocationCount(tp, LOCATION_MZONE)
	if ft <= 0 then
		return
	end
	local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	local sg = g:Filter(Card.IsRelateToEffect, nil, e)
	if #sg > 1 and Duel.IsPlayerAffectedByEffect(tp, CARD_BLUEEYES_SPIRIT) then
		return
	end
	if #sg > ft then
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
		sg = sg:Select(tp, ft, ft, nil)
	end
	if #sg > 0 then
		for sc in aux.Next(sg) do
			Duel.SpecialSummonStep(sc, 0, tp, tp, false, false, POS_FACEUP_DEFENSE)
			local e1 = Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e1, true)
			local e2 = Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetReset(RESET_EVENT + RESETS_STANDARD)
			sc:RegisterEffect(e2, true)
		end
		local ct = Duel.SpecialSummonComplete()
		if ct ~= 0 then
			Duel.BreakEffect()
			Duel.Draw(tp, ct, REASON_EFFECT)
		end
	end
end
