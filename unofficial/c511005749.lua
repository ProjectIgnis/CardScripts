--Spike Seadra (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--atk/def 300 x # thunder monsters
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,1))
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
end

function s.filter(c)
return c:IsRace(RACE_THUNDER)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local ct,g=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*300
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetValue(ct)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
c:RegisterEffect(e1) 
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e2)
end



