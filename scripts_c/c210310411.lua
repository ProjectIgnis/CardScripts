--希望の刻印
--The Mark of Hope
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Activate
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --Gain LP
    local e2 = Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_RECOVER)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_DAMAGE)
    e2:SetProperty(EFFECT_FLAG_DELAY + EFFECT_FLAG_DAMAGE_STEP)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCondition(s.lpcon)
    e2:SetOperation(s.lpop)
    c:RegisterEffect(e2)
    --Protect
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_QUICK_O)
    e3:SetCode(EVENT_FREE_CHAIN)
    e3:SetRange(LOCATION_GRAVE)
    e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e3:SetCost(aux.bfgcost)
    e3:SetTarget(s.prtg)
    e3:SetOperation(s.prop)
    c:RegisterEffect(e3)
end
function s.lpcon(e, tp, eg, ep, ev, re, r, rp)
    return ep == tp
end
function s.lpop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then
        return
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount() + ev * 10)
    e1:SetCondition(s.lpcon2)
    e1:SetOperation(s.lpop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.lpcon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnCount() ~= (e:GetLabel() % 10)
end
function s.lpop2(e, tp, eg, ep, ev, re, r, rp)
    local lp = e:GetLabel() // 10
    Duel.Hint(HINT_CARD, 0, id)
    Duel.Recover(tp, lp * 2, REASON_EFFECT)
end
function s.prfilter(c)
    return c:IsFaceup() and c:IsTheMark()
end
function s.prtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.prfilter(chkc)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.prfilter, tp, LOCATION_MZONE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local g = Duel.SelectTarget(tp, s.prfilter, tp, LOCATION_MZONE, 0, 1, 1, nil)
end
function s.prop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    if not (tc and tc:IsRelateToEffect(e)) then
        return
    end
    --indes
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
    e1:SetRange(LOCATION_MZONE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 2)
    tc:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
    tc:RegisterEffect(e2)
    local e3 = e1:Clone()
    e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
    tc:RegisterEffect(e3)
end
