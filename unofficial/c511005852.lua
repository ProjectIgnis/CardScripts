--Droll Bird (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--fLIP monster of 500 of less FACEup
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_FLIP)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end

function s.filter(c)
return c:IsType(TYPE_MONSTER) and (c:IsFacedown() and c:GetAttack()<=500)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
if #g>0 then
Duel.ChangePosition(g,POS_FACEUP)
end
end

