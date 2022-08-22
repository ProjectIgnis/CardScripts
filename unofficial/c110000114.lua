--フルアーマー・グラビテーション
--Full Armor Gravitation
--reworked effect by senpaizuri
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetDecktopGroup(tp,10)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(tp)
		and g:FilterCount(Card.IsAbleToRemove,nil)==10 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,tp,LOCATION_DECK)
end
function s.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsType(TYPE_ARMOR)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetDecktopGroup(tp,10)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	if g:FilterCount(Card.IsAbleToRemove,nil)~=10 then return end
	Duel.DisableShuffleCheck()
	Duel.ConfirmDecktop(tp,10)
	local tg={}
	for tc in aux.Next(g) do
		if s.filter(tc,e,tp) then table.insert(tg,tc) end
	end
	table.sort(tg,function(a,b) return a:GetSequence()>b:GetSequence() end)
	local sg=Group.CreateGroup()
	for _,tc in pairs(tg) do
		if #sg==ft then break end
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			sg:AddCard(tc)
			g:RemoveCard(tc)
		end
	end
	Duel.SpecialSummonComplete()
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
