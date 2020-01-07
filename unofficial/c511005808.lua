-- Battle Warrior(DOR)
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--+500 atk/def against beast type monsters
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
e1:SetRange(LOCATION_MZONE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetCondition(s.condtion)
e1:SetValue(500)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e2)
end

function s.condtion(e)
local ph=Duel.GetCurrentPhase()
if not (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL) or not e:GetHandler():IsRelateToBattle() then return false end
local bc=e:GetHandler():GetBattleTarget()
return bc and bc:IsFaceup() and bc:IsRace(RACE_BEAST)
end

