--GO-DDD神零王ゼロゴッド・レイジ
--Divine Go-D/D/D Zero King Zero G.O.D. Reiji
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--damage reduce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.damval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	c:RegisterEffect(e2)
	--decrease tribute
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.ntcon)
	e3:SetTarget(aux.FieldSummonProcTg(s.nttg))
	c:RegisterEffect(e3)
	--apply effect
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(s.cost)
	e4:SetTarget(s.target)
	e4:SetOperation(s.operation)
	c:RegisterEffect(e4)
	--change atk
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,5))
	e5:SetCategory(CATEGORY_ATKCHANGE)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_ATTACK_ANNOUNCE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
	--battle
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e7:SetValue(1)
	c:RegisterEffect(e7)
end
s.listed_series={0xaf}
function s.damval(e,re,val,r,rp,rc)
	local c=e:GetHandler()
	local tp=e:GetHandlerPlayer()
	if r&REASON_EFFECT~=0 and Duel.GetFlagEffect(tp,id)==0 then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		return 0
	end
	return val
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsSetCard(0xaf)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,e:GetHandler()) end
	local g=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,1,false,nil,e:GetHandler())
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not e:GetHandler():IsHasEffect(EFFECT_DIRECT_ATTACK)
	local b2=Duel.GetFlagEffect(1-tp,id+1)==0
	local b3=Duel.GetFlagEffect(1-tp,id+2)==0
	if chk==0 then return b1 or b2 or b3 end
	local stab={}
	local dtab={}
	if b1 then
		table.insert(stab,0x1)
		table.insert(dtab,aux.Stringid(id,2))
	end
	if b2 then
		table.insert(stab,0x2)
		table.insert(dtab,aux.Stringid(id,3))
	end
	if b3 then
		table.insert(stab,0x4)
		table.insert(dtab,aux.Stringid(id,4))
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	local op=Duel.SelectOption(tp,table.unpack(dtab))+1
	e:SetLabel(stab[op])
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	if op==0x1 then
		if not c:IsRelateToEffect(e) then return end
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	elseif op==0x2 then
		Duel.RegisterFlagEffect(1-tp,id+1,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,aux.Stringid(id,3))
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetTargetRange(0,1)
		e2:SetValue(s.aclimit1)
		e2:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e2,tp)
	else
		Duel.RegisterFlagEffect(1-tp,id+2,RESET_PHASE+PHASE_END,EFFECT_FLAG_CLIENT_HINT,1,aux.Stringid(id,4))
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetCode(EFFECT_CANNOT_ACTIVATE)
		e3:SetTargetRange(0,1)
		e3:SetValue(s.aclimit2)
		e3:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e3,tp)
	end
end
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(1-tp)<=4000
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lp=Duel.GetLP(1-tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(lp)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
function s.aclimit1(e,re,tp)
	local rc=re:GetHandler()
	return rc and rc:IsLocation(LOCATION_SZONE)
end
function s.aclimit2(e,re,tp)
	local rc=re:GetHandler()
	return rc and rc:IsLocation(LOCATION_HAND+LOCATION_GRAVE)
end