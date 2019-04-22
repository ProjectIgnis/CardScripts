--手札断殺
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if e:GetHandler():IsLocation(LOCATION_HAND) then h1=h1-1 end
		local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
		local a=false
		local b=false
		if h1==0 then
			a=Duel.IsPlayerCanDraw(tp,1)
		elseif h1<4 then
			a=Duel.IsPlayerCanDraw(tp,h1)
		else
			a=Duel.IsPlayerCanDraw(tp,4)
		end
		if h2==0 then
			b=Duel.IsPlayerCanDraw(1-tp,1)
		elseif h2<4 then
			b=Duel.IsPlayerCanDraw(1-tp,h2)
		else
			b=Duel.IsPlayerCanDraw(1-tp,4)
		end
		return a and b
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandlerPlayer()==Duel.GetTurnPlayer() then
		turnp=Duel.GetTurnPlayer()
	else
		turnp=1-tp
	end
	local h1=Duel.GetFieldGroupCount(turnp,LOCATION_HAND,0)
	local h2=Duel.GetFieldGroupCount(turnp,0,LOCATION_HAND)
	local g1
	if h1==0 then
		h1=1
		g1=Group.CreateGroup()
	elseif h1<4 then
		g1=Duel.GetFieldGroup(turnp,LOCATION_HAND,0)
	else
		h1=4
		Duel.Hint(HINT_SELECTMSG,turnp,HINTMSG_TOGRAVE)
		g1=Duel.SelectMatchingCard(turnp,aux.TRUE,turnp,LOCATION_HAND,0,4,4,nil)
	end
	Duel.ConfirmCards(1-turnp,g1)
	local g2
	if h2==0 then
		h2=1
		g2=Group.CreateGroup()
	elseif h2<4 then
		g2=Duel.GetFieldGroup(1-turnp,LOCATION_HAND,0)
	else
		h2=4
		Duel.Hint(HINT_SELECTMSG,1-turnp,HINTMSG_TOGRAVE)
		g2=Duel.SelectMatchingCard(1-turnp,aux.TRUE,1-turnp,LOCATION_HAND,0,4,4,nil)
	end
	Duel.ConfirmCards(turnp,g2)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Draw(turnp,h1,REASON_EFFECT)
	Duel.Draw(1-turnp,h2,REASON_EFFECT)
end
