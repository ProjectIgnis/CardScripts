--死なばもろとも
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
		return h1>2 and h2>2 and Duel.IsPlayerCanDraw(tp,5) and Duel.IsPlayerCanDraw(1-tp,5)
	end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,5)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local h1=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	local h2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)
	if h1<3 or h2<3 then return end
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,LOCATION_HAND)
	local ct=Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	Duel.Damage(tp,ct*100,REASON_EFFECT)
	Duel.BreakEffect()
	Duel.Draw(tp,5,REASON_EFFECT)
	Duel.Draw(1-tp,5,REASON_EFFECT)
end
