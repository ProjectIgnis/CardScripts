--ナチュラル (Anime)
--Natural Disaster (Anime)
--Made by When
local s,id=GetID()
function s.initial_effect(c)
    local e1=Effect.CreateEffect(c)
    e1:SetType(EFFECT_TYPE_ACTIVATE)
    e1:SetCode(EVENT_FREE_CHAIN)
    c:RegisterEffect(e1)
    --damage
    local e2=Effect.CreateEffect(c)
    e2:SetDescription(aux.Stringid(id,0))
    e2:SetCategory(CATEGORY_DAMAGE)
    e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
    e2:SetRange(LOCATION_SZONE)
    e2:SetCode(EVENT_TO_GRAVE)
    e2:SetCondition(s.condition)
    e2:SetOperation(s.operation)
    c:RegisterEffect(e2)
end
s.listed_series={0x18}
function s.cfilter(c,tp)
    return c:IsPreviousLocation(LOCATION_ONFIELD) and  c:IsPreviousControler(tp)
        and c:IsReason(REASON_DESTROY)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
    return eg:IsExists(s.cfilter,1,nil,1-tp)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
    local ct=eg:FilterCount(s.cfilter,nil,1-tp)
    Duel.Damage(1-tp,ct*400,REASON_EFFECT)
end