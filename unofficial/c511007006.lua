--フラッシュ・ファング
--Flash Fang
--Scripted by Lyris
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsShark),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsAbleToEnterBP() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsShark),tp,LOCATION_MZONE,0,nil)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLE_DAMAGE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetLabel(fid)
		e2:SetOperation(s.regop)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(fid,RESET_PHASE|PHASE_END,0,1,0)
	end
	sg:KeepAlive()
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetLabel(fid)
	e2:SetLabelObject(sg)
	e2:SetCondition(s.descon)
	e2:SetOperation(s.desop)
	Duel.RegisterEffect(e2,tp)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	if ep==1-tp and Duel.GetAttackTarget()==nil then
		e:GetHandler():SetFlagEffectLabel(e:GetLabel(),e:GetHandler():GetFlagEffectLabel(e:GetLabel())+ev)
	end
end
function s.desfilter(c,fid)
	return c:GetFlagEffectLabel(fid)>0
end
function s.desopfilter(c,dam)
	return c:IsFaceup() and c:GetAttack()<dam
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local fid=e:GetLabel()
	local dg=g:Filter(s.desfilter,nil,fid)
	if #dg>0 then
		local dam=dg:GetSum(Card.GetFlagEffectLabel,fid)
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
	if #dg>0 then
		local dam=dg:GetSum(Card.GetFlagEffectLabel,fid)
		local sg=Duel.GetMatchingGroup(s.desopfilter,tp,0,LOCATION_MZONE,nil,dam)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end