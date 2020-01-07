--Vaccination
--scripted by:urielkama
--Updated by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetCategory(CATEGORY_EQUIP)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
--equip limit
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_EQUIP_LIMIT)
e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
e2:SetValue(1)
c:RegisterEffect(e2)
--equiped monster with vaccine counters immune to virus cards
local e3=Effect.CreateEffect(c)
e3:SetType(EFFECT_TYPE_EQUIP)
e3:SetCode(EFFECT_IMMUNE_EFFECT)
e3:SetValue(s.efilter)
c:RegisterEffect(e3)	
--equip to another target
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
e4:SetCategory(CATEGORY_EQUIP)
e4:SetDescription(aux.Stringid(id,0))
e4:SetCode(EVENT_SUMMON_SUCCESS)
e4:SetRange(LOCATION_GRAVE)
e4:SetCondition(s.retcon)
e4:SetTarget(s.rettg)
e4:SetOperation(s.retop)
c:RegisterEffect(e4)
local e5=e4:Clone()
e5:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e5)
end

function s.efilter(e,re)
if e:GetHandler():GetEquipTarget():GetCounter(0x1108)==0 then return false end --check equipped monster for vaccine counter
return  e:GetHandlerPlayer()~=re:GetHandlerPlayer() or e:GetHandlerPlayer()==re:GetHandlerPlayer() and (re:GetHandler():GetCode()==86361354   or re:GetHandler():GetCode()==33184167   
or re:GetHandler():GetCode()==24725825   or re:GetHandler():GetCode()==22804644   or re:GetHandler():GetCode()==170000150   or re:GetHandler():GetCode()==4931121   or re:GetHandler():GetCode()==35027493
or re:GetHandler():GetCode()==39163598   or re:GetHandler():GetCode()==54591086   or
re:GetHandler():GetCode()==57728570   or re:GetHandler():GetCode()==84491298   or re:GetHandler():GetCode()==100000166   or
re:GetHandler():GetCode()==511000822   or re:GetHandler():GetCode()==511000823   or re:GetHandler():GetCode()==511002576   or
re:GetHandler():GetCode()==511005713 or re:GetHandler():GetCode()==800000012 or re:GetHandler():GetCode()==512000080 or re:GetHandler():GetCode()==54974237  )  
end

function s.filter(c)
return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if not c:IsLocation(LOCATION_SZONE) then return end
local tc=Duel.GetFirstTarget()
if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
Duel.Equip(tp,c,tc)
Duel.BreakEffect()
tc:AddCounter(0x1108,1)
end	
end

function s.con(e,c)
local c=e:GetHandler()
if  c:GetCounter(0x1108)>0 then return true
else return false
end
end

function s.retcon(e,tp,eg,ep,ev,re,r,rp)
local tc=eg:GetFirst()
return (tc:GetSummonType()&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE or (tc:GetSummonType()&SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
and tc:GetMaterialCount()>0
end

function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
local ec=c:GetPreviousEquipTarget()
local tc=eg:GetFirst()
local g=tc:GetMaterial()
if chkc then return g:IsContains(chkc) and chkc:IsCanBeEffectTarget(e) end
if chk==0 then return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
if #g>1 and g==ec then
g=g:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
end
Duel.SetTargetCard(g)
tc:CreateEffectRelation(e)
Duel.SetOperationInfo(0,CATEGORY_EQUIP,c,1,0,0)
end

function s.retop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local sc=eg:GetFirst()
local tc=Duel.GetFirstTarget()
if tc and tc:IsRelateToEffect(e) and (tc:IsReason(REASON_RELEASE) or tc:IsReason(REASON_FUSION)) and sc and sc:IsRelateToEffect(e) and sc:IsFaceup() and c and c:IsRelateToEffect(e) then
Duel.Equip(tp,c,sc)
Duel.BreakEffect()
sc:AddCounter(0x1108,1)
Duel.ConfirmCards(tc:GetPreviousControler(),tc)
end
end
