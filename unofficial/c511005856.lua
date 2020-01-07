--Brain Control (DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--take control opp monster with highest ATK
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_CONTROL)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end

function s.filter(c,e,tp)
return c:IsControlerCanBeChanged() and c:IsFaceup()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return  Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
if #g>0 then
local tg=g:GetMaxGroup(Card.GetAttack) end
return tg 
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
if not e:GetHandler():IsRelateToEffect(e) then return end
local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
if #g>0 then
local tg=g:GetMaxGroup(Card.GetAttack)
local tc=tg:GetFirst()
Duel.GetControl(tc,tp,PHASE_END,1)
end
end


