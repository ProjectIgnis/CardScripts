--クイック・アタック
--Quick Rush
--fixed by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.IsPlayerCanDraw(tp,1)
	local b2=Duel.GetTurnCount()==1 and Duel.GetCurrentPhase()<=PHASE_BATTLE
	if chk==0 then return b1 or b2 end
	local op=0
	Duel.Hint(HINT_SELECTMSG,tp,550)
	if b1 and b2 then
		op=Duel.SelectOption(tp,aux.Stringid(22093873,0),1157)
	elseif Duel.IsPlayerCanDraw(tp,1) then
		op=0
	else
		op=1
	end
	e:SetLabel(op)
	if op==0 then
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		Duel.SetTargetPlayer(tp)
		Duel.SetTargetParam(1)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetLabel()==0 then
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Draw(p,d,REASON_EFFECT)
	else
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_BP_FIRST_TURN)
		e1:SetTargetRange(1,1)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetCondition(s.atkcon)
		e2:SetTarget(s.atktg)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.atkcon(e)
	return Duel.GetTurnCount()==1
end
function s.atktg(e,c)
	return not c:IsLevelBelow(4)
end
