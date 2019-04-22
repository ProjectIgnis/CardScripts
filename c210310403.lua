--刻印の幹事
--Overseer of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Special Summon
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e1:SetType(EFFECT_TYPE_QUICK_O + EFFECT_TYPE_FIELD)
    e1:SetCode(EVENT_CHAINING)
    e1:SetRange(LOCATION_HAND + LOCATION_GRAVE)
    e1:SetCondition(s.spcon)
    e1:SetTarget(s.sptg)
    e1:SetOperation(s.spop)
    c:RegisterEffect(e1)
    --Banish
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetTarget(s.rmtg)
    e2:SetOperation(s.rmop)
    c:RegisterEffect(e2)
end
function s.spcon(e, tp, eg, ep, ev, re, r, rp)
    local ex, cg, ct, cp, cv = Duel.GetOperationInfo(ev, CATEGORY_ANNOUNCE)
    return ex and (cv & (ANNOUNCE_CARD + ANNOUNCE_CARD_FILTER)) ~= 0
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    if chk == 0 then
        return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
    end
    Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    if not c:IsRelateToEffect(e) then
        return
    end
    if Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
        local e1 = Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD)
        e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
        e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
        e1:SetTargetRange(1, 0)
        e1:SetValue(1)
        e1:SetReset(RESET_PHASE + PHASE_END)
        Duel.RegisterEffect(e1, tp)
    end
end
function s.rmfilter(c, isImmediate)
    return c:IsFacedown() and (isImmediate and c:IsAbleToRemove() or true)
end
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chkc then
        return chkc:IsLocation(LOCATION_ONFIELD) and s.rmfilter(chkc, isImmediate)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.rmfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, nil, isImmediate)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.rmfilter, tp, LOCATION_ONFIELD, LOCATION_ONFIELD, 1, 2, nil, isImmediate)
    if isImmediate then
        Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, #g, 0, 0)
    end
end
function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect, nil, e)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if isImmediate then
        Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
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
    e1:SetCondition(s.rmcon2)
    e1:SetOperation(s.rmop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.flagfilter(c, flag)
    return c:GetFlagEffect(flag) ~= 0
end
function s.rmcon2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    ng = g:Filter(s.flagfilter, nil, id)
    g:DeleteGroup()
    ng:KeepAlive()
    e:SetLabelObject(ng)
    return Duel.GetTurnCount() ~= e:GetLabel() and #ng > 0
end
function s.rmop2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.Remove(g, POS_FACEUP, REASON_EFFECT)
    g:DeleteGroup()
end
