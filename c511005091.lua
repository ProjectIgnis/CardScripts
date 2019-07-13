--Sacrifice's Blast
--  By Shad3
local s,id=GetID()

function s.initial_effect(c)
	--Globals
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SSET)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetCondition(s.gtg_cd)
		ge1:SetOperation(s.gtg_op)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_SUMMON_SUCCESS)
		ge2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge2:SetOperation(s.sum_op)
		Duel.RegisterEffect(ge2,0)
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_LEAVE_FIELD_P)
		ge3:SetOperation(s.reflag_op)
		Duel.RegisterEffect(ge3,0)
	end)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end

function s.gtg_cd(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsOriginalCode,1,nil,id)
end

function s.gtg_op(e,tp,eg,ep,ev,re,r,rp)
  local g=eg:Filter(Card.IsOriginalCode,nil,id)
	local c=g:GetFirst()
	while c do
		local p=c:GetControler()
		if Duel.GetFieldGroupCount(p,LOCATION_MZONE,LOCATION_MZONE)>0 then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TARGET)
			local tc=Duel.GetFieldGroup(p,LOCATION_MZONE,LOCATION_MZONE):Select(p,1,1,nil):GetFirst()
			local fid=c:GetFieldID()
			tc:RegisterFlagEffect(id,RESET_EVENT+0x1000000,0,0,fid)
		end
		c=g:GetNext()
	end
end

function s.fid_chk(c,id)
	return c:GetFieldID()==id
end

function s.sum_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if (tc:GetSummonType()&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE then
		local g=tc:GetMaterial()
		local sactg={}
		g:ForEach(function(c)
			if c:GetFlagEffect(id)~=0 then
				sactg[c:GetFlagEffectLabel(id)]=true
				c:ResetFlagEffect(id)
			end
		end)
		local sg=Duel.GetMatchingGroup(Card.IsOriginalCode,0,LOCATION_SZONE,LOCATION_SZONE,nil,id)
		sg:ForEach(function(c)
			local fid=c:GetFieldID()
			if sactg[fid] then
				c:GetActivateEffect():SetLabel(tc:GetFieldID())
				local e1=Effect.CreateEffect(tc)
				e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
				e1:SetCode(id)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
				e1:SetRange(LOCATION_MZONE)
				e1:SetOperation(s.des_op)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
			end
		end)
	end
end

function s.des_op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.Destroy(c,REASON_EFFECT)~=0 then
		Duel.Damage(c:GetPreviousControler(),c:GetPreviousAttackOnField(),REASON_EFFECT)
	end
end

function s.reflag_op(e,tp,eg,ep,ev,re,r,rp)
	local c=eg:GetFirst()
	while c do
		if c:GetFlagEffect(id)~=0 then
			if (c:GetReason()&REASON_RELEASE)==0 then
				c:ResetFlagEffect(id)
			end
		end
		c=eg:GetNext()
	end
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ac=Duel.GetAttacker()
	if chk==0 then 
		return ac:GetControler()~=tp and e:GetLabel()==ac:GetFieldID()
	end
	e:GetHandler():SetCardTarget(ac)
end

function s.op(e,tp,eg,ep,ev,re,r,rp)
	local ac=e:GetHandler():GetFirstCardTarget()
	if ac then
		Duel.RaiseSingleEvent(ac,id,e,REASON_EFFECT,tp,tp,e:GetHandler():GetFieldID())
	end
end