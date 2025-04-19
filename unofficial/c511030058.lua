--機塊リデュース
--Appliancer Reduction
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Halve damage
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.dmgcon)
	e2:SetCost(Cost.SelfBanish)
	e2:SetOperation(s.dmgop)
	c:RegisterEffect(e2)
end
s.listed_series={0x14a}
function s.confilter(c)
	return c:IsSetCard(SET_APPLIANCER) and c:IsType(TYPE_LINK) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.rmfilter(c)
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rmg=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	local drg=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_MZONE,0,nil)
	local ct=drg:GetClassCount(Card.GetCode)
	if chk==0 then return #rmg>0 and #drg>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,rmg,#rmg,0,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rmg=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	if #rmg>0 and Duel.Remove(rmg,POS_FACEUP,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup():Filter(Card.IsLocation,nil,LOCATION_REMOVED)
		if #og>0 then
			local drg=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_MZONE,0,nil)
			local ct=drg:GetClassCount(Card.GetCode)
			if ct>0 then
				Duel.BreakEffect()
				Duel.Draw(tp,ct,REASON_EFFECT)
			end
		end
	end
end
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=Duel.GetAttacker()
	return bc and bc:IsControler(1-tp)
end
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(HALF_DAMAGE)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end