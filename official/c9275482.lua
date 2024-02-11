--幻日灯火
--UFOLight
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent cannot target this card with card effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function() return not Duel.IsBattlePhase() end)
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	--Neither monster can be destroyed by battle
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Draw 1 card
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
function s.indestg(e,c)
	local handler=e:GetHandler()
	return c==handler or c==handler:GetBattleTarget()
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and Duel.IsPlayerCanRemove(tp) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,1,REASON_EFFECT)>0 then
		Duel.ShuffleHand(tp)
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,ct,nil)
		if #g==0 then return end
		Duel.BreakEffect()
		if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)==0 then return end
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_REMOVED)
		local c=e:GetHandler()
		if ct>0 and c:IsRelateToEffect(e) and c:IsFaceup() then
			--Gains 500 ATK for each card banished by this effect
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(500*ct)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end