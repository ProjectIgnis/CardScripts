--Performing Pals Counter Strike
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Destroy opp monster instead
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_CHAINING)
e1:SetCondition(s.condition)
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
end
s.listed_series={0x9f}

function s.cfilter(c)
return c:IsOnField() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9f) 
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
if tp==ep or not Duel.IsChainNegatable(ev) then return false end
if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
return ex and tg~=nil and tc+tg:FilterCount(s.cfilter,nil)-#tg>0
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDestructable,tp,0,LOCATION_MZONE,1,nil) end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local g=Group.CreateGroup()
Duel.ChangeTargetCard(ev,g)
Duel.ChangeChainOperation(ev,s.repop)
end

function s.repop(e,tp,eg,ep,ev,re,r,rp)
Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
local g=Duel.GetFieldGroup(1-e:GetHandlerPlayer(),0,LOCATION_MZONE):Select(1-tp,1,1,nil)
Duel.SetTargetCard(g)
Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e) then
Duel.Destroy(tc,REASON_EFFECT)
end
end