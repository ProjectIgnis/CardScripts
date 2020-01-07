--Flame Swordsman (DM)
--Scripted by edo9300
Duel.LoadScript("c300.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(0xda,0xff)
	--immune to counter cleaner
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_PZONE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetOperation(s.ctop)
	c:RegisterEffect(e0)
	--transfer atk
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51100567,6))
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(0xff)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.con)
	e3:SetCost(s.trcost)
	e3:SetTarget(s.trtg)
	e3:SetOperation(s.trop)
	c:RegisterEffect(e3)
	local e3a=e3:Clone()
	e3a:SetRange(LOCATION_MZONE)
	e3a:SetCondition(s.con2)
	e3a:SetCost(s.trcost2)
	c:RegisterEffect(e3a)
end
s.listed_names={38834303}
s.dm=true
s.dm_spsummon_op=function(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		local ct=c:GetCounter(0xda)
		Duel.SendtoDeck(c,2,-2,REASON_RULE)
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(ct*100)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(300,0,EFFECT_FLAG_CLIENT_HINT,1,0,63)
		Duel.ResetFlagEffect(tp,301)
	end
end
s.dm_op=function(c)
	c:AddCounter(0xda,18)
end
function s.ctpermit(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_SZONE) and not c:IsStatus(STATUS_DISABLED)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDeckMaster(true)
end
function s.con2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDeckMaster() and e:GetHandler():IsLocation(LOCATION_MZONE)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	e:GetHandler():AddCounter(0xda,ct)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():GetCode()~=38834303 then return end
	if re:GetHandler():IsCode(38834303) then
		local e0=Effect.CreateEffect(c)	
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e0:SetCode(EVENT_CHAIN_SOLVED)
		e0:SetRange(LOCATION_PZONE+LOCATION_MZONE)
		e0:SetOperation(s.op)
		e0:SetLabel(c:GetCounter(0xda))
		e0:SetReset(RESET_CHAIN)
		c:RegisterEffect(e0)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:GetHandler():AddCounter(0xda,18)
end
function s.trcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	if chk==0 then return c:GetCounter(0xda)>=1 end
	local t={}
	local l=1
	while l<=e:GetHandler():GetCounter(0xda) do
		t[l]=l*100
		l=l+1
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51100567,7))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(announce)
	c:RemoveCounter(tp,0xda,announce/100,REASON_COST)
end
function s.trcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
	if chk==0 then return c:GetAttack()>=100 end
	local m=math.floor(c:GetAttack()/100)
	local t={}
	for i=1,m do
		t[i]=i*100
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(51100567,7))
	local announce=Duel.AnnounceNumber(tp,table.unpack(t))
	e:SetLabel(announce)	
	local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_COPY_INHERIT)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-announce)
		c:RegisterEffect(e1)
end
function s.trfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
function s.trtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.trfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.trfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.trfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.trop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(e:GetLabel())
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e2)
end
