--Monster Eye (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--flip
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(31560081,0))
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetOperation(s.op)
e1:SetTarget(s.target)
c:RegisterEffect(e1)
end

function s.filter(c,e,tp,tid)
return c:IsFacedown() and c:GetTurnID()==tid-1 and c:GetOwner()~=tp
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
local tid=Duel.GetTurnCount()
if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.filter(chkc,e,tp,tid) end
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_ONFIELD,1,nil,e,tp,tid) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_ONFIELD,1,1,nil,e,tp,tid)
Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e) and tc:IsFacedown() then 
Duel.ChangePosition(tc,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
end
end
