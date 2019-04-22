--刻印の恋人
--Lover of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
aux.CallToken(210310999)
function s.initial_effect(c)
    --Special Summon self
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_SPSUMMON_PROC)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
    e1:SetRange(LOCATION_HAND)
    e1:SetCondition(s.sprcon)
    c:RegisterEffect(e1)
    --Special Summon other
    local e2 = Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id, 1))
    e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
    e2:SetType(EFFECT_TYPE_QUICK_O)
    e2:SetCode(EVENT_FREE_CHAIN)
    e2:SetRange(LOCATION_MZONE)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetCountLimit(1)
    e2:SetTarget(s.sptg)
    e2:SetOperation(s.spop)
    c:RegisterEffect(e2)
end
function s.sprfilter(c)
    local code1, code2 = c:GetOriginalCodeRule()
    return c:GetCode() ~= code1 and c:GetCode() ~= code2
end
function s.sprcon(e, c)
    if c == nil then
        return true
    end
    return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0 and
        Duel.IsExistingMatchingCard(s.sprfilter, tp, 0, LOCATION_ONFIELD, 1, nil)
end
function s.spfilter(c, e, tp, isImmediate)
    return c:IsTheMark() and (isImmediate and c:IsCanBeSpecialSummoned(e, 0, tp, false, false) or true)
end
function s.sptg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if chkc then
        return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc, e, tp, isImmediate)
    end
    if chk == 0 then
        return Duel.IsExistingTarget(s.spfilter, tp, LOCATION_GRAVE, 0, 1, nil, e, tp, isImmediate)
    end
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
    local g = Duel.SelectTarget(tp, s.spfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil, e, tp, isImmediate)
    if isImmediate then
        Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, g, #g, 0, LOCATION_GRAVE)
    end
end
function s.spop(e, tp, eg, ep, ev, re, r, rp)
    local c = e:GetHandler()
    local tc = Duel.GetFirstTarget()
    local isImmediate = Duel.IsPlayerAffectedByEffect(tp, CARD_TRUE_ESSENCE_MARK)
    if isImmediate then
        if tc:IsRelateToEffect(e) then
            Duel.SpecialSummon(tc, 0, tp, tp, false, false, POS_FACEUP)
        end
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
