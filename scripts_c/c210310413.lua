--刻印の人の村
--Vilage of the Marked Ones
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
    --destroy replace
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EFFECT_DESTROY_REPLACE)
    e2:SetRange(LOCATION_FZONE)
    e2:SetTarget(s.reptg)
    e2:SetValue(s.repval)
    e2:SetOperation(s.repop)
    c:RegisterEffect(e2)
    --negate
    local e3 = Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_CHAIN_SOLVING)
    e3:SetRange(LOCATION_SZONE)
    e3:SetCondition(s.negcon)
    e3:SetOperation(s.negop)
    c:RegisterEffect(e3)
    --change target
    local e4 = Effect.CreateEffect(c)
    e4:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
    e4:SetCode(EVENT_CHAINING)
    e4:SetRange(LOCATION_FZONE)
    e4:SetOperation(s.regop)
    c:RegisterEffect(e4)
    local e5 = Effect.CreateEffect(c)
    e5:SetDescription(aux.Stringid(id, 0))
    e5:SetType(EFFECT_TYPE_QUICK_F)
    e5:SetCode(EVENT_CUSTOM + id)
    e5:SetRange(LOCATION_FZONE)
    e5:SetProperty(EFFECT_FLAG_EVENT_PLAYER + EFFECT_FLAG_BOTH_SIDE)
    e5:SetCondition(s.tgcon)
    e5:SetTarget(s.tgtg)
    e5:SetOperation(s.tgop)
    c:RegisterEffect(e5)
end
function s.repfilter(c)
    return c:IsFaceup() and c:IsTheMark() and c:IsOnField() and c:IsControler(tp) and not c:IsReason(REASON_REPLACE) and
        (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT))
end
function s.repval(e, c)
    return s.repfilter(c)
end
function s.reptg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return eg:IsExists(s.repfilter, 1, nil)
    end
    local dg = eg:Filter(s.repfilter, nil)
    dg:KeepAlive()
    e:SetLabelObject(dg)
    return true
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    Duel.Hint(HINT_CARD, 0, id)
    local dg = e:GetLabelObject()
    for tc in aux.Next(dg) do
        tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 2)
    end
    local e1 = Effect.CreateEffect(e:GetHandler())
    e1:SetDescription(aux.Stringid(id, 1))
    e1:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_PHASE + PHASE_END)
    e1:SetCountLimit(1)
    e1:SetLabel(Duel.GetTurnCount())
    e1:SetLabelObject(dg)
    e1:SetCondition(s.tgcon2)
    e1:SetOperation(s.tgop2)
    e1:SetReset(RESET_PHASE + PHASE_END, 2)
    Duel.RegisterEffect(e1, tp)
end
function s.flagfilter(c, flag)
    return c:GetFlagEffect(flag) ~= 0
end
function s.tgcon2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    local ng = g:Filter(s.flagfilter, nil, id)
    g:DeleteGroup()
    ng:KeepAlive()
    e:SetLabelObject(ng)
    return Duel.GetTurnCount() ~= e:GetLabel() and #ng > 0
end
function s.tgop2(e, tp, eg, ep, ev, re, r, rp)
    local g = e:GetLabelObject()
    Duel.Hint(HINT_CARD, 0, id)
    Duel.SendtoGrave(g, nil, REASON_EFFECT)
    g:DeleteGroup()
end
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
    if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    return rp ~= tp and g and #g > 1 and Duel.IsChainDisablable(ev)
end
function s.negop(e, tp, eg, ep, ev, re, r, rp)
    Duel.NegateEffect(ev)
end
function s.regop(e, tp, eg, ep, ev, re, r, rp)
    if rp ~= tp then
        Duel.RaiseEvent(e:GetHandler(), EVENT_CUSTOM + id, re, r, rp, 1 - tp, ev)
    end
end
function s.tgcon(e, tp, eg, ep, ev, re, r, rp)
    if e == re or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then
        return false
    end
    local g = Duel.GetChainInfo(ev, CHAININFO_TARGET_CARDS)
    if not g or #g ~= 1 then
        return false
    end
    local tc = g:GetFirst()
    if not tc:IsFaceup() then
        return false
    end
    e:SetLabelObject(tc)

    return true
end
function s.tgfilter(c, re, rp, tf, ceg, cep, cev, cre, cr, crp, ac)
    return tf(re, rp, ceg, cep, cev, cre, cr, crp, 0, c) and c:IsCode(ac) and c:IsCanBeEffectTarget(re)
end
function s.tgtg(e, tp, eg, ep, ev, re, r, rp, chk)
    if chk == 0 then
        return true
    end
    s.announce_filter = {e:GetLabelObject():GetCode(), OPCODE_ISCODE}
    local ac = Duel.AnnounceCardFilter(tp, table.unpack(s.announce_filter))
    Duel.SetTargetParam(ac)
    Duel.SetOperationInfo(0, CATEGORY_ANNOUNCE, nil, 0, tp, ANNOUNCE_CARD)
end
function s.tgop(e, tp, eg, ep, ev, re, r, rp)
    if not e:GetHandler():IsRelateToEffect(e) then
        return
    end

    local ac = Duel.GetChainInfo(0, CHAININFO_TARGET_PARAM)
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TARGET)
    local tf = re:GetTarget()
    local res, ceg, cep, cev, cre, cr, crp = Duel.CheckEvent(re:GetCode(), true)
    local g =
        Duel.SelectMatchingCard(
        1 - tp,
        s.tgfilter,
        1 - tp,
        LOCATION_ONFIELD,
        LOCATION_ONFIELD,
        1,
        1,
        nil,
        re,
        rp,
        tf,
        ceg,
        cep,
        cev,
        cre,
        cr,
        crp,
        ac
    )
    if #g > 0 then
        Duel.ChangeTargetCard(ev, g)
    else
        Duel.NegateEffect(ev)
    end
end
