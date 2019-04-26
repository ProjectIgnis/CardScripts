--ドロー・ディスチャージ
--Draw Discharge
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetCurrentPhase()~=PHASE_DRAW
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(eg)
	if eg and eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetAttack())
		Duel.SetOperationInfo(0,CATEGORY_REMOVE+CATEGORY_HANDES,nil,0,1-tp,1)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e)
	if g and #g>0 then
		Duel.ConfirmCards(tp,g)
		if g:IsExists(Card.IsType,1,nil,TYPE_MONSTER) then
			Duel.BreakEffect()
			local atk=0
			local tc=g:GetFirst()
			while tc do
				local tatk=tc:GetAttack()
				if tatk>0 then atk=atk+tatk end
				tc=g:GetNext()
			end
			if Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
		Duel.ShuffleHand(1-tp)
	end
end