--刻印の戦士
--Enforcer of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Prevent attack
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetCost(s.atcost)
    e1:SetTarget(s.attg)
    e1:SetOperation(s.atop)
    c:RegisterEffect(e1)
    --Return to hand
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
function s.atcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return e:GetHandler():IsAbleToGraveAsCost()
    end
    Duel.SendtoGrave(e:GetHandler(), REASON_COST)
end
function s.attg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    local ac = Duel.AnnounceCard(tp)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD)
end
function s.atop(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_CANNOT_ATTACK)
    e1:SetTargetRange(LOCATION_MZONE, LOCATION_MZONE)
    e1:SetTarget(s.attg2)
    e1:SetReset(RESET_PHASE + PHASE_END)
    e1:SetLabel(ac)
    Duel.RegisterEffect(e1, tp)
end
function s.attg2(e, c)
    return c:IsCode(e:GetLabel())
end
function s.thfilter(c, isImmediate)
    return isImmediate and c:IsAbleToHand() or true
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chkc then
        return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.thfilter(chkc, isImmediate)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.thfilter, tp, 0, LOCATION_ONFIELD, 1, nil, isImmediate)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_RTOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, 0, LOCATION_ONFIELD, 1, 2, nil, isImmediate)
    if isImmediate then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, #g, 0, 0)
    end
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect, nil, e)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if isImmediate then
        Duel.SendtoHand(g, nil, REASON_EFFECT)
        return
    end
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
    end
    g:KeepAlive()
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount())
    e1:SetLabelObject(g)
    e1:SetCondition(s.thcon2)
    e1:SetOperation(s.thop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.flagfilter(c, flag)
    return c:GetFlagEffect(flag) ~= 0
end
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    ng = g:Filter(s.flagfilter, nil, id)
    g:DeleteGroup()
    ng:KeepAlive()
    e:SetLabelObject(ng)
    return Duel.GetTurnCount() ~= e:GetLabel() and #ng > 0
end
function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.SendtoHand(g, nil, REASON_EFFECT)
    g:DeleteGroup()
end
