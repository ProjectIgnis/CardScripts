--刻印の創造者
--Creator of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    c:SetSPSummonOnce(id)
    --Cannot be destroyed by battle
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_SINGLE)
    e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    e1:SetValue(1)
    c:RegisterEffect(e1)
    --Change name
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 0))
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_HAND)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCost(s.nmcost)
    e2:SetTarget(s.nmtg)
    e2:SetOperation(s.nmop)
    c:RegisterEffect(e2)
    --Special Summon
    local e3 = Effect.CreateEffect(c)
    e3:SetDescription(aux.Stringid(id, 1))
    e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
    e3:SetCode(EVENT_TO_GRAVE)
    e3:SetProperty(EFFECT_FLAG_DELAY)
    e3:SetTarget(s.sptg)
    e3:SetOperation(s.spop)
    c:RegisterEffect(e3)
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
        return chkc:IsControler(1 - tp) and chkc:IsLocation(LOCATION_MZONE) and s.nmfilter(chkc, ac)
    end
    local g = Duel.GetMatchingGroup(Card.IsFaceup, tp, 0, LOCATION_MZONE, nil)
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
    local tg = Duel.SelectTarget(tp, s.nmfilter, tp, 0, LOCATION_MZONE, 1, 1, nil, ac)
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
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk)
    local c = e:GetHandler()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chk == 0 then
        return isImmediate and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or true
    end
    if isImmediate then
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
    end
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if isImmediate then
        if c:IsLocation(LOCATION_GRAVE) then
            Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
        end
        return
    end
    c:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount())
    e1:SetLabelObject(c)
    e1:SetCondition(s.spcon2)
    e1:SetOperation(s.spop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.spcon2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return Duel.GetTurnCount() ~= e:GetLabel() and tc:GetFlagEffect(id) ~= 0
end
function s.spop2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
end
