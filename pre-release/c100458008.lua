--光帰の旅－『セネト』
--A Journey Back to the Light - "Zenet"
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Show 2 or 3 Normal Monster Cards in your hand, Deck, face-up field, and/or GY, then apply the appropriate effect based on the number shown, then if you showed a card(s) in the hand, you can draw 1 card
	--● 2: Special Summon 1 Level 8 or lower non-Effect Fusion Monster from your Extra Deck as a Normal Monster Card
	--● 3: Special Summon 1 "Zenet" monster from your Deck or 1 Normal Monster from your GY
	--You can only activate 1 "A Journey Back to the Light - "Zenet"" per turn
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Prevent the non-Effect Fusion Monster Special Summoned as a Normal Monster Card from being returned to the hand or Main Deck as cost
	aux.GlobalCheck(s,function()
		Card.IsAbleToHandAsCost=(function()
			local oldfunc=Card.IsAbleToHandAsCost
			return function(c,...)
				if c:HasFlagEffect(id) then
					return false
				end
				return oldfunc(c,...)
			end
		end)()
		Card.IsAbleToDeckAsCost=(function()
			local oldfunc=Card.IsAbleToDeckAsCost
			return function(c,...)
				if c:HasFlagEffect(id) then
					return false
				end
				return oldfunc(c,...)
			end
		end)()
	end)
end
s.listed_series={SET_ZENET}
local LOCATIONS_HAND_DECK_ONFIELD_GRAVE=LOCATION_HAND|LOCATION_DECK|LOCATION_ONFIELD|LOCATION_GRAVE
function s.showfilter(c)
	return c:IsOriginalType(TYPE_NORMAL) and (c:IsFaceup() or not c:IsOnField())
end
function s.exspfilter(c,e,tp)
	return c:IsLevelBelow(8) and c:IsNonEffectMonster() and c:IsFusionMonster() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.deckgyspfilter(c,e,tp)
	return ((c:IsSetCard(SET_ZENET) and c:IsLocation(LOCATION_DECK)) or (c:IsType(TYPE_NORMAL) and c:IsLocation(LOCATION_GRAVE)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local show_count=Duel.GetMatchingGroupCount(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,nil)
		local option_1=show_count>=2 and Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
		local option_2=show_count>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.deckgyspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
		return option_1 or option_2
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.rescon(option_1,option_2)
	return function(sg,e,tp,mg)
		return (#sg==2 and option_1) or (#sg==3 and option_2)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local show_group=Duel.GetMatchingGroup(s.showfilter,tp,LOCATIONS_HAND_DECK_ONFIELD_GRAVE,0,nil)
	if #show_group==0 then return end
	local option_1=#show_group>=2 and Duel.IsExistingMatchingCard(s.exspfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp)
	local option_2=#show_group>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.deckgyspfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
	if not (option_1 or option_2) then return end
	local rescon=s.rescon(option_1,option_2)
	local sg=aux.SelectUnselectGroup(show_group,e,tp,2,3,rescon,1,tp,HINTMSG_CONFIRM,rescon)
	if #sg==0 then return end
	local hdg,fgg=sg:Split(Card.IsLocation,nil,LOCATION_HAND|LOCATION_DECK)
	if #fgg>0 then Duel.HintSelection(fgg) end
	if #hdg>0 then Duel.ConfirmCards(1-tp,hdg) end
	if hdg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND) then Duel.ShuffleHand(tp) end
	if hdg:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local deck_shuffle_chk=false
	local summon_success_chk=false
	local hand_reveal_chk=sg:IsExists(Card.IsLocation,1,nil,LOCATION_HAND)
	if #sg==2 then
		--● 2: Special Summon 1 Level 8 or lower non-Effect Fusion Monster from your Extra Deck as a Normal Monster Card
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.exspfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP) then
			local c=e:GetHandler()
			local original_type=sc:GetType()
			sc:Type((original_type&~TYPE_FUSION)|TYPE_NORMAL)
			sc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,original_type,aux.Stringid(id,1))
			--Reset its type back to the original when it stops being face-up in the Monster Zone
			local e0a=Effect.CreateEffect(c)
			e0a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e0a:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0a:SetCode(EVENT_ADJUST)
			e0a:SetCondition(function()
				return not sc:HasFlagEffect(id)
			end)
			e0a:SetOperation(function()
				sc:Type(original_type)
				e0a:Reset()
			end)
			Duel.RegisterEffect(e0a,tp)
			local e0b=Effect.CreateEffect(c)
			e0b:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e0b:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e0b:SetCode(EFFECT_SEND_REPLACE)
			e0b:SetTarget(function(e,tp,eg,ep,ev,re,r,rp,chk)
				local g=eg:Filter(Card.HasFlagEffect,nil,id)
				if chk==0 then return #g>0 end
				for tc in g:Iter() do
					tc:Type(tc:GetFlagEffectLabel(id))
				end
				e0b:Reset()
				return true
			end)
			e0b:SetValue(aux.FALSE)
			Duel.RegisterEffect(e0b,tp)
		end
		summon_success_chk=Duel.SpecialSummonComplete()>0
	elseif #sg==3 then
		--● 3: Special Summon 1 "Zenet" monster from your Deck or 1 Normal Monster from your GY
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.deckgyspfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if not sc then return end
		deck_shuffle_chk=sc:IsLocation(LOCATION_DECK)
		summon_success_chk=Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)>0
	end
	if deck_shuffle_chk then Duel.ShuffleDeck(tp) end
	if hand_reveal_chk and summon_success_chk and Duel.IsPlayerCanDraw(tp,1)
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.BreakEffect()
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end