--リンクアップル
--Link Apple
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--reveal
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	Duel.ConfirmCards(1-tp,e:GetHandler())
	Duel.ShuffleHand(tp)
end
function s.cfilter(c)
	return c:IsFacedown() and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	if #g==0 then return end
	local rc=g:RandomSelect(tp,1):GetFirst()
	if Duel.Remove(rc,POS_FACEUP,REASON_EFFECT)~=1 or not rc:IsLocation(LOCATION_REMOVED) or not c:IsRelateToEffect(e) then return end
	if rc:GetType()&TYPE_MONSTER+TYPE_LINK==TYPE_MONSTER+TYPE_LINK then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		if Duel.SendtoGrave(c,REASON_EFFECT+REASON_DISCARD)==1 then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
