--ポイズニング・ブロッカー
--Poisoning Blocker
--Scripted by AlphaKretin
--fixed by Larry126
local card, code = GetID()
function card.initial_effect(c)
	--atk/def up
	local e1 = Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90432163, 0))
	e1:SetCategory(CATEGORY_ATKCHANGE + CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(card.atkcon)
	e1:SetTarget(card.atktg)
	e1:SetOperation(card.atkop)
	c:RegisterEffect(e1)
end
function card.atkcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function card.atktg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return e:GetHandler():IsCanChangePosition() end
end
function card.atkop(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.ChangePosition(c, POS_FACEUP_DEFENSE) ~= 0 then
		local e1 = Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
		local e2 = e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end