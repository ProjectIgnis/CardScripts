--MR3 Pendulum Summon
--coded by MissingNo with the help of pyrQ and edo9300
local s,id=GetID()
function s.initial_effect(c)
    if Duel.IsDuelType(DUEL_EMZONE) then aux.EnableExtraRules(c,s,s.init)
    else local e1=Effect.CreateEffect(c)
        e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
        e1:SetCode(EVENT_ADJUST)
        e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
        e1:SetOperation(s.legaldeck)
        Duel.RegisterEffect(e1,0)
    end
end
function s.legaldeck(e,tp,eg,ep,ev,re,r,rp)
    local c=e:GetOwner()
    local p=c:GetControler()
    Duel.DisableShuffleCheck()
    Duel.SendtoDeck(c,nil,-2,REASON_RULE)
    local ct=Duel.GetMatchingGroupCount(nil,p,LOCATION_HAND+LOCATION_DECK,0,c)
    if (Duel.IsDuelType(DUEL_MODE_SPEED) and ct<20 or ct<40) and Duel.SelectYesNo(1-p,aux.Stringid(4014,5)) then
        Duel.Win(1-p,0x55)
    end
    if c:IsPreviousLocation(LOCATION_HAND) then Duel.Draw(p,1,REASON_RULE) end
    e:Reset()
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
    e2:SetValue(function(e,c,fp,rp,r)return Duel.GetLinkedZone(1-rp)>>16|96 end)
    Duel.RegisterEffect(e2,0)
end
