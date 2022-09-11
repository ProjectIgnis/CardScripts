--オリエンタルタイガー
--Oriental Tiger
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Inflict Damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanChangePosition() end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,0,LOCATION_GRAVE,nil)
	if chk==0 then return #g>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(#g*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g*100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)~=0 then
		--Effect
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
		if Duel.GetMatchingGroupCount(Card.IsSpell,tp,0,LOCATION_GRAVE,nil)>=10 then
			Duel.BreakEffect()
			Duel.Damage(1-tp,1200,REASON_EFFECT)
		end
	end
end