--ディアバウンド・カーネル
--Diabound Kernel (anime)
--Rescripted by AlphaKretin
local card, code = GetID()
function card.initial_effect(c)
	--equip
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(code, 0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
	e1:SetTarget(card.eqtg)
	e1:SetOperation(card.eqop)
	c:RegisterEffect(e1)
	--special summon from equip
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(code, 1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(card.spcon)
	e2:SetTarget(card.sptg)
	e2:SetOperation(card.spop)
	c:RegisterEffect(e2)
	--special summon from grave
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(code, 2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1, code)
	e3:SetCondition(card.spcon2)
	e3:SetTarget(card.sptg2)
	e3:SetOperation(card.spop2)
	c:RegisterEffect(e3)
	--gain effect
	local e4 = Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DESTROYING)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCondition(aux.bdocon)
	e4:SetTarget(card.efftg)
	e4:SetOperation(card.effop)
	c:RegisterEffect(e4)
end

function card.eqtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then
		return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1 - tp) and chkc:IsFaceup()
	end
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_SZONE) > 0 and
			Duel.IsExistingTarget(Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, nil)
	end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_EQUIP)
	Duel.SelectTarget(tp, Card.IsFaceup, tp, 0, LOCATION_MZONE, 1, 1, nil)
end

function card.eqop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	local tc = Duel.GetFirstTarget()
	if
		not tc or Duel.GetLocationCount(tp, LOCATION_SZONE) <= 0 or tc:IsControler(tp) or tc:IsFacedown() or
			not tc:IsRelateToEffect(e)
	 then
		Duel.SendtoGrave(c, REASON_EFFECT)
		return
	end
	Duel.Equip(tp, c, tc, true)
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetValue(card.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT + RESETS_STANDARD)
	c:RegisterEffect(e1)
	--equip effect
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(card.atkval)
	e2:SetReset(RESET_EVENT + RESETS_STANDARD)
	c:RegisterEffect(e2)
	c:RegisterFlagEffect(code, RESET_EVENT + RESETS_STANDARD, 1, 0)
end

function card.eqlimit(e, c)
	return c == e:GetLabelObject()
end

function card.atkval(e)
	return e:GetHandler():GetBaseAttack() * -1
end

function card.spcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():GetFlagEffect(code) ~= 0
end

function card.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
			e:GetHandler():IsCanBeSpecialSummoned(e, 0, tp, false, false)
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, 0, 0)
end

function card.spop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then
		return
	end
	Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
end

function card.spcon2(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local ec = c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec and ec:IsReason(REASON_DESTROY + REASON_BATTLE)
end
function card.sptg2(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, e:GetHandler(), 1, tp, 0)
end
function card.spop2(e, tp, eg, ep, ev, re, r, rp)
	Duel.SpecialSummon(e:GetHandler(), 0, tp, tp, false, false, POS_FACEUP)
end

function card.efftg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then
		return true
	end
	local bc = e:GetHandler():GetBattleTarget()
	e:SetLabelObject(bc)
end

function card.effop(e, tp, eg, ep, ev, re, r, rp)
	local tc = e:GetLabelObject()
	if tc and e:GetHandler():IsRelateToEffect(e) then
		e:GetHandler():CopyEffect(tc:GetOriginalCode(), RESET_EVENT + RESETS_STANDARD, 1)
	end
end
