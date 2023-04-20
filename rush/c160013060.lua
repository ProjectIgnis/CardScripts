--ノーバディ・スキャットシーフ
--Nobody Scat Thief
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Draw 3 cards
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_EFFECT) or (c:IsReason(REASON_BATTLE) and Duel.GetAttacker():IsControler(1-tp)))
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	 if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
	Duel.ShuffleHand(p)
	Duel.BreakEffect()
	local ct=Duel.GetFieldGroupCountRush(tp,LOCATION_HAND,0)
	Duel.DiscardHand(p,nil,1,ct,REASON_EFFECT)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0 then
		-- Take no battle damage this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.damop)
		e1:SetReset(RESET_PHASE+PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local at=Duel.GetAttacker()
	if at:IsControler(1-tp) and at:IsLevelBelow(8) then Duel.ChangeBattleDamage(tp,0) end
end