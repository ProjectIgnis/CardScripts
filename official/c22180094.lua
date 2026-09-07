--Ｓ－Ｆｏｒｃｅ 乱破小夜丸
--S-Force Rappa Chiyomaru
--Scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Each of your opponent's monsters in the same column as one of your "S-Force" monsters can only target monsters in that column for attacks
	local e1a=Effect.CreateEffect(c)
	e1a:SetType(EFFECT_TYPE_FIELD)
	e1a:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1a:SetRange(LOCATION_MZONE)
	e1a:SetTargetRange(0,LOCATION_MZONE)
	e1a:SetTarget(function(e,c)
			if SForce.ColumnTarget(e,c) then
				e:SetLabelObject(c)
				return true
			end
		end)
	e1a:SetValue(function(e,c)
			local bc=e:GetLabelObject()
			return bc and not bc:GetColumnGroup():IsContains(c)
		end)
	c:RegisterEffect(e1a)
	local e1b=e1a:Clone()
	e1b:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1b)
	--(Quick Effect): You can banish 1 "S-Force" card from your hand; return this card to the hand, and if you do, Special Summon 1 "S-Force" monster from your Deck in Defense Position, except "S-Force Rappa Chiyomaru". You can only use this effect of "S-Force Rappa Chiyomaru" once per turn
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(Cost.Replaceable(s.spcost,s.extracon))
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e2)
end
s.listed_series={SET_S_FORCE}
s.listed_names={id}
function s.spcostfilter(c)
	return c:IsSetCard(SET_S_FORCE) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_S_FORCE) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.extracon(base,e,tp,eg,ep,ev,re,r,rp,exc)
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,exc,e,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() and Duel.GetMZoneCount(tp,c)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end