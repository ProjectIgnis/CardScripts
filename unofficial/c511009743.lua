--メディックドローン・ドック
--Medicdrone Dock
--cleaned up by MLD
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--link summon
	Link.AddProcedure(c,s.mfilter,2)
	c:EnableReviveLimit()
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.reccon1)
	e1:SetTarget(s.rectg1)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	--recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,id+10000)
	e2:SetCondition(s.reccon2)
	e2:SetTarget(s.rectg2)
	e2:SetOperation(s.recop)
	c:RegisterEffect(e2)
end
function s.mfilter(c,lc,sumtype,tp)
	return c:IsDrone()
end
function s.reccon1(e,tp,eg,ep,ev,re,r,rp)
	local atk=0
	eg:ForEach(function(tc)
		if tc:IsReason(REASON_DESTROY) and tc:IsReason(REASON_BATTLE+REASON_EFFECT)
			and tc:IsDrone() and not tc:IsPreviousLocation(LOCATION_SZONE) then
			local tatk=tc:GetTextAttack()
			if tatk>atk then atk=tatk end
		end
	end)
	if atk>0 then e:SetLabel(atk) end
	return atk>0
end
function s.rectg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local lp=e:GetLabel()
	Duel.SetTargetParam(lp)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_NONE,lp)
end
function s.reccon2(e,tp,eg,ep,ev,re,r,rp)
	return r&REASON_EFFECT+REASON_BATTLE~=0
end
function s.rectg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetParam(1000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,PLAYER_NONE,1000)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local opt=Duel.SelectOption(tp,aux.Stringid(58074572,0),aux.Stringid(58074572,1))
	local p=(opt==0 and tp or 1-tp)
	local d=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	Duel.Recover(p,d,REASON_EFFECT)
end
