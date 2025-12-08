--闇のデッキ破壊ウイルス
--Eradicator Epidemic Virus
local s,id=GetID()
function s.initial_effect(c)
	--Look at your opponent's hand, all Spells/Traps they control, and all cards they draw until the 3rd end of their turn, and destroy all cards of that declared type
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_TOHAND|TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:GetAttack()>=2500
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.costfilter,1,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,s.costfilter,1,1,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local decl_type=2<<Duel.SelectOption(tp,DECLTYPE_SPELL,DECLTYPE_TRAP)
	e:SetLabel(decl_type)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsType,decl_type),tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.cffilter(c)
	return c:IsLocation(LOCATION_HAND) or (c:IsFacedown() and c:IsSpellTrap())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local decl_type=e:GetLabel()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD|LOCATION_HAND)
	if #g>0 then
		local cg=g:Filter(s.cffilter,nil)
		Duel.ConfirmCards(tp,cg)
		local dg=g:Filter(Card.IsType,nil,decl_type)
		Duel.Destroy(dg,REASON_EFFECT)
		Duel.ShuffleHand(1-tp)
	end
	--Look at all cards your opponent draws until the 3rd end of their turn, and destroy all cards of that declared type
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DRAW)
	e1:SetOperation(s.desop)
	e1:SetLabel(decl_type)
	e1:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	Duel.RegisterEffect(e1,tp)
	--To work with "Pyro Clock of Destiny"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.turncon)
	e2:SetOperation(s.turnop)
	e2:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	Duel.RegisterEffect(e2,tp)
	e2:SetLabelObject(e1)
	local descnum=tp==c:GetOwner() and 0 or 1
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetDescription(aux.Stringid(id,descnum))
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e3:SetCode(1082946)
	e3:SetLabelObject(e2)
	e3:SetOwnerPlayer(tp)
	e3:SetOperation(s.reset)
	e3:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e4:SetDescription(aux.Stringid(id,3))
	e4:SetReset(RESET_PHASE|PHASE_END|RESET_OPPO_TURN,3)
	e4:SetTargetRange(0,1)
	Duel.RegisterEffect(e4,tp)
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	s.turnop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if ep==e:GetOwnerPlayer() then return end
	local hg=eg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg==0 then return end
	Duel.ConfirmCards(1-ep,hg)
	local dg=hg:Filter(Card.IsType,nil,e:GetLabel())
	Duel.Destroy(dg,REASON_EFFECT)
	Duel.ShuffleHand(ep)
end
function s.turncon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(1-tp)
end
function s.turnop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		e:GetLabelObject():Reset()
		if re then re:Reset() end
	end
end