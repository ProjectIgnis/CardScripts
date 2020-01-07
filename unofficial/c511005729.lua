--SwordStalker (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--atk/def up x # monsters in grave by 100
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,1))
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_FLIP)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
end

function s.filter(c)
return c:IsType(TYPE_MONSTER)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ct,g=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_GRAVE,0,nil)*100
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetValue(ct)
c:RegisterEffect(e1) 
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e2)
end



