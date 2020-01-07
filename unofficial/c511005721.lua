--Stop Defense (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e0=Effect.CreateEffect(c)
e0:SetCategory(CATEGORY_POSITION)
e0:SetType(EFFECT_TYPE_ACTIVATE)
e0:SetCode(EVENT_FREE_CHAIN)
e0:SetOperation(s.operation)
e0:SetTarget(s.target)
c:RegisterEffect(e0)
end

function s.filter(c)
return c:IsDefensePos() and c:IsFaceup()
end

function s.filter2(c)
return c:IsDefensePos() and c:IsFacedown()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) or Duel.IsExistingMatchingCard(s.filter2,tp,0,LOCATION_MZONE,1,nil) end
local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
if #g>0 then 
Duel.ChangePosition(g,POS_FACEUP_ATTACK)
end
local g=Duel.GetMatchingGroup(s.filter2,tp,0,LOCATION_MZONE,nil)
if #g>0 then 
Duel.ChangePosition(g,POS_FACEDOWN_ATTACK)
end
end
