--Psycho puppet (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
c:EnableReviveLimit()
--ATK/DEF+1500 IF CONTROL MYSTERIOUS PUPPETER
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e2:SetCondition(s.con2)
e2:SetOperation(s.atkop)
c:RegisterEffect(e2)
end
s.listed_names={54098121}

function s.filter(c)
return c:IsFaceup() and c:IsCode(54098121)
end

function s.con2(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_ONFIELD,0,1,nil)
end

function s.atkop(e,tp,eg,ep,ev,re,r,rp)
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetValue(1500)
e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
e:GetHandler():RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
e:GetHandler():RegisterEffect(e2)
end




