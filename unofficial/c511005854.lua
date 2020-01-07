--Royal Decree(DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_CHAINING)
e1:SetOperation(s.activate)
e1:SetTarget(s.target)
e1:SetCondition(s.condition)
c:RegisterEffect(e1)
--negate Trap
local e2=Effect.CreateEffect(c)
e2:SetCategory(CATEGORY_NEGATE)
e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_QUICK_F)
e2:SetCode(EVENT_CHAINING)
e2:SetRange(LOCATION_SZONE)
e2:SetCondition(s.condition)
e2:SetTarget(s.target)
e2:SetOperation(s.activate)
c:RegisterEffect(e2)
--activate turn set
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e3:SetCode(EVENT_SSET)
e3:SetOperation(s.op) 
Duel.RegisterEffect(e3,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local c=eg:GetFirst()
while c do
if c:GetOriginalCode()==id then c:SetStatus(STATUS_SET_TURN,false) end
c=eg:GetNext()
end
end


function s.condition(e,tp,eg,ep,ev,re,r,rp)
return re:GetHandler()~=e:GetHandler() and re:IsActiveType(TYPE_TRAP)  and Duel.IsChainNegatable(ev) 
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end


function s.activate(e,tp,eg,ep,ev,re,r,rp)
local ec=re:GetHandler()
Duel.NegateEffect(ev)
if re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_CONTINUOUS) then
	ec:CancelToGrave()
end
end
