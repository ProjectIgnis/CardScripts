--銀河眼の隕石竜　（ギャラクシーアイズ・スターフォール・ドラゴン）
--Galaxy-Eyes Starfall Dragon
--AlphaKretin
local card = c210310068
local id = 210310068
function card.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(
		c,
		aux.FilterBoolFunctionEx(Card.IsAttribute, ATTRIBUTE_LIGHT),
		1,
		1,
		aux.NonTunerEx(Card.IsLevel, 8),
		1,
		1
	)
	c:EnableReviveLimit()

	--Banish upon Synchro Summon
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id, 0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
	e1:SetCondition(card.rmcon)
	e1:SetTarget(card.rmtg)
	e1:SetOperation(card.rmop)
	c:RegisterEffect(e1)

	--Reduce Xyz attack
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0, LOCATION_MZONE)
	e2:SetValue(card.atkval)
	c:RegisterEffect(e2)

	--Attack all Xyz
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(card.atkfilter)
	c:RegisterEffect(e3)

	--Float into Photon Dragon
	local e4 = Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id, 1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(card.spcon)
	e4:SetTarget(card.sptg)
	e4:SetOperation(card.spop)
	c:RegisterEffect(e4)
end
card.listed_names = {93717133}

--Banish upon Synchro Summon
function card.rmcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function card.cfilter(c)
	return (c:IsSetCard(0x55) or c:IsSetCard(0x7b)) and c:IsType(TYPE_MONSTER)
end
function card.rmtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, nil) and
			Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) >= 3
	end
end
function card.rmop(e, tp, eg, ep, ev, re, r, rp)
	Duel.ConfirmDecktop(tp, 3)
	local g = Duel.GetDecktopGroup(tp, 3)
	local ct = g:FilterCount(card.cfilter, nil)
	Duel.ShuffleDeck(tp)
	if ct > 0 then
		local tg = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
		if #tg > 0 then
			local rg = tg:Filter(Card.IsRelateToEffect, nil, e)
			Duel.Remove(tg, POS_FACEUP, REASON_EFFECT)
		end
	end
end

--Reduce Xyz attack
function card.atkval(e, c)
	if c:IsType(TYPE_XYZ) then
		local ct = c:GetOverlayCount()
		return ct * -1000
	else
		return 0
	end
end

--Attack all Xyz
function card.atkfilter(e, c)
	return c:IsType(TYPE_XYZ)
end

--Float into Photon Dragon
function card.spcon(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and rp ~= tp and c:GetPreviousControler() == tp 
		and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function card.spfilter(c, e, tp)
	return c:IsCode(93717133) and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
end
function card.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	local LOCATION_HAND_DECK_GRAVE = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			Duel.IsExistingMatchingCard(card.spfilter, tp, LOCATION_HAND_DECK_GRAVE, 0, 1, nil, e, tp)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND_DECK_GRAVE)
end
function card.spop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then
		return
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
	local LOCATION_HAND_DECK_GRAVE = LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE
	local g =
		Duel.SelectMatchingCard(tp, aux.NecroValleyFilter(card.spfilter), tp, LOCATION_HAND_DECK_GRAVE, 0, 1, 1, nil, e, tp)
	if #g > 0 then
		Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
	end
end
