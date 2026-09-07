--魔封印の宝札
--Card of Spell Containment
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	--Register when a player Sets a card
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MSET)
		ge1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp) Duel.RegisterFlagEffect(rp,id+1,RESET_PHASE|PHASE_END,0,1) end)
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SSET)
		Duel.RegisterEffect(ge2,0)
		local ge3=ge1:Clone()
		ge3:SetCode(EVENT_CHANGE_POS)
		ge3:SetOperation(s.checkposop)
		Duel.RegisterEffect(ge3,0)
		local ge4=ge1:Clone()
		ge4:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge4:SetOperation(s.checksumop)
		Duel.RegisterEffect(ge4,0)
	end)
end
function s.chainfilter(re,tp,cid)
	return not (re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL))
end
function s.checkposfilter(c)
	return c:IsPreviousPosition(POS_FACEUP) and c:IsFacedown()
end
function s.checkposop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkposfilter,1,nil) then
		Duel.RegisterFlagEffect(rp,id+1,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.checksumop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(Card.IsFacedown,1,nil) then
		Duel.RegisterFlagEffect(rp,id+1,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)==0 and Duel.GetFlagEffect(tp,id+1)==0 end
	local c=e:GetHandler()
	--Cannot activate Spell Cards the turn you activate this card
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(function(e,re,tp) return re:GetHandler():IsSpell() and re:IsHasType(EFFECT_TYPE_ACTIVATE) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Cannot Set cards the turn you activate this card
	local e2a=Effect.CreateEffect(c)
	e2a:SetType(EFFECT_TYPE_FIELD)
	e2a:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e2a:SetCode(EFFECT_CANNOT_MSET)
	e2a:SetTargetRange(1,0)
	e2a:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2a,tp)
	local e2b=e2a:Clone()
	e2b:SetCode(EFFECT_CANNOT_SSET)
	Duel.RegisterEffect(e2b,tp)
	local e2c=e2a:Clone()
	e2c:SetCode(EFFECT_CANNOT_TURN_SET)
	Duel.RegisterEffect(e2c,tp)
	local e2d=e2a:Clone()
	e2d:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2d:SetTarget(function(_,_,_,_,sumpos) return (sumpos&POS_FACEDOWN)>0 end)
	Duel.RegisterEffect(e2d,tp)
	--Player hint
	aux.RegisterClientHint(c,nil,tp,1,0,aux.Stringid(id,0),nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
