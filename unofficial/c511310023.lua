--闇の淵
--Edge of Darkness
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--Activate
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--gain atk
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetOperation(card.atkop)
	c:RegisterEffect(e2)
	--search
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(code, 0))
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCost(card.thcost)
	e3:SetTarget(card.thtg)
	e3:SetOperation(card.thop)
	c:RegisterEffect(e3)
end

--gain atk
function card.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_ZOMBIE)
end

function card.atkop(e, tp, eg, ep, ev, re, r, rp)
	local ac = Duel.GetAttacker()
	if ac and ac:IsRace(RACE_ZOMBIE) then
		ac:UpdateAttack(
			Duel.GetMatchingGroupCount(card.atkfilter, tp, LOCATION_MZONE, 0, nil) * 100,
			RESET_PHASE + PHASE_END + RESET_EVENT + RESETS_STANDARD,
			e:GetHandler()
		)
	end
end

--to hand
function card.thcfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_ZOMBIE) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true)
end

--unselect checking function - group must all be of same name and there must be a card left to add
function card.rescon(sg, e, tp, mg)
	return sg:GetClassCount(Card.GetCode) == 1 and
		Duel.IsExistingMatchingCard(card.thfilter, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, sg)
end

function card.thfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsAbleToHand()
end

function card.thcost(e, tp, eg, ep, ev, re, r, rp, chk)
	local g = Duel.GetMatchingGroup(card.thcfilter, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, nil)
	if chk == 0 then
		return aux.SelectUnselectGroup(g, e, tp, 2, 2, card.rescon, chk)
	end
	local rg = aux.SelectUnselectGroup(g, e, tp, 2, 2, card.rescon, 1, tp, HINTMSG_REMOVE)
	Duel.Remove(rg, POS_FACEUP, REASON_COST)
end

function card.thtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingMatchingCard(card.thfilter, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, nil)
	end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_GRAVE + LOCATION_DECK)
end

function card.thop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, card.thfilter, tp, LOCATION_GRAVE + LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end
