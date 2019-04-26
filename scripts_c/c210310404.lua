--刻印の守護者
--Protector of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
local effs = {remove = 0, grave = 1}
function s.initial_effect(c)
    --Banish
    local e1 = Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id, 0))
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_QUICK_O)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetRange(LOCATION_MZONE)
    e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e1:SetCountLimit(1, EFFECT_COUNT_CODE_SINGLE)
    e1:SetTarget(s.rmtg)
    e1:SetOperation(s.rmop)
    e1:SetLabel(effs.remove)
    c:RegisterEffect(e1)
    local e2 = e1:Clone()
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_TOGRAVE)
    e2:SetLabel(effs.grave)
    c:RegisterEffect(e2)
end
local locations = {[effs.remove] = LOCATION_GRAVE, [effs.grave] = LOCATION_REMOVED}
local filters = {
    [effs.remove] = function(c, tp)
        return c:IsAbleToRemove() and c:IsControler(tp) and c:IsFaceup()
    end,
    [effs.grave] = function(c)
        return c:IsAbleToGrave()
    end
}
local categories = {[effs.remove] = CATEGORY_REMOVE, [effs.grave] = CATEGORY_TOGRAVE}
function s.rmfilter(c, isImmediate, label, tp)
    return isImmediate and filters[label](c, tp) or true
end
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local label = e:GetLabel()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chkc then
        return chkc:IsLocation(locations[label]) and s.rmfilter(chkc, isImmediate, label, tp)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.rmfilter, tp, locations[label], locations[label], 1, nil, isImmediate, label, tp)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g =
        Duel.SelectTarget(tp, s.rmfilter, tp, locations[label], locations[label], 1, 1, nil, isImmediate, label, tp)
    if isImmediate then
        Duel.SetOperationInfo(0, categories[label], g, #g, 0, 0)
    end
end
local ops = {
    [effs.remove] = function(c)
        Duel.Remove(c, POS_FACEUP, REASON_EFFECT)
    end,
    [effs.grave] = function(c)
        Duel.SendtoGrave(c, REASON_EFFECT + REASON_RETURN)
    end
}
function s.rmop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local label = e:GetLabel()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if isImmediate then
        if tc:IsRelateToEffect(e) then
            ops[label](tc)
        end
        return
    end
    tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount() * 10 + label)
    e1:SetLabelObject(tc)
    e1:SetCondition(s.rmcon2)
    e1:SetOperation(s.rmop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.rmcon2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    return Duel.GetTurnCount() ~= (e:GetLabel() // 10) and tc:GetFlagEffect(id) ~= 0
end
function s.rmop2(e, tp, eg, ep, ev, re, r, rp)
    local tc = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    ops[e:GetLabel() % 10](tc)
end
