--トライエッジ・マスター
--Tri-Edge Master
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--1 Tuner + 1+ non-Tuner monsters
	Synchro.AddProcedure(c,nil,1,1,Synchro.NonTuner(nil),1,99)
	--Apply effect(s) based on materials
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetLabel()>0 and e:GetHandler():IsSynchroSummoned() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
	--Check materials used for Synchro Summon
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_SINGLE)
	e1a:SetCode(EFFECT_MATERIAL_CHECK)
	e1a:SetLabelObject(e1)
	e1a:SetValue(s.matcheck)
	c:RegisterEffect(e1a)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lb=e:GetLabel()
	local g=(lb&0x1>0) and Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler()) or nil
	local dr=lb&0x2>0
	if chk==0 then return (not g or #g>0) and (not dr or Duel.IsPlayerCanDraw(tp,1)) end
	if g then Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0) end
	if dr then
		if lb==0x2 then
			Duel.SetTargetPlayer(tp)
			Duel.SetTargetParam(1)
		end
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	local index=(lb==0x1 and 1) or (lb==0x2 and 2) or (lb==0x4 and 3) or 4
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,index))
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lb=e:GetLabel()
	local breakeff=false
	--Destroy 1 other card on the field
	if lb&0x1>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
		if #g>0 then
			breakeff=true
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	--Draw 1 card
	if lb&0x2>0 then
		local p,d=tp,1
		if lb==0x2 then p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM) end
		if Duel.IsPlayerCanDraw(p) then
			if breakeff then Duel.BreakEffect() end
			breakeff=true
			Duel.Draw(p,d,REASON_EFFECT)
		end
	end
	--Treat this card as a Tuner
	if lb&0x4>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
		if breakeff then Duel.BreakEffect() end
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
function s.matcheck(e,c)
	local g=c:GetMaterial()
	local e1=e:GetLabelObject()
	e1:SetLabel(0)
	if #g>2 then
		e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
		e1:SetLabel(0x1|0x2|0x4)
	elseif #g==2 then
		local a=g:GetFirst():GetSynchroLevel(c)
		local b=g:GetNext():GetSynchroLevel(c)
		if a+b~=6 then return end
		local lv=math.min(a,b)
		if lv==1 then e1:SetCategory(CATEGORY_DESTROY)
		elseif lv==2 then e1:SetCategory(CATEGORY_DRAW) end
		e1:SetLabel(1<<(lv-1))
	end
end