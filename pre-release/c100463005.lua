--時空鎖
--Time Chain
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate this card when your monster is targeted for an attack: Neither battling monster can be destroyed by that battle, also banish them after damage calculation until their controller's 2nd Standby Phase
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.GetAttackTarget():IsControler(tp)
	end)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Negate the activated effects of monsters with the same original name as monsters that are currently banished by this card's effect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
	--During your Draw Phase, instead of conducting your normal draw: You can add 1 monster from your Deck to your hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	--Destroy this card during your opponent's 2nd Standby Phase after activation
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp,eg,ep,ev,re,r,rp)
		return Duel.IsTurnPlayer(1-tp)
	end)
	e1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local turn_counter=c:GetTurnCounter()+1
		c:SetTurnCounter(turn_counter)
		if turn_counter==2 then
			Duel.Destroy(c,REASON_EFFECT)
		end
	end)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_OPPO_TURN,2)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc1,bc2=Duel.GetAttacker(),Duel.GetAttackTarget()
	if chk==0 then return bc1:IsAbleToRemove() and bc2:IsAbleToRemove() end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,Group.FromCards(bc1,bc2),2,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local bc1,bc2=Duel.GetAttacker(),Duel.GetAttackTarget()
	if not (bc1 and bc2 and bc1:IsRelateToBattle() and bc2:IsRelateToBattle()) then return end
	local c=e:GetHandler()
	--Neither battling monster can be destroyed by that battle
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
	bc1:RegisterEffect(e1)
	local e2=e1:Clone()
	bc2:RegisterEffect(e2)
	--Banish them after damage calculation until their controller's 2nd Standby Phase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
		local c=e:GetHandler()
		local bc1_ctrl=bc1:GetControler()
		local bc2_ctrl=bc2:GetControler()
		local bc1_turn_count=Duel.GetTurnCount(bc1_ctrl)
		local bc2_turn_count=Duel.GetTurnCount(bc2_ctrl)
		local reset_phase=RESET_PHASE|PHASE_STANDBY
		local bc1_extra_reset=bc1_ctrl==tp and RESET_SELF_TURN or RESET_OPPO_TURN
		local bc2_extra_reset=bc2_ctrl==tp and RESET_SELF_TURN or RESET_OPPO_TURN
		--Banish them after damage calculation until their controller's 2nd Standby Phase
		aux.RemoveUntil(bc1,nil,REASON_EFFECT,PHASE_STANDBY,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.IsTurnPlayer(bc1_ctrl) and Duel.GetTurnCount(bc1_ctrl)==bc1_turn_count+2 end,reset_phase|bc1_extra_reset,2)
		aux.RemoveUntil(bc2,nil,REASON_EFFECT,PHASE_STANDBY,id,e,tp,aux.DefaultFieldReturnOp,function() return Duel.IsTurnPlayer(bc2_ctrl) and Duel.GetTurnCount(bc2_ctrl)==bc2_turn_count+2 end,reset_phase|bc2_extra_reset,2)
		bc1:CreateRelation(c,RESET_EVENT|RESETS_STANDARD)
		bc2:CreateRelation(c,RESET_EVENT|RESETS_STANDARD)
	end)
	e3:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e3,tp)
end
function s.disfilter(c,handler,code)
	return c:IsMonster() and c:IsFaceup() and c:HasFlagEffect(id) and c:IsRelateToCard(handler) and c:IsOriginalCodeRule(code)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsMonsterEffect() and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil,e:GetHandler(),re:GetHandler():GetOriginalCodeRule()) then
		Duel.NegateEffect(ev)
	end
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 and Duel.GetDrawCount(tp)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,LOCATION_DECK,0,1,nil) end
	local draw_count=Duel.GetDrawCount(tp)
	if draw_count~=0 then
		_replace_count=0
		_replace_max=draw_count
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(1,0)
		e1:SetValue(0)
		e1:SetReset(RESET_PHASE|PHASE_DRAW)
		Duel.RegisterEffect(e1,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	_replace_count=_replace_count+1
	if _replace_count>_replace_max then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.AND(Card.IsMonster,Card.IsAbleToHand),tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end