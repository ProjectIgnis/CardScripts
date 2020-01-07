--Change slime (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
local e0=Effect.CreateEffect(c)
e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e0:SetCode(EVENT_BE_BATTLE_TARGET)
e0:SetRange(LOCATION_MZONE)
e0:SetCondition(s.con)
e0:SetOperation(s.op)
e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
c:RegisterEffect(e0)
--atk def
local e1=Effect.CreateEffect(c)
e1:SetDescription(aux.Stringid(id,0))
e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_SET_AVAILABLE)
e1:SetTarget(s.target)
e1:SetOperation(s.operation)
c:RegisterEffect(e1)
e0:SetLabelObject(e1)
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
return e:GetHandler():IsPosition(POS_FACEDOWN)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
local te=e:GetLabelObject()
local tetype=te:GetType()
local tecode=te:GetCode()
te:SetType(EFFECT_TYPE_ACTIVATE)
te:SetCode(EVENT_FREE_CHAIN)
local act=false
if te:IsActivatable(tp) then act=true end
te:SetType(tetype)
te:SetCode(tecode)
if not act then return end
Duel.ChangePosition(e:GetHandler(),POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE)
end	

function s.filter(c)
return c:GetBattleTarget()
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_MZONE,1,nil) end
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if not bc:IsRelateToBattle() or bc:IsFacedown() then return end
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_SET_ATTACK_FINAL)
e1:SetValue(bc:GetBaseAttack())
e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
c:RegisterEffect(e1)
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
e2:SetValue(bc:GetBaseDefense())
e2:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
c:RegisterEffect(e2)
end