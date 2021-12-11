--Twisted Personality
local s,id=GetID()
function s.initial_effect(c)
    aux.AddSkillProcedure(c,2,false,nil,nil)
    local e1=Effect.CreateEffect(c)
    e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
    e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e1:SetCode(EVENT_STARTUP)
    e1:SetCountLimit(1)
    e1:SetRange(0x5f)
    e1:SetLabel(0)
    e1:SetOperation(s.flipop)
    c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
    Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
    Duel.Hint(HINT_CARD,tp,id)
    local c=e:GetHandler()
    if Duel.GetFlagEffect(tp,id+1)==0 then
        --Add counter
        local lp=Duel.GetLP(c:GetControler())
        local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetLabel(lp)
        e1:SetLabelObject(e)
        e1:SetCondition(s.lpcon)
        e1:SetOperation(s.lpop)
        Duel.RegisterEffect(e1,tp)
        --Discard/Destroy
        local e2=Effect.CreateEffect(e:GetHandler())
        e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e2:SetCode(EVENT_FREE_CHAIN)
        e2:SetCountLimit(1)
        e2:SetLabelObject(e)
        e2:SetCondition(s.con)
        e2:SetOperation(s.op)
        Duel.RegisterEffect(e2,tp)
        --player hint for number of counters
        local e3=Effect.CreateEffect(e:GetHandler())
        e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
        e3:SetDescription(aux.Stringid(id,0))
        e3:SetCode(id)
        e3:SetTargetRange(1,0)
        Duel.RegisterEffect(e3,tp)
    end
    Duel.RegisterFlagEffect(ep,id+1,0,0,0)
end
--Lose LP check
function s.lpcon(e,tp,eg,ep,ev,re,r,rp)
    local p=e:GetHandler():GetControler()
    return Duel.GetLP(p)~=e:GetLabel()
end
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
    local p=e:GetHandler():GetControler()
    if Duel.GetLP(p)>e:GetLabel() then
        e:SetLabel(Duel.GetLP(p))
        return
    end
    e:SetLabel(Duel.GetLP(p))
    if e:GetLabelObject():GetLabel()<3 then
        e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
        local ce=Duel.IsPlayerAffectedByEffect(tp,id)
        if ce then
            local nce=ce:Clone()
            ce:Reset()
            nce:SetDescription(aux.Stringid(id,e:GetLabelObject():GetLabel()))
            Duel.RegisterEffect(nce,tp)
        end
    end
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
    --discard
    local g1=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
    --destroy
    local g2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
    return Duel.IsMainPhase() and Duel.GetTurnPlayer()==tp and ((e:GetLabelObject():GetLabel()>1 and g1) or (e:GetLabelObject():GetLabel()>2 and g2))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
    --discard
    local g1=e:GetLabelObject():GetLabel()>1 and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
    --destroy
    local g2=e:GetLabelObject():GetLabel()>2 and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
    local opt=0
    if g1 and g2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))
    elseif g1 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,4))
    elseif g2 then
        opt=Duel.SelectOption(tp,aux.Stringid(id,5))+1
    else return end
    if opt==0 then
        e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-2)
        local ce=Duel.IsPlayerAffectedByEffect(tp,id)
        if ce then
            local nce=ce:Clone()
            ce:Reset()
            nce:SetDescription(aux.Stringid(id,e:GetLabelObject():GetLabel()))
            Duel.RegisterEffect(nce,tp)
        end
        local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
        if #g==0 then return end
        local sg=g:RandomSelect(1-tp,1)
        Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
    else 
        e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-3)
        local ce=Duel.IsPlayerAffectedByEffect(tp,id)
        if ce then
            local nce=ce:Clone()
            ce:Reset()
            nce:SetDescription(aux.Stringid(id,e:GetLabelObject():GetLabel()))
            Duel.RegisterEffect(nce,tp)
        end
        local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
        if #g==0 then return end
        local sg=g:Select(tp,1,1,nil)
        Duel.HintSelection(sg)
        Duel.Destroy(sg,REASON_EFFECT)
    end
end
