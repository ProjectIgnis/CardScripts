--pupa of moth
--Scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--spsummon great moth if destroyed before count 5
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,1))
e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_BATTLE_DESTROYED)
e1:SetCondition(s.condition)
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
--cannot attack
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e2:SetRange(LOCATION_MZONE)
e2:SetCode(EFFECT_CANNOT_ATTACK)
c:RegisterEffect(e2)
--spsummon perfectly ultimate great moth
local e3=Effect.CreateEffect(c)
e3:SetDescription(aux.Stringid(id,0))
e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e3:SetRange(LOCATION_MZONE)
e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
e3:SetCondition(s.spcon)
e3:SetCost(s.spcost)
e3:SetTarget(s.sptg)
e3:SetOperation(s.spop)
c:RegisterEffect(e3)
--required
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e4:SetCode(EVENT_SUMMON_SUCCESS)
e4:SetOperation(s.regop)
c:RegisterEffect(e4)
local e5=e4:Clone()
e5:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e5)
local e6=e4:Clone()
e6:SetCode(EVENT_FLIP)
c:RegisterEffect(e6)
--to defense
local e7=Effect.CreateEffect(c)
e7:SetDescription(aux.Stringid(id,0))
e7:SetCategory(CATEGORY_POSITION)
e7:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
e7:SetCode(EVENT_SUMMON_SUCCESS)
e7:SetTarget(s.potg)
e7:SetOperation(s.poop)
c:RegisterEffect(e7)
local e8=e7:Clone()
e8:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
c:RegisterEffect(e8)
local e9=e7:Clone()
e9:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e9)
end
s.listed_names={14141448,48579379}
function s.potg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return e:GetHandler():IsAttackPos() end
Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
function s.poop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
return not e:GetHandler():IsLocation(LOCATION_DECK) and e:GetHandler():IsReason(REASON_BATTLE)
end
function s.spfilter(c,e,tp)
return c:IsCode(14141448) and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACE_UP)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
if #g>0 then
Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
Duel.ConfirmCards(1-tp,g)
end
Duel.SpecialSummonComplete()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
e:GetHandler():RegisterFlagEffect(34830503,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(34830503)==0
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
function s.spfilter2(c,e,tp)
return c:IsCode(48579379) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
local g=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
local tc=g:GetFirst()
if tc then
Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
tc:RegisterFlagEffect(48579379,RESET_EVENT+0x16e0000,0,0)
tc:CompleteProcedure()
end
end
