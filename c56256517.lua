--予言通帳
--Seer's Passbook
--Script by nekrozar
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
    --Activate
    local e1=Effect.CreateEffect(c)
    e1:SetCategory(CATEGORY_REMOVE)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
    e1:SetTarget(s.target)
    e1:SetOperation(s.activate)
    c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
    local g=Duel.GetDecktopGroup(tp,3)
    if chk==0 then return g:FilterCount(Card.IsAbleToRemove,nil)==3 end
    Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
    if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
    local g=Duel.GetDecktopGroup(tp,3)
    Duel.DisableShuffleCheck()
    if Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)~=3 then return end
    g:KeepAlive()
    local c=e:GetHandler()
    c:SetTurnCounter(0)
    local fid=c:GetFieldID()
    for tc in aux.Next(g) do
        tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
    end
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
    e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
    e1:SetCountLimit(1)
    e1:SetLabel(fid)
    e1:SetLabelObject(g)
    e1:SetCondition(s.thcon)
    e1:SetOperation(s.thop)
    e1:SetReset(RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
    Duel.RegisterEffect(e1,tp)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
    return Duel.GetTurnPlayer()==tp
end
function s.thfilter(c,fid)
    return c:GetFlagEffectLabel(id)==fid
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetHandler()
    local ct=c:GetTurnCounter()
    ct=ct+1
    if ct==3 then
        local g=e:GetLabelObject():Filter(s.thfilter,nil,e:GetLabel())
        if g and #g==3 then
            Duel.SendtoHand(g,nil,REASON_EFFECT)
        end
    else c:SetTurnCounter(ct) end
end

