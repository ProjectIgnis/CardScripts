--救惺望御
--Star Salvation Shield
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate(summon)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_DRAW)
	e3:SetCondition(s.condition2)
	c:RegisterEffect(e3)
end
function s.filter1(c,tp)
	return c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter1,1,nil,tp) and Duel.IsTurnPlayer(1-tp)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsTurnPlayer(1-tp)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_MZONE,0,1,nil) end
end
function s.ctrlfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MAGICALKNIGHT) and c:IsLevelAbove(9) and c:IsType(TYPE_FUSION) and c:GetBaseAttack()==3000 and c:IsControlerCanBeChanged(true)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToGraveAsCost),tp,LOCATION_MZONE,0,1,1,nil)
	g=g:AddMaximumCheck()
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		--can attack once
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCondition(s.atkcon)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetOperation(s.checkop)
		e2:SetReset(RESET_PHASE|PHASE_END)
		e2:SetLabelObject(e1)
		Duel.RegisterEffect(e2,tp)
		if Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			local dg=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil)
			if #dg>0 then
				Duel.HintSelection(dg,true)
				Duel.GetControl(dg,tp)
			end
		end
	end
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end