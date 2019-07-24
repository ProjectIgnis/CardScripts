--Spell Search
--remade by MLD with tips from Shad3
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(aux.FALSE)
	e1:SetTarget(s.faketg)
	e1:SetOperation(s.fakeop)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PREDRAW)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ADJUST)
		ge1:SetOperation(s.checkop)
		ge1:SetCountLimit(1)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.faketg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetTurnPlayer()~=tp and Duel.GetDrawCount(1-tp)>0 end
	local dt=Duel.GetDrawCount(1-tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.fakeop(e,tp,eg,ep,ev,re,r,rp)
	_replace_count=_replace_count+1
	if _replace_count<=_replace_max then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(1-tp,s.afilter,1-tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,g)
		else
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
			Duel.ConfirmCards(tp,dg)
			Duel.ShuffleDeck(1-tp)
		end
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsOriginalCode,tp,LOCATION_SZONE,LOCATION_SZONE,nil,id)
	local p=Duel.GetTurnPlayer()
	--local g2=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local te=tc:GetActivateEffect()
		te:SetCondition(aux.TRUE)
		if te:IsActivatable(p) and Duel.SelectEffectYesNo(p,tc) then
			Duel.ChangePosition(tc,POS_FACEUP)
			--g2:AddCard(tc)
		elseif te:IsActivatable(1-p) and Duel.SelectEffectYesNo(1-p,tc) then
			Duel.ChangePosition(tc,POS_FACEUP)
			--g2:AddCard(tc)
		end
		te:SetCondition(aux.FALSE)
		tc=g:GetNext()
	end
	--[[if #g2>0 then
		Duel.RaiseEvent(g2,EVENT_PREDRAW,e,REASON_EFFECT,Duel.GetTurnPlayer(),Duel.GetTurnPlayer(),0)
	end]]
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetDrawCount(1-tp)>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	e:SetType(EFFECT_TYPE_ACTIVATE)
	local dt=Duel.GetDrawCount(1-tp)
	if dt~=0 then
		_replace_count=0
		_replace_max=dt
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_DRAW_COUNT)
		e1:SetTargetRange(0,1)
		e1:SetReset(RESET_PHASE+PHASE_DRAW)
		e1:SetValue(0)
		Duel.RegisterEffect(e1,tp)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetLabelObject(e)
	e2:SetOperation(s.resetop)
	e2:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e2,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,1-tp,LOCATION_DECK)
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
end
function s.afilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	_replace_count=_replace_count+1
	if _replace_count<=_replace_max then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(1-tp,s.afilter,1-tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(tp,g)
		else
			local dg=Duel.GetFieldGroup(tp,0,LOCATION_DECK)
			Duel.ConfirmCards(tp,dg)
			Duel.ShuffleDeck(1-tp)
		end
	end
end
