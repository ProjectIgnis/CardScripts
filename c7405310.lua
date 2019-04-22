--エクストラゲート
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)~=0
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_EXTRA,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINGMSG_LVRANK)
	local lv=Duel.AnnounceLevel(tp)
	Duel.SetTargetParam(lv)
end
function s.filter(c,lv)
	return c:GetLevel()==lv
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local lv=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_EXTRA,0,nil,lv)
	if #g~=0 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)
		local rg=g:FilterSelect(1-tp,Card.IsAbleToRemove,1,1,nil)
		if #rg~=0 then
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
		else
			local cg=Duel.GetFieldGroup(1-tp,LOCATION_EXTRA,0)
			Duel.ConfirmCards(tp,cg)
		end
	else
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
