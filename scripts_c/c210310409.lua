--熱心の刻印
--The Mark of Zeal
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Change target ATK
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_ATKCHANGE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DAMAGE_STEP)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetHintTiming(TIMING_DAMAGE_STEP)
    e1:SetCondition(s.atkcon)
    e1:SetTarget(s.atktg)
    e1:SetOperation(s.atkop)
    c:RegisterEffect(e1)
    --Change all ATK
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetOperation(s.atkop2)
    c:RegisterEffect(e2)
end
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetCurrentPhase() ~= PHASE_DAMAGE or not Duel.IsDamageCalculated()
end
function s.atkfilter(c)
    return c:IsFaceup() and c:IsTheMark()
end
function s.atktg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and s.atkfilter(chkc)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_FACEUP)
    Duel.SelectTarget(tp, s.atkfilter, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
end
function s.atkop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        e1:SetValue(700)
        tc:RegisterEffect(e1)
        local e2 = Effect.CreateEffect(c)
        e2:SetType(EFFECT_TYPE_SINGLE)
        e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e2:SetCode(EFFECT_EXTRA_ATTACK)
        e2:SetValue(2)
        e2:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e2)
    end
end
function s.atkop2(e, tp, eg, ep, ev, re, r, rp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount())
    e1:SetCondition(s.atkcon3)
    e1:SetOperation(s.atkop3)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.atkcon3(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnCount() ~= e:GetLabel()
end
function s.atkop3(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, LOCATION_MZONE, LOCATION_MZONE, nil)
    for tc in aux.Next(g) do
        local val = tc:IsControler(tp) and 500 or -500
        tc:UpdateAttack(val, nil, e:GetHandler())
        tc:UpdateDefense(val, nil, e:GetHandler())
    end
end
