--クリアー・ワールド
--Clear World
local s,id=GetID()
function s.initial_effect(c)
	local fid=c:GetFieldID()
	local copying=c:IsStatus(STATUS_COPYING_EFFECT)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Maintenance cost: Pay 500 LP or destroy this card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_FZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) end)
	e1:SetOperation(s.maintop)
	c:RegisterEffect(e1)
	--● LIGHT: Play with your hand revealed at all times
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_PUBLIC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetTarget(function(e,c) return s.PlayerIsAffectedByClearWorld(c:GetControler(),ATTRIBUTE_LIGHT) end)
	c:RegisterEffect(e2)
	--● DARK: If you control 2 or more monsters, you cannot declare an attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.darkconyou)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCondition(s.darkconopp)
	e4:SetTargetRange(0,1)
	c:RegisterEffect(e4)
	--● EARTH: Destroy 1 face-up Defense Position monster you control
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_EARTH) and c:IsHasEffect(id) and not c:HasFlagEffect(id) and (not copying or c:IsFieldID(fid)) end)
	e5:SetOperation(s.desop)
	if copying then
		e5:SetReset(RESET_PHASE|PHASE_END)
	end
	Duel.RegisterEffect(e5,0)
	local e5b=e5:Clone()
	Duel.RegisterEffect(e5b,1)
	--● WATER: Discard 1 card
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,2))
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_PHASE+PHASE_END)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCountLimit(1)
	e6:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_WATER) and c:IsHasEffect(id) and not c:HasFlagEffect(id+1) and (not copying or c:IsFieldID(fid)) end)
	e6:SetOperation(s.discardop)
	if copying then
		e6:SetReset(RESET_PHASE|PHASE_END)
	end
	Duel.RegisterEffect(e6,0)
	local e6b=e6:Clone()
	Duel.RegisterEffect(e6b,1)
	--● FIRE: Take 1000 damage
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(id,3))
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e7:SetCode(EVENT_PHASE+PHASE_END)
	e7:SetRange(LOCATION_FZONE)
	e7:SetCondition(function(e,tp) return Duel.IsTurnPlayer(tp) and s.PlayerControlsAttributeOrIsAffectedByClearWall(tp,ATTRIBUTE_FIRE) and c:IsHasEffect(id) and not c:HasFlagEffect(id+2) and (not copying or c:IsFieldID(fid)) end)
	e7:SetOperation(s.damop)
	if copying then
		e7:SetReset(RESET_PHASE|PHASE_END)
	end
	Duel.RegisterEffect(e7,0)
	local e7b=e7:Clone()
	Duel.RegisterEffect(e7b,1)
	--● WIND: You must pay 500 Life Points to activate a Spell Card
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetCode(EFFECT_ACTIVATE_COST)
	e8:SetRange(LOCATION_FZONE)
	e8:SetTargetRange(1,0)
	e8:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(e:GetHandlerPlayer(),ATTRIBUTE_WIND) end)
	e8:SetTarget(function(e,te,tp) return te:IsSpellEffect() and te:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e8:SetCost(function(e,te_or_c,tp) return Duel.CheckLPCost(tp,500) end)
	e8:SetOperation(function(e,tp) Duel.PayLPCost(tp,500) end)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetTargetRange(0,1)
	e9:SetCondition(function(e) return s.PlayerIsAffectedByClearWorld(1-e:GetHandlerPlayer(),ATTRIBUTE_WIND) end)
	c:RegisterEffect(e9)
	--Apply a dummy effect on itself to track whether the card's effects are currently active or not
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_SINGLE)
	e10:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e10:SetCode(id)
	e10:SetRange(LOCATION_FZONE)
	c:RegisterEffect(e10)
end
function s.maintop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	local b1=Duel.CheckLPCost(tp,500)
	local b2=true
	--Pay 500 LP or destroy this card
	local op=b1 and Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,4)},
		{b2,aux.Stringid(id,5)}) or 2
	if op==1 then
		Duel.PayLPCost(tp,500)
	elseif op==2 then
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end
function s.PlayerControlsAttributeOrIsAffectedByClearWall(player,attribute)
	return Duel.IsPlayerAffectedByEffect(1-player,EFFECT_CLEAR_WALL)
		or Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAttribute,attribute),player,LOCATION_MZONE,0,1,nil)
end
function s.PlayerIsAffectedByClearWorld(player,attribute)
	return not Duel.IsPlayerAffectedByEffect(player,EFFECT_CLEAR_WORLD_IMMUNE)
		and s.PlayerControlsAttributeOrIsAffectedByClearWall(player,attribute)
end
function s.darkconyou(e)
	local affected_player=e:GetHandlerPlayer()
	return s.PlayerIsAffectedByClearWorld(affected_player,ATTRIBUTE_DARK) and Duel.GetFieldGroupCount(affected_player,LOCATION_MZONE,0)>=2
end
function s.darkconopp(e)
	local affected_player=1-e:GetHandlerPlayer()
	return s.PlayerIsAffectedByClearWorld(affected_player,ATTRIBUTE_DARK) and Duel.GetFieldGroupCount(affected_player,LOCATION_MZONE,0)>=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESETS_STANDARD_PHASE_END,0,1)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_EARTH)
		or not Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,0,1,nil,POS_FACEUP_DEFENSE) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsPosition,tp,LOCATION_MZONE,0,1,1,nil,POS_FACEUP_DEFENSE)
	if #g==0 then return end
	Duel.HintSelection(g)
	Duel.Destroy(g,REASON_EFFECT)
end
function s.discardop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+1,RESETS_STANDARD_PHASE_END,0,1)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_WATER)
		or Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT|REASON_DISCARD)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id+2,RESETS_STANDARD_PHASE_END,0,1)
	if not s.PlayerIsAffectedByClearWorld(tp,ATTRIBUTE_FIRE) then return end
	Duel.Hint(HINT_CARD,0,id)
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	Duel.Damage(tp,1000,REASON_EFFECT)
end