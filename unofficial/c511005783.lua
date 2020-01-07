--Raigeki (DOR)
--scripted by GameMaster(GM)
--updated by Edo
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.tg)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
end

--Thanks to edo for helping update filter using coulum funtions
function s.filter(c,g)
return g:IsContains(c)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
local cg=e:GetHandler():GetColumnGroup()
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local cg=c:GetColumnGroup()
if c:IsRelateToEffect(e) then
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,cg)
if #g>0 then
Duel.Destroy(g,REASON_EFFECT)
end
end
end


