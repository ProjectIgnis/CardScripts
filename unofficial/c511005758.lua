--Barrel Dragon (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_DESTROY+CATEGORY_FLIP)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end

function s.filter(c,e)
return c:IsType(0xfff) and not c:IsImmuneToEffect(e) 
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
local oppmonNum = Duel.GetMatchingGroupCount(s.filter,nil,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e)
local s1=math.min(oppmonNum,oppmonNum)
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),e)  end
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
if #g>0  then
local tg=g
if #tg>1 then
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
Duel.SetTargetCard(tg)
Duel.HintSelection(g)
end
end
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
local oppmonNum = Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
local s1=math.min(oppmonNum,oppmonNum)
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),e)
if #g>0 then
local sg=g:RandomSelect(tp,1)
Duel.Destroy(sg,REASON_EFFECT)
Duel.ConfirmCards(tp,sg)
end
end
