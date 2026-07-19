--剣鬼の神域
--Asutra Divine Domain
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects;
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_ASUTRA}
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	--● Special Summon this card as a Normal Monster (Aqua/Tuner/WATER/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:IsHasType(EFFECT_TYPE_ACTIVATE)
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ASUTRA,TYPE_MONSTER|TYPE_NORMAL|TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER)
	--● When your opponent activates a Spell/Trap Card or effect and they control no face-down cards: Negate that effect
	local b2_event,_,event_p,event_v,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local b2=b2_event and event_p==1-tp and event_reff:IsSpellTrapEffect() and Chain.IsDisablable(event_v)
		and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local cd=e:GetChainData()
	cd.choice=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if cd.choice==1 then
		--● Special Summon this card as a Normal Monster (Aqua/Tuner/WATER/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,tp,0)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif cd.choice==2 then
		--● When your opponent activates a Spell/Trap Card or effect and they control no face-down cards: Negate that effect
		cd.negate_chain_link=event_v
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,event_reff:GetHandler(),1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local cd=e:GetChainData()
	if cd.choice==1 then
		--● Special Summon this card as a Normal Monster (Aqua/Tuner/WATER/Level 1/ATK 0/DEF 0) (this card is NOT treated as a Trap), then immediately after this effect resolves, you can Synchro Summon 1 Synchro Monster
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,id,SET_ASUTRA,TYPE_MONSTER|TYPE_NORMAL|TYPE_TUNER,0,0,1,RACE_AQUA,ATTRIBUTE_WATER) then
			c:AddMonsterAttribute(TYPE_NORMAL|TYPE_TUNER)
			Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
			c:AddMonsterAttributeComplete()
		end
		if Duel.SpecialSummonComplete()==0 then return end
		local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local sg=g:Select(tp,1,1,nil)
			Duel.SynchroSummon(tp,sg:GetFirst())
		end
	elseif cd.choice==2 then
		--● When your opponent activates a Spell/Trap Card or effect and they control no face-down cards: Negate that effect
		Duel.NegateEffect(cd.negate_chain_link)
	end
end