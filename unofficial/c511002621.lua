--デュエリスト・キングダム
--Duelist Kingdom
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
	--no direct
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	Duel.RegisterEffect(e1,0)
	--summon face-up defense
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_LIGHT_OF_INTERVENTION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(1,1)
	Duel.RegisterEffect(e2,0)
	--summon any level
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e3:SetTarget(s.nttg)
	e3:SetCondition(s.ntcon)
	Duel.RegisterEffect(e3,0)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_SET_PROC)
	e4:SetTarget(s.nttg2)
	Duel.RegisterEffect(e4,0)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	e5:SetTarget(s.nttg3)
	Duel.RegisterEffect(e5,0)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_LIMIT_SET_PROC)
	e6:SetTarget(s.nttg4)
	Duel.RegisterEffect(e6,0)
	--set up flags to prevent loop with above effect
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_ADJUST)
	e7:SetCondition(s.limitcon)
	e7:SetOperation(s.limitop)
	Duel.RegisterEffect(e7,0)
	--burn for destroy
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetCode(EVENT_DESTROYED)
	e8:SetOperation(s.damop)
	Duel.RegisterEffect(e8,0)
	 --cannot attack
	local e9=Effect.CreateEffect(c)
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e9:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e9:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e9:SetCondition(s.atkcon)
	e9:SetTarget(s.atktg)
	Duel.RegisterEffect(e9,0)
	--check
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e10:SetCode(EVENT_ATTACK_ANNOUNCE)
	e10:SetOperation(s.atkcheckop)
	e10:SetLabelObject(e9)
	Duel.RegisterEffect(e10,0)
	local e11=Effect.CreateEffect(c)
	e11:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e11:SetCode(EVENT_PHASE+PHASE_END)
	e11:SetCountLimit(1)
	e11:SetCondition(s.wincon)
	e11:SetOperation(s.winop)
	Duel.RegisterEffect(e11,0)
end
function s.limitfilter(c)
	return c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) and c:GetFlagEffect(id)==0
end
function s.limitfilter2(c)
	return c:IsHasEffect(EFFECT_LIMIT_SET_PROC) and c:GetFlagEffect(id+1)==0
end
function s.limitcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.limitfilter,tp,0xff,0xff,1,nil) or Duel.IsExistingMatchingCard(s.limitfilter2,tp,0xff,0xff,1,nil)
end
function s.limitop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.limitfilter,tp,0xff,0xff,nil)
	for tc in aux.Next(g) do
		tc:RegisterFlagEffect(id,0,0,0)
	end
	local g2=Duel.GetMatchingGroup(s.limitfilter2,tp,0xff,0xff,nil)
	for tc in aux.Next(g2) do
		tc:RegisterFlagEffect(id+1,0,0,0)
	end
end
function s.nttg(e,c)
	return c==0 or c==1 or c:GetFlagEffect(id)==0
end
function s.nttg2(e,c)
	return c==0 or c==1 or c:GetFlagEffect(id+1)==0
end
function s.nttg3(e,c)
	return c==0 or c==1 or c:GetFlagEffect(id)~=0
end
function s.nttg4(e,c)
	return c==0 or c==1 or c:GetFlagEffect(id+1)~=0
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return minc==0 and max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.damfilter(c,p)
	return c:IsPreviousControler(p) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		local pg=eg:Filter(s.damfilter,nil,p)
		if #pg>0 then
			local sum=pg:GetSum(Card.GetPreviousAttackOnField)//2
			if sum>0 then
				Duel.Damage(p,sum,REASON_EFFECT)
			end
		end
	end
end
function s.atkcon(e)
	return e:GetHandler():GetFlagEffect(id-1)~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.atkcheckop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id-1)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(id-1,RESET_PHASE|PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
function s.wincon(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetTurnPlayer()
	return Duel.GetFieldGroupCount(p,LOCATION_MZONE,0)==0 and Duel.GetActivityCount(p,ACTIVITY_NORMALSUMMON)==0 
		and Duel.GetActivityCount(p,ACTIVITY_SPSUMMON)==0 and Duel.GetActivityCount(p,ACTIVITY_FLIPSUMMON)==0
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local WIN_REASON=0x58
	local p=Duel.GetTurnPlayer()
	if Duel.GetFieldGroupCount(p,LOCATION_MZONE,0)==0 and Duel.GetActivityCount(p,ACTIVITY_NORMALSUMMON)==0 
		and Duel.GetActivityCount(p,ACTIVITY_SPSUMMON)==0 and Duel.GetActivityCount(p,ACTIVITY_FLIPSUMMON)==0 then
		Duel.Win(1-p,WIN_REASON)
	end
end