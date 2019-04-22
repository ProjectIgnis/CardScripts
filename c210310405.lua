--刻印のしもべ
--Servant of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Change name
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_HAND)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCost(s.nmcost)
    e1:SetTarget(s.nmtg)
    e1:SetOperation(s.nmop)
    c:RegisterEffect(e1)
    --Search
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_REMOVE + CATEGORY_TOHAND + CATEGORY_SEARCH)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetCountLimit(1)
    e2:SetTarget(s.thtg)
    e2:SetOperation(s.thop)
    c:RegisterEffect(e2)
end
function s.nmcost(e, tp, eg, ep, ev, re, r, rp, chk)
    e:SetLabel(1)
    return true
end
function s.nmfilter(c, code)
    return c:IsFaceup() and not c:IsCode(code)
end
function s.nmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local c = e:GetHandler()
    if chkc then
        local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
        return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_SZONE) and s.nmfilter(chkc, ac)
    end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_SZONE, nil)
    if chk == 0 then
        if e:GetLabel() ~= 1 then
            return false
        end
        e:SetLabel(0)
        return #g > 0 and c:IsAbleToGraveAsCost()
    end
    Duel.SendtoGrave(c, REASON_COST)
    --can't change to same name, so if only controls one can't announce its name
    local code = #g == 1 and g:GetFirst():GetCode() or 0
    --not c:IsCode(code)
    s.announce_filter = {code, OPCODE_ISCODE, OPCODE_NOT}
    local ac = Duel.AnnounceCardFilter(tp, table.unpack(s.announce_filter))
    local tg = Duel.SelectTarget(tp, s.nmfilter, tp, 0, LOCATION_SZONE, 1, 1, nil, ac)
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD_FILTER)
end
function s.nmop(e, tp, eg, ep, ev, re, r, rp)
    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    local tc = Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and tc:IsFaceup() then
        local e1 = Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetCode(EFFECT_CHANGE_CODE)
        e1:SetValue(ac)
        e1:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
        tc:RegisterEffect(e1)
    end
end
function s.thfilter(c, isImmediate)
    return c:IsTheMark() and c:IsType(TYPE_SPELL + TYPE_TRAP) and c:IsAbleToRemove()
    --and (isImmediate and c:IsAbleToHand() or true)
    --Workaround: Checks if can add while in deck, so stopped by Mistake.
    --No card prevents adding from banished, so no need for check for now.
end
function s.thtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chk == 0 then
        return Duel.IsExistingTarget(s.thfilter, tp, LOCATION_DECK, 0, 1, nil, isImmediate)
    end
    Duel.SetOperationInfo(0, CATEGORY_REMOVE, nil, 1, 0, LOCATION_DECK)
    if isImmediate then
        Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_REMOVED)
    end
end
function s.thop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
    local tc = Duel.SelectMatchingCard(tp, s.thfilter, tp, LOCATION_DECK, 0, 1, 1, nil, isImmediate):GetFirst()
    if not (tc and Duel.Remove(tc, POS_FACEUP, REASON_EFFECT) ~= 0) then
        return
    end
    if isImmediate then
        Duel.SendtoHand(tc, nil, REASON_EFFECT)
        return
    end
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
function s.thcon2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return Duel.GetTurnCount() ~= e:GetLabel() and tc:GetFlagEffect(id) ~= 0 and tc:IsLocation(LOCATION_REMOVED)
end
function s.thop2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
end
