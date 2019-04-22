--刻印の人の逃亡
--Daring Escape of the Marked Ones
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --End turn
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_ATTACK_ANNOUNCE)
    e1:SetCondition(s.endcon)
    e1:SetCost(s.endcost)
    e1:SetOperation(s.endop)
    c:RegisterEffect(e1)
end
function s.endcon(e, tp, eg, ep, ev, re, r, rp)
    return tp ~= Duel.GetTurnPlayer()
end
function s.cfilter(c)
    return c:IsTheMark() and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c, true)
end
function s.endcost(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, nil)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_MZONE + LOCATION_GRAVE, 0, 1, 1, nil)
    Duel.Remove(g, POS_FACEUP, REASON_COST)
end
function s.endop(e, tp, eg, ep, ev, re, r, rp)
    local turnp = Duel.GetTurnPlayer()
    Duel.SkipPhase(turnp, PHASE_BATTLE, RESET_PHASE + PHASE_END, 1, 1)
    Duel.SkipPhase(turnp, PHASE_MAIN2, RESET_PHASE + PHASE_END, 1)
end
