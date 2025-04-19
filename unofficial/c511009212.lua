--Spell Search
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Your opponent adds 1 Spell from their Deck to their Hand instead of drawing
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local ge=Effect.CreateEffect(c)
	ge:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	ge:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	ge:SetCode(EVENT_PREDRAW)
	ge:SetCondition(s.condition2)
	ge:SetOperation(s.activate2)
	Duel.RegisterEffect(ge,0)
end
function s.condition2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetControler()
	if not c:IsLocation(LOCATION_HAND|LOCATION_SZONE) then return end
	return Duel.IsTurnPlayer(1-tp) and Duel.GetDrawCount(1-tp)>0
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tp=c:GetControler()
	local eff=c:GetActivateEffect()
	eff:SetLabel(1)
	local act=eff:IsActivatable(tp,false,false)
	eff:SetLabel(0)
	if act and Duel.SelectEffectYesNo(tp,c,95) then
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_DRAW,0,1)
		Duel.Activate(c:GetActivateEffect())
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabel()==1 or Duel.GetFlagEffect(tp,id)>0
end
function s.afilter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetDrawCount(1-tp)>0 and Duel.IsExistingMatchingCard(s.afilter,1-tp,LOCATION_DECK,0,1,nil) end
	local dt=Duel.GetDrawCount(1-tp)
	if dt~=0 then
		e:SetLabel(2)
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
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()~=2 then
		return
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(1-tp,s.afilter,1-tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(tp,g)
	end
end