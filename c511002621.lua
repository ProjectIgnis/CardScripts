--Duelist Kingdom
--scripted by GameMaster(GM)
local s,id=GetID()
function s.initial_effect(c)
--Activate	
local e1=Effect.CreateEffect(c)	
e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
e1:SetCode(EVENT_PREDRAW)
e1:SetRange(0x5f)
e1:SetOperation(s.op)
c:RegisterEffect(e1)
--summon without tribute level 5+>=
local e2=Effect.CreateEffect(c)
e2:SetType(EFFECT_TYPE_FIELD)
e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e2:SetCode(EFFECT_SUMMON_PROC)
e2:SetRange(LOCATION_REMOVED)
e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
e2:SetCondition(s.ntcon)
c:RegisterEffect(e2)
local e3=e2:Clone()
e3:SetCode(EFFECT_SET_PROC)
c:RegisterEffect(e3)
--cannot direct attack
local e4=Effect.CreateEffect(c)
e4:SetType(EFFECT_TYPE_FIELD)
e4:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
e4:SetRange(LOCATION_REMOVED)
e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
c:RegisterEffect(e4)
--card unaffected/protection
local e5=Effect.CreateEffect(c)
e5:SetType(EFFECT_TYPE_SINGLE)
e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
e5:SetRange(LOCATION_REMOVED)
e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
e5:SetValue(1)
c:RegisterEffect(e5)
local e6=e5:Clone()
e6:SetCode(EFFECT_IMMUNE_EFFECT)
e6:SetValue(s.ctcon2)
c:RegisterEffect(e6)
--return damage when your monster destroyed
local e7=Effect.CreateEffect(c)
e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e7:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
e7:SetCode(EVENT_DESTROYED)
e7:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e7:SetRange(LOCATION_REMOVED)
e7:SetCondition(s.con7)
e7:SetTarget(s.tg7)
e7:SetOperation(s.op7)
c:RegisterEffect(e7)
--return damage when opponents monster destroyed
local e8=Effect.CreateEffect(c)
e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_DELAY)
e8:SetCode(EVENT_DESTROYED)
e8:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
e8:SetRange(LOCATION_REMOVED)
e8:SetCondition(s.con8)
e8:SetTarget(s.tg8)
e8:SetOperation(s.op8)
c:RegisterEffect(e8)
--change pos turn summoned
local e9=Effect.CreateEffect(c)
e9:SetCategory(CATEGORY_POSITION)
e9:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
e9:SetRange(LOCATION_REMOVED)
e9:SetCode(EVENT_SUMMON_SUCCESS)
e9:SetTarget(s.tg9)
e9:SetOperation(s.op9)
c:RegisterEffect(e9)
local e10=e9:Clone()
e10:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e10)
--change pos turn opp summoned
local e11=Effect.CreateEffect(c)
e11:SetCategory(CATEGORY_CONTROL)
e11:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
e11:SetRange(LOCATION_REMOVED)
e11:SetCode(EVENT_SUMMON_SUCCESS)
e11:SetTarget(s.tg11)
e11:SetOperation(s.op11)
c:RegisterEffect(e11)
local e12=e11:Clone()
e12:SetCode(EVENT_SPSUMMON_SUCCESS)
c:RegisterEffect(e12)
--extra protection boss duel etc..
local eb=Effect.CreateEffect(c)
eb:SetType(EFFECT_TYPE_SINGLE)
eb:SetCode(EFFECT_CANNOT_TO_DECK)
eb:SetRange(LOCATION_REMOVED)
c:RegisterEffect(eb)
local ec=eb:Clone()
ec:SetCode(EFFECT_CANNOT_TO_HAND)
c:RegisterEffect(ec)
local ed=eb:Clone()
ed:SetCode(EFFECT_CANNOT_TO_GRAVE)
c:RegisterEffect(ed)
local ee=eb:Clone()
ee:SetCode(EFFECT_CANNOT_REMOVE)
c:RegisterEffect(ee)
end

--start of duel activation effect 
function s.op(e,tp,eg,ep,ev,re,r,rp,chk)
local c=e:GetHandler()
if not Duel.SelectYesNo(1-tp,aux.Stringid(5555,0)) or not Duel.SelectYesNo(tp,aux.Stringid(5555,0)) then
local sg=Duel.GetMatchingGroup(Card.IsCode,tp,0x7f,0x7f,nil,id)
Duel.SendtoDeck(sg,nil,-2,REASON_RULE)
return
end	
if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_REMOVED,0,1,nil,id) then
Duel.DisableShuffleCheck()
Duel.SendtoDeck(c,nil,-2,REASON_RULE)
else
Duel.Remove(c,POS_FACEUP,REASON_RULE)
Duel.Hint(HINT_CARD,0,id)
end
if c:GetPreviousLocation()==LOCATION_HAND then
Duel.Draw(tp,1,REASON_RULE)
end
end

--Card unaffected Value
function s.ctcon2(e,re)
return re:GetHandler()~=e:GetHandler()
end

--summon without tribute effect
function s.ntcon(e,c)
if c==nil then return true end
if c:IsLevelBelow(4) then return false end
if c:IsLevelAbove(5) then return true end
return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 
end

--change self monster pos turn summoned
function s.filter(c,e,tp)
return c:IsFaceup() and c:IsControler(tp) 
end
function s.tg9(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return eg:IsExists(s.filter,1,nil,e,tp) end
end

function s.op9(e,tp,eg,ep,ev,re,r,rp,chk)
local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil,e,tp)
local tc=g:GetFirst()
while  tc do
tc:SetStatus(STATUS_SUMMON_TURN,false)
tc:SetStatus(STATUS_SPSUMMON_TURN,false)
tc=g:GetNext()
end
end


--opp can change monster pos turn summoned
function s.filter4(c,e,tp)
return c:IsFaceup() and c:GetControler()==1-tp 
end
function s.tg11(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
if chk==0 then return eg:IsExists(s.filter4,1,nil,e,tp) end
end

function s.op11(e,tp,eg,ep,ev,re,r,rp,chk)
local g=Duel.GetMatchingGroup(s.filter4,tp,0,LOCATION_MZONE,nil,e,tp)
local tc=g:GetFirst()
while  tc do
tc:SetStatus(STATUS_SUMMON_TURN,false)
tc:SetStatus(STATUS_SPSUMMON_TURN,false)
tc=g:GetNext()
end
end

--Damage effect

--self
function s.cfilter(c,tp)
return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
end

function s.con7(e,tp,eg,ep,ev,re,r,rp)
return eg:IsExists(s.cfilter,1,nil,tp)
end

function s.tg7(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
local dam=eg:Filter(s.cfilter,nil,tp):GetSum(Card.GetAttack)/2
Duel.SetTargetPlayer(tp)
Duel.SetTargetParam(dam)
end

function s.op7(e,tp,eg,ep,ev,re,r,rp)
local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
Duel.Damage(p,d,REASON_EFFECT)
end

--opp
function s.cfilter2(c,tp)
return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==1-tp
end

function s.con8(e,tp,eg,ep,ev,re,r,rp)
return eg:IsExists(s.cfilter2,1,nil,tp)
end

function s.tg8(e,tp,eg,ep,ev,re,r,rp,chk)
if chk==0 then return true end
local dam=eg:Filter(s.cfilter2,nil,tp):GetSum(Card.GetAttack)/2
Duel.SetTargetPlayer(1-tp)
Duel.SetTargetParam(dam)
end

function s.op8(e,tp,eg,ep,ev,re,r,rp)
local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
Duel.Damage(p,d,REASON_EFFECT)
end



