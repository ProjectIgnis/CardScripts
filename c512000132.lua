--草薙の本当
--Kusanagi's Truth
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.SelectYesNo(1-tp,aux.Stringid(1040,0)) then
        Duel.Damage(tp,1000,REASON_EFFECT)
        Duel.Damage(1-tp,1000,REASON_EFFECT)
    else
        Duel.Draw(tp,1,REASON_EFFECT)
        Duel.Draw(1-tp,1,REASON_EFFECT)
    end
end