--ダメージ・ポラリライザー (Anime)
--Damage Polarizer (Anime)
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
    --Make effect damage 0 and both players draw 1 card
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_DRAW)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_CHAINING)
    e1:SetCondition(s.condition)
    e1:SetTarget(s.target)
    e1:SetOperation(s.operation)
    c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    local ex=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
    return ex and (re:IsMonsterEffect() or re:IsHasType(EFFECT_TYPE_ACTIVATE))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
    Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
    local e1=Effect.CreateEffect(e:GetHandler())
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
    e1:SetCode(EFFECT_CHANGE_DAMAGE)
    e1:SetTargetRange(1,1)
    e1:SetValue(s.val)
    e1:SetReset(RESET_CHAIN)
    e1:SetLabel(cid)
    Duel.RegisterEffect(e1,tp)
    Duel.Draw(tp,1,REASON_EFFECT)
    Duel.Draw(1-tp,1,REASON_EFFECT)
end
function s.val(e,re,r,rp,rc)
    local cc=Duel.GetCurrentChain()
    if cc==0 or (r&REASON_EFFECT)==0 then return end
    local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
    if cid==e:GetLabel() then return 0 end
    return val
end