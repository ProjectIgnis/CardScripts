--闇の淵デュプリケート・ドローン
--Duplicate Drone
--Scripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--special summon
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(card.spcon)
	c:RegisterEffect(e1)
	--place in szone
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(code, 0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1, code)
	e2:SetTarget(card.sztg)
	e2:SetOperation(card.szop)
	c:RegisterEffect(e2)
	--copy stats
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(code, 1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(card.cptg)
	e3:SetOperation(card.cpop)
	c:RegisterEffect(e3)
end

--special summon
function card.spfilter(c)
	return c:IsFaceup() and c:IsCode(code)
end

function card.spcon(e, c)
	if c == nil then
		return true
	end
	return Duel.GetLocationCount(c:GetControler(), LOCATION_MZONE) > 0 and
		Duel.IsExistingMatchingCard(card.spfilter, c:GetControler(), LOCATION_MZONE, 0, 1, nil)
end

--place in szone
function card.szfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE) and not c:IsForbidden()
end

function card.sztg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and card.szfilter(chkc)
	end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
			Duel.IsExistingTarget(card.szfilter, tp, LOCATION_MZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TOFIELD)
	Duel.SelectTarget(tp, card.szfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end

function card.szop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 then
		return
	end
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.MoveToField(tc, tp, tp, LOCATION_SZONE, POS_FACEUP, true)
		local e1 = Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD - RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL + TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

--copy stats
function card.cpfilter(c)
	return c:IsFaceup() and (c:GetOriginalType() & (TYPE_MONSTER)) == TYPE_MONSTER and c:IsType(TYPE_SPELL) and
		c:IsType(TYPE_CONTINUOUS) and c:GetOriginalType() & (TYPE_XYZ | TYPE_LINK) == 0
end

function card.cptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return c:IsLocation(LOCATION_SZONE) and c:IsControler(tp) and card.cpfilter(chkc)
	end
	if chk == 0 then
		return Duel.IsExistingTarget(card.cpfilter, tp, LOCATION_SZONE, 0, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SELF)
	Duel.SelectTarget(tp, card.cpfilter, tp, LOCATION_SZONE, 0, 1, 1, nil)
end

function card.cpop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local tc = Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or not tc or not tc:IsRelateToEffect(e) then
		return
	end
	tc:CreateRelation(c, RESETS_STANDARD)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetCondition(card.cpcon)
	e1:SetValue(tc:GetTextAttack())
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	local e2 = e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetValue(tc:GetTextDefense())
	c:RegisterEffect(e2)
	local e3 = e1:Clone()
	e3:SetCode(EFFECT_CHANGE_CODE)
	e3:SetValue(tc:GetCode())
	c:RegisterEffect(e3)
	local e4 = e1:Clone()
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(tc:GetOriginalRace())
	c:RegisterEffect(e4)
	local e5 = e1:Clone()
	e5:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e5:SetValue(tc:GetOriginalAttribute())
	c:RegisterEffect(e5)
	local e6 = e1:Clone()
	e6:SetCode(EFFECT_CHANGE_LEVEL)
	e6:SetValue(tc:GetOriginalLevel())
	c:RegisterEffect(e6)
	local e7 = Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_CONTINUOUS + EFFECT_TYPE_FIELD)
	e7:SetRange(LOCATION_MZONE)
	e7:SetCode(EVENT_LEAVE_FIELD_P)
	e7:SetLabelObject(tc)
	e7:SetCondition(card.descon)
	e7:SetOperation(card.desop)
	e7:SetReset(RESET_EVENT + RESETS_STANDARD)
	c:RegisterEffect(e7)
end

function card.cpcon(e, c)
	local lc = e:GetLabelObject()
	return lc and lc:IsRelateToCard(e:GetHandler()) and lc:IsLocation(LOCATION_SZONE)
end

function card.descon(e, tp, eg, ep, ev, re, r, rp)
	local lc = e:GetLabelObject()
	return lc and lc:IsRelateToCard(e:GetHandler()) and eg:IsContains(lc)
end

function card.desop(e, tp, eg, ep, ev, re, r, rp)
	Duel.Destroy(e:GetHandler(), REASON_EFFECT)
end
