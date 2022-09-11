--ペンデュラム・スケール
--Pendulum Scale
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldCard(tp,LOCATION_PZONE,0) and Duel.GetFieldCard(tp,LOCATION_PZONE,1)
end
function s.thfilter(c,hl)
	if not (c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()) then return false end
	if hl then
		return c:IsLevelAbove(5) and c:IsLevelBelow(7)
	else
		return c:IsLevelAbove(2) and c:IsLevelBelow(4)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if chk==0 then
		if not lc or not rc then return false end
		local diff=math.abs(lc:GetScale()-rc:GetScale())
		if diff==0 then
			return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler())
		elseif diff<=3 then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,false)
		elseif diff<=6 then
			return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,true)
		elseif diff>=7 then
			return lc:IsAbleToHand() or rc:IsAbleToHand()
		end
	end
	local diff=math.abs(lc:GetScale()-rc:GetScale())
	if diff==0 then
		local g=Duel.GetMatchingGroup(Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler())
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,PLAYER_ALL,LOCATION_ONFIELD)
	elseif diff<=6 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif diff>=7 then
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_PZONE)
	end
end
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_PENDULUM) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lc=Duel.GetFieldCard(tp,LOCATION_PZONE,0)
	local rc=Duel.GetFieldCard(tp,LOCATION_PZONE,1)
	if not lc or not rc then return end
	local diff=math.abs(lc:GetScale()-rc:GetScale())
	if diff==0 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,1))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,Card.IsSpellTrap,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
		if #g>0 then
			Duel.HintSelection(g,true)
			Duel.Destroy(g,REASON_EFFECT)
		end
	elseif diff<=6 then
		local diffchk=diff>=4
		local str=diffchk and 3 or 2
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,str))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,str))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,diffchk)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif diff>=7 then
		Duel.Hint(HINT_OPSELECTED,tp,aux.Stringid(id,4))
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,4))
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
		local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_PZONE,0,1,2,nil)
		if #hg>0 and Duel.SendtoHand(hg,nil,REASON_EFFECT)>0 and hg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
			and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
			if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:Select(tp,1,1,nil)
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end