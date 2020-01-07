--Flame Ghost (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)	
--destroy all monsters if umi is faceup on field
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetTarget(s.target)
e1:SetCondition(s.condition)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end
s.listed_names={CARD_UMI}

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
Duel.Destroy(g,REASON_EFFECT)
end

function s.cfilter(c)
return c:IsFaceup() and c:IsCode(CARD_UMI)
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) 
end
