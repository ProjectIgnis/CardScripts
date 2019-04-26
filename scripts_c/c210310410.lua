--我慢の刻印
--The Mark of Patience
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Shuffle to deck
    local e1 = Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DISABLE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCode(EVENT_TO_HAND)
    e1:SetTarget(s.tdtg)
    e1:SetOperation(s.tdop)
    c:RegisterEffect(e1)
    --Activate in hand
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_SINGLE)
    e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
    e2:SetCondition(s.handcon)
    c:RegisterEffect(e2)
end
function s.cfilter(c)
    return not c:IsReason(REASON_DRAW)
end
function s.tdtg(e, tp, eg, ep, ev, re, r, rp, chk)
    local ag = eg:Filter(s.cfilter, nil)
    if chk == 0 then
        return #ag > 0
    end
    local code
    if ag:GetClassCount(Card.GetCode) > 1 then
        code = ag:Select(tp, 1, 1, nil):GetFirst():GetCode()
    else
        code = ag:GetFirst():GetCode()
    end
    Duel.Hint(HINT_CODE, 0, code)
    e:SetLabel(code)
end
function s.tdop(e, tp, eg, ep, ev, re, r, rp)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount() + e:GetLabel() * 10)
    e1:SetCondition(s.tdcon2)
    e1:SetOperation(s.tdop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.tdcon2(e, tp, eg, ep, ev, re, r, rp)
    return Duel.GetTurnCount() ~= (e:GetLabel() % 10)
end
function s.tdfilter(c, code)
    return c:IsCode(code) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
function s.tdop2(e, tp, eg, ep, ev, re, r, rp)
    local code = e:GetLabel() // 10
    Duel.Hint(HINT_CARD, 0, id)
    local g = Duel.GetMatchingGroup(s.tdfilter, tp, 0, LOCATION_GRAVE + LOCATION_ONFIELD, nil, code)
    Duel.SendtoDeck(g, nil, 2, REASON_EFFECT)
end
function s.handcon(e)
    return Duel.GetFieldGroupCount(e:GetHandlerPlayer(), LOCATION_ONFIELD, 0) == 0
end
