--MR3 Pendulum Summon
local s,id=GetID()
function s.initial_effect(c)
    aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
    local e1=Effect.GlobalEffect(c)
    e1:SetType(EFFECT_TYPE_FIELD)
    e1:SetCode(EFFECT_BECOME_LINKED_ZONE)
    e1:SetValue(0xffffff)
    Duel.RegisterEffect(e1,0)
    local e2=Effect.GlobalEffect(c)
    e2:SetType(EFFECT_TYPE_FIELD)
    e2:SetCode(EFFECT_FORCE_MZONE)
    e2:SetRange(LOCATION_MZONE)
    e2:SetTargetRange(LOCATION_EXTRA,LOCATION_EXTRA)
    e2:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_LINK))
    e2:SetValue(s.val)
    Duel.RegisterEffect(e2,0)
end
function s.val(e,c,fp,rp,r)
    return Duel.GetLinkedZone(1-rp)>>16|96
end
