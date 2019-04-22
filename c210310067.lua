--The Phantom Knights of Blade Reforged
--AlphaKretin
local card = c210310067
local id = 210310067
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1, id + EFFECT_COUNT_CODE_OATH)
	e1:SetCost(card.cost)
	e1:SetTarget(card.target)
	e1:SetOperation(card.activate)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	--return
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87246309, 1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)	
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(card.rettg)
	e2:SetOperation(card.retop)
	c:RegisterEffect(e2)
end

--activate
function card.cost(e, tp, eg, ep, ev, re, r, rp, chk)
	e:SetLabel(100)
	if chk == 0 then return true end
end
function card.costfilter(c, e, tp)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true) and Duel.IsExistingMatchingCard(card.spfilter, tp, LOCATION_EXTRA, 0, 1, nil, c:GetRank(), e, tp)
end
function card.spfilter(c, lv, e, tp)
	return c:IsRank(lv - 1) and c:IsSetCard(0x10db) and c:IsCanBeSpecialSummoned(e, SUMMON_TYPE_XYZ, tp, false, false)
end
function card.target(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		if e:GetLabel() ~= 100 then return false end
		e:SetLabel(0)
		return e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.GetLocationCountFromEx(tp)>0
			and Duel.IsExistingMatchingCard(card.costfilter, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, 1, nil, e, tp)
	end
	e:SetLabel(0)
	local g = Duel.SelectMatchingCard(tp, card.costfilter, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, 1, 1, nil, e, tp)
	Duel.Remove(g, POS_FACEUP, REASON_COST)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
end
function card.activate(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCountFromEx(tp) <= 0 then return end
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp, card.spfilter, tp, LOCATION_EXTRA, 0, 1, 1, nil, tc:GetRank(), e, tp)
	if g:GetCount()>0 and Duel.SpecialSummon(g, SUMMON_TYPE_XYZ, tp, tp, false, false, POS_FACEUP) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.Overlay(g:GetFirst(), Group.FromCards(c))
	end
end

--return
function card.retfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsSetCard(0xdb) and not c:IsCode(id)
end
function card.rettg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and card.retfilter(chkc) end
	if chk == 0 then return Duel.IsExistingTarget(card.retfilter, tp, LOCATION_REMOVED, 0, 3, nil) end
	Duel.Hint(HINT_OPSELECTED, 1 - tp, e:GetDescription())
	Duel.Hint(HINT_SELECTMSG, tp, aux.Stringid(48976825, 0))
	local g = Duel.SelectTarget(tp, card.retfilter, tp, LOCATION_REMOVED, 0, 3, 3, nil)
	Duel.SetOperationInfo(0, CATEGORY_TOGRAVE, g, g:GetCount(), 0, 0)
end
function card.retop(e, tp, eg, ep, ev, re, r, rp)
	local tg = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
	local sg = tg:Filter(Card.IsRelateToEffect, nil, e)
	if sg:GetCount() > 0 and Duel.SendtoGrave(sg, REASON_EFFECT + REASON_RETURN) > 0 then
		local og = Duel.GetOperatedGroup()
		for tc in aux.Next(og) do 
			local e1 = Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetCode(EFFECT_CANNOT_ACTIVATE)
			e1:SetTargetRange(1, 0)
			e1:SetValue(card.aclimit)
			e1:SetLabelObject(tc)
			e1:SetReset(RESET_PHASE + PHASE_END)
			Duel.RegisterEffect(e1, tp)
		end
	end
end
function card.aclimit(e, re, tp)
	local tc = e:GetLabelObject()
	return re:GetHandler():IsCode(tc:GetCode()) and not re:GetHandler():IsImmuneToEffect(e)
end
