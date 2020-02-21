--ショー・マスト・ゴー・オン
--The Show Must Go On
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_ACTION) and not c:IsType(TYPE_FIELD)
		and (c:IsAbleToHand() and c:IsLocation(LOCATION_HAND)
		or c:IsControlerCanBeChanged() and c:IsLocation(LOCATION_ONFIELD))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_ONFIELD+LOCATION_HAND,2,nil) end
	local g=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_ONFIELD+LOCATION_HAND,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_ONFIELD) then
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	end
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_ONFIELD+LOCATION_HAND,2,2,nil)
	if #g==2 then
		local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
		local fg=g-hg
		if hg:GetFirst() then
			Duel.SendtoHand(hg,tp,REASON_EFFECT)
		end
		if fg:GetFirst() then
			Duel.GetControl(fg,tp)
		end
	end
end
