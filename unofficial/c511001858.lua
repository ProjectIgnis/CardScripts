--ハイド・アンド・シャーク
--Hide and Shark
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Banish 1 "Shark" monster, end the Battle Phase, return the monster to the field and increase its ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetLP(tp)<=2000
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then
		local lp=math.floor(Duel.GetLP(tp)/2)
		for _,eff in pairs({Duel.IsPlayerAffectedByEffect(tp,EFFECT_LPCOST_CHANGE)}) do
			local val=eff:GetValue()
			if (type(val)=='integer' and val==0)
				or (type(val)=='function' and (val(eff,e,tp,lp)~=lp)) then
				return false
			end
		end
		return true
	end
end
function s.filter(c)
	return c:IsFaceup() and c:IsShark() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	local lp=Duel.GetLP(tp)//2
	Duel.PayLPCost(tp,lp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	Duel.SetTargetParam(lp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
	if tc then
		Duel.HintSelection(tc,true)
		if Duel.Remove(tc,POS_FACEUP,REASON_EFFECT|REASON_TEMPORARY)>0 then
			Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE|PHASE_BATTLE_STEP,1)
			Duel.BreakEffect()
			Duel.ReturnToField(tc)
			--Gain ATK equal to the amount of LP paid
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			e1:SetValue(Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM))
			tc:RegisterEffect(e1)
		end
	end
end