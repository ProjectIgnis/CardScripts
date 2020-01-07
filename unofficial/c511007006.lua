--coded by Lyris
--Flash Fang
--fixed by MLD
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsShark()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=sg:GetFirst()
	while tc do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		tc:RegisterFlagEffect(51107006,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLE_DAMAGE)
		e2:SetOperation(s.regop)
		tc:RegisterEffect(e2)
		tc=sg:GetNext()
	end
	sg:KeepAlive()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(sg)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp and Duel.GetAttackTarget()==nil then
		local c=e:GetHandler()
		c:SetFlagEffectLabel(51107006,c:GetFlagEffectLabel(51107006)+ev)
	end
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(51107006)-fid>0
end
function s.desopfilter(c,dam)
	return c:GetAttack()<dam
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	local dg=g:Filter(s.desfilter,nil,fid)
	if #dg~=0 then
		local dam=0
		local tc=dg:GetFirst()
		while tc do
			dam=dam+(tc:GetFlagEffectLabel(51107006)-fid)
			tc=dg:GetNext()
		end
		return Duel.IsExistingMatchingCard(s.desopfilter,tp,0,LOCATION_MZONE,1,nil,dam)
	else
		g:DeleteGroup()
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	local dg=g:Filter(s.desfilter,nil,fid)
	g:DeleteGroup()
	local dam=0
	local tc=dg:GetFirst()
	while tc do
		dam=dam+(tc:GetFlagEffectLabel(51107006)-fid)
		tc=dg:GetNext()
	end
	local sg=Duel.GetMatchingGroup(s.desopfilter,tp,0,LOCATION_MZONE,nil,dam)
	Duel.Destroy(sg,REASON_EFFECT)
end
