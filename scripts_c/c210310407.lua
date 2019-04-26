--決心の刻印
--The Mark of Determination
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
    --Add to hand
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_TOHAND)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetRange(LOCATION_SZONE)
    e1:SetCountLimit(1)
    e1:SetTarget(s.thtg)
    e1:SetOperation(s.thop)
    c:RegisterEffect(e1)
    --Send to grave
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_CONTINUOUS)
    e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e2:SetCode(EVENT_DESTROYED)
    e2:SetOperation(s.regop)
    c:RegisterEffect(e2)
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 0))
    e3:SetCategory(CATEGORY_TOGRAVE)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
    e3:SetCode(EVENT_CUSTOM + id)
    e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER + EFFECT_FLAG_DELAY)
    e3:SetTarget(s.tgtg)
    e3:SetOperation(s.tgop)
    c:RegisterEffect(e3)
end
function s.thfilter(c)
    return c:IsTheMark() and c:IsAbleToHand()
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    if chkc then
        return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local g = Duel.SelectTarget(tp, s.thfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then
        return
    end
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) then
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetDescription(aux.Stringid(id, 1))
        e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_PHASE + PHASE_END)
        e1:SetCountLimit(1)
        e1:SetLabel(Duel.GetTurnCount())
        e1:SetLabelObject(tc)
        e1:SetCondition(s.thcon2)
        e1:SetOperation(s.thop2)
        e1:SetReset(RESET_PHASE + PHASE_END, 2)
        Duel.RegisterEffect(e1, tp)
    end
end
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return Duel.GetTurnCount() ~= e:GetLabel() and tc:GetFlagEffect(id) ~= 0
end
function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
function s.regop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if rp ~= tp then
        Duel.RaiseSingleEvent(c, EVENT_CUSTOM + id, re, r, rp, 1 - tp, ev)
    end
end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    local ac = Duel.AnnounceCard(tp)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD)
end
function s.tgfilter(c, ac)
    return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsCode(ac)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    local g = Duel.GetMatchingGroup(s.tgfilter, tp, LOCATION_ONFIELD + LOCATION_HAND, 0, nil, ac)
    if #g > 0 then
        Duel.SendtoGrave(g, REASON_EFFECT)
    end
end
