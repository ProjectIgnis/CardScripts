--ゼロ・エクストラリンク
--Zero Extra Link
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
    aux.AddPersistentProcedure(c,0,s.filter)
    --eff
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_UPDATE_ATTACK)
    e1:SetRange(LOCATION_SZONE)
    e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
    e1:SetTarget(aux.PersistentTargetFilter)
    e1:SetValue(s.atkval)
    c:RegisterEffect(e1)
    --material
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(47882565,0))
    e2:SetCategory(CATEGORY_ATKCHANGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e2:SetCode(EVENT_SPSUMMON_SUCCESS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetLabelObject(e1)
    e2:SetCondition(s.atkcon)
    e2:SetOperation(s.atkop)
    c:RegisterEffect(e2)
    local e3=Effect.CreateEffect(c)
    e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e3:SetCode(EVENT_LEAVE_FIELD_P)
    e3:SetRange(LOCATION_SZONE)
    e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
    e3:SetCondition(s.matcon)
    e3:SetOperation(s.matop)
    c:RegisterEffect(e3)
    --destroy
    local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(5851097,0))
    e4:SetCategory(CATEGORY_DESTROY)
    e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
    e4:SetCode(EVENT_BATTLED)
    e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetRange(LOCATION_SZONE)
    e4:SetTarget(s.descon)
    e4:SetOperation(s.desop)
    c:RegisterEffect(e4)
end
function s.exfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK) and (c:GetSequence()==5 or c:GetSequence()==6)
end
function s.filter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetMutualLinkedGroup():IsExists(s.exfilter,1,nil)
end
function s.cfilter(c)
    return c:IsFaceup() and c:IsType(TYPE_LINK)
end
function s.atkval(e,c)
    local val=Duel.GetMatchingGroupCount(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)*800
    e:SetLabel(val)
    return val
end
function s.atkfilter(c,tc)
    return c:IsType(TYPE_LINK) and c:IsSummonType(SUMMON_TYPE_LINK) and c:GetFlagEffect(id)>0
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.atkfilter,1,nil)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
    local tc=eg:Filter(s.atkfilter,1,nil):GetFirst()
    if tc then
        local e1=Effect.CreateEffect(e:GetHandler())
        e1:SetType(EFFECT_TYPE_SINGLE)
        e1:SetCode(EFFECT_UPDATE_ATTACK)
        e1:SetValue(e:GetLabelObject():GetLabel())
        e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
        tc:RegisterEffect(e1)
    end
end
function s.matfilter(c,ec)
    return ec:IsHasCardTarget(c) and c:IsReason(REASON_MATERIAL+REASON_LINK)
end
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.matfilter,1,nil,e:GetHandler())
end
function s.matop(e,tp,eg,ep,ev,re,r,rp)
    eg:Filter(s.matfilter,nil,e:GetHandler()):GetFirst():GetReasonCard():RegisterFlagEffect(id,RESET_EVENT+0xfe0000,0,1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
    return e:GetHandler():IsHasCardTarget(Duel.GetAttacker())
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
    if e:GetHandler():IsRelateToEffect(e) then
        Duel.Destroy(e:GetHandler(),REASON_EFFECT)
    end
end

