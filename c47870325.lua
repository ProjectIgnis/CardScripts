--スマイル・アクション
--Smile Action
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate attack
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove(POS_FACEDOWN)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local rg=Group.CreateGroup()
	for p=0,1 do
		if Duel.IsExistingMatchingCard(s.rmfilter,p,LOCATION_GRAVE,0,1,nil) and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)
			local g=Duel.SelectMatchingCard(p,s.rmfilter,p,LOCATION_GRAVE,0,1,5,nil)
			rg:Merge(g)
		end
	end
	if #rg>0 and Duel.Remove(rg,POS_FACEDOWN,REASON_EFFECT)>0 then
		local og=Duel.GetOperatedGroup()
		for tc in aux.Next(og) do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
	end
end
function s.thfilter(c)
	return c:GetFlagEffect(id)~=0 and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local at=Duel.GetAttacker()	
	local p=1-at:GetControler()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,p,LOCATION_REMOVED)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,p,LOCATION_HAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	local p=1-at:GetControler()
	if Duel.IsExistingMatchingCard(s.thfilter,p,LOCATION_REMOVED,0,1,nil) and Duel.SelectYesNo(p,aux.Stringid(id,2)) then
		local g=Duel.GetMatchingGroup(s.thfilter,p,LOCATION_REMOVED,0,nil)
		local tg=g:RandomSelect(p,1)
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		local tc=tg:GetFirst()
		if tc:IsDiscardable(REASON_EFFECT) and Duel.SelectYesNo(p,aux.Stringid(id,3)) then
			Duel.BreakEffect()
			Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)
			Duel.NegateAttack()
		else
			--double damage
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
			e1:SetOperation(s.damop)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabel(p)
			Duel.RegisterEffect(e1,p)
		end
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetLabel() then
		Duel.DoubleBattleDamage(ep)
	end
end

