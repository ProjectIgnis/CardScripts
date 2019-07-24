--Shield and Sword (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE)
and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
Duel.SetTargetCard(g)
end

function s.filter(c,e)
return c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
local c=e:GetHandler()
local tc=sg:GetFirst()
while tc do
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_SWAP_BASE_AD)
tc:RegisterEffect(e1)
tc=sg:GetNext()
end
end
