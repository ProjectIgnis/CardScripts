--Darkness Approaches
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetOperation(s.op)
e1:SetTarget(s.tg)
c:RegisterEffect(e1)
--cannot turn set
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_CANNOT_TURN_SET)
e2:SetValue(1)
c:RegisterEffect(e2)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
end


function s.filter(c)
return c:IsAttackPos() and c:IsFaceup() and c:IsCanTurnSet()
end

function s.filter2(c)
return c:IsDefensePos() and c:IsFaceup() and c:IsCanTurnSet()
end

function s.filter3(c)
return c:IsFaceup() and c:IsCanTurnSet()
end




function s.op(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
if #g>0 then 
Duel.ChangePosition(g,POS_FACEDOWN_ATTACK)
end
local g=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
if #g>0 then 
Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_SZONE,LOCATION_SZONE,nil)
if #g>0 then 
Duel.ChangePosition(g,POS_FACEDOWN)
end
end
