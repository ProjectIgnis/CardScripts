--刻印の神髄
--True Essence of the Mark
--Scripted by AlphaKretin, with permission https://www.youtube.com/watch?v=V3UHH4knlrk&lc=UgwK10c6FJ1NYjkauYR4AaABAg.8pQkcrK531M8pQlVbWVn6i
--Design by HardlegGaming, https://www.youtube.com/watch?v=V3UHH4knlrk
local s, id = GetID()
function s.initial_effect(c)
    --link summon
    c:EnableReviveLimit()
    aux.AddLinkProcedure(
        c,
        function(c, ...)
            return c:IsLinkTheMark(...)
        end,
        3,
        3
    )
    --Resolve immediately
    local e1 = Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(id)
    e1:SetRange(LOCATION_MZONE)
    e1:SetTargetRange(1, 1)
    c:RegisterEffect(e1)
    --Workaround hardcode, change engraver's resolution to destroy
    local e2 = Effect.CreateEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
    e2:SetCode(EVENT_CHAIN_SOLVING)
    e2:SetRange(LOCATION_MZONE)
    e2:SetOperation(s.desop)
    c:RegisterEffect(e2)
    aux.CallToken(210310999)
end
function s.repop(e, tp, eg, ep, ev, re, r, rp)
    local tc = Duel.GetFirstTarget()
    Duel.Destroy(tc, REASON_EFFECT)
end
function s.desop(e, tp, eg, ep, ev, re, r, rp)
    local eff, tg = Duel.GetChainInfo(ev, CHAININFO_TRIGGERING_EFFECT, CHAININFO_TARGET_CARDS)
    if
        eff:GetHandler():GetOriginalCode() == CARD_ENGRAVER_MARK and eff:IsHasCategory(CATEGORY_DESTROY) and tg and
            #tg > 0
     then
        Duel.ChangeChainOperation(ev, s.repop)
    end
end
