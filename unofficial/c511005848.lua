--Anti-Magic Fragrance (DOR)
--scripted by GameMaster (GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_ACTIVATE)
e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
e1:SetCode(EVENT_FREE_CHAIN)
e1:SetTarget(s.target)
e1:SetOperation(s.activate)
c:RegisterEffect(e1)
end

function s.filter(c)
return  c:IsRace(RACE_PLANT) and c:IsFaceup()
end

function s.con(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
return bc and bc:IsRace(RACE_SPELLCASTER)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
local tc=Duel.GetFirstTarget()
if tc:IsRelateToEffect(e)  then
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetCategory(CATEGORY_DESTROY)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
e1:SetCode(EVENT_BATTLE_START)
e1:SetCondition(s.con)
e1:SetTarget(s.destg)
e1:SetOperation(s.desop)
e1:SetReset(RESET_EVENT+0x00040000)
tc:RegisterEffect(e1)
--negate
local e2=Effect.CreateEffect(e:GetHandler())
e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e2:SetCode(EVENT_BATTLED)
e2:SetOperation(s.desop)
tc:RegisterEffect(e2)
end
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
if #g>0 then
local tg=g
if #tg>0 then
Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
Duel.SetTargetCard(tg)
Duel.HintSelection(g)
end
end
end

function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
local bc=c:GetBattleTarget()
if chk==0 then return bc and bc:IsFaceup() and bc:IsRace(RACE_SPELLCASTER) end
Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end

function s.desop(e,tp,eg,ep,ev,re,r,rp)
local c=e:GetHandler()
if  Duel.GetAttacker()==nil or Duel.GetAttackTarget()==nil then return end	
local bc=c:GetBattleTarget()
if not bc and bc:IsRace(RACE_SPELLCASTER) then return end
if bc:IsRelateToBattle() and bc:IsRace(RACE_SPELLCASTER) then
Duel.Destroy(bc,REASON_EFFECT)
local e1=Effect.CreateEffect(e:GetHandler())
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_DISABLE)
e1:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE)
bc:RegisterEffect(e1)
local e2=Effect.CreateEffect(e:GetHandler())
e2:SetType(EFFECT_TYPE_SINGLE)
e2:SetCode(EFFECT_DISABLE_EFFECT)
e2:SetReset(RESET_EVENT+RESETS_STANDARD_EXC_GRAVE)
bc:RegisterEffect(e2)
end
end