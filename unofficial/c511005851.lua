--Korogashi (DOR)
--scripted by GameMaster (GM) + Shad3 + Edo
local s,id=GetID()
function s.initial_effect(c)
----Reduce ATK! DEF!= -300 monsters located horizontal/vertical from location destroyed
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_BATTLE_DESTROYED)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
end

--filter for emzone
function s.filter(c,seq,tp)
local emzone=seq>4
if emzone then
if seq==5 then seq=1
else seq=3
end
end
return (c:IsColumn(seq,tp) or c:IsColumn(seq-1,tp) or c:IsColumn(seq+1,tp)) and ((emzone and c:IsLocation(LOCATION_MZONE)) or (not emzone and c:GetControler()==tp or c:IsInExtraMZone()))
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
--reduce cards in emzone
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e:GetHandler():GetPreviousSequence(),tp,e:GetHandler():GetPreviousLocation())
local tc=g:GetFirst()
while tc do 
local e1=Effect.CreateEffect(tc)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
e1:SetValue(-300)
tc:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
tc:RegisterEffect(e2)
tc=g:GetNext()
end
--reduce all your monsters and any opponent monster in same column
local c=e:GetHandler()
local p=c:GetPreviousControler()
local s=c:GetPreviousSequence()
local tg=Duel.GetMatchingGroup(Card.IsFaceup,p,LOCATION_MZONE,0,nil)
local tc=Duel.GetFieldCard(1-p,LOCATION_MZONE,4-s)
if tc then tg:AddCard(tc) end
local c=tg:GetFirst()
while c do
local e1=Effect.CreateEffect(c)
e1:SetType(EFFECT_TYPE_SINGLE)
e1:SetCode(EFFECT_UPDATE_ATTACK)
e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
e1:SetReset(RESET_EVENT+RESETS_STANDARD)
e1:SetValue(-300)
c:RegisterEffect(e1)
local e2=e1:Clone()
e2:SetCode(EFFECT_UPDATE_DEFENSE)
c:RegisterEffect(e2)
c=tg:GetNext()
end
end

