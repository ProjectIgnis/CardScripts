--ジャンク・シグナル
--Junk Signal
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_JUNK_WARRIOR,CARD_STARDUST_DRAGON}
function s.spcostfilter(c,e,tp)
	return Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,nil,e,tp)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_JUNK_WARRIOR,CARD_STARDUST_DRAGON) or c:ListsCode(CARD_JUNK_WARRIOR,CARD_STARDUST_DRAGON))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.CheckReleaseGroupCost(tp,s.spcostfilter,1,false,nil,nil,e,tp)
	local ex,_,event_player,event_value,event_reff=Duel.CheckEvent(EVENT_CHAINING,true)
	local trig_player,trig_type=nil
	if ex then
		trig_player,trig_type=Duel.GetChainInfo(event_value-1,CHAININFO_TRIGGERING_PLAYER,CHAININFO_TRIGGERING_TYPE)
	end
	local b2=ex and event_player==1-tp and Duel.IsChainDisablable(event_value) and trig_player==tp and trig_type&TYPE_SYNCHRO>0
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		local sc=Duel.SelectReleaseGroupCost(tp,s.spcostfilter,1,1,false,nil,nil,e,tp):GetFirst()
		Duel.Release(sc,REASON_COST)
		e:SetLabelObject(sc)
		sc:CreateEffectRelation(e)
	elseif op==2 then
		e:SetLabel(op,event_value)
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local op=e:GetLabel()
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_DISABLE)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op,event_value=e:GetLabel()
	if op==1 then
		--Tribute 1 monster; Special Summon 1 "Junk Warrior", 1 "Stardust Dragon", or 1 monster that mentions either of them from your hand, Deck, or GY, except the Tributed monster
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		local sc=e:GetLabelObject()
		local exc=sc:IsRelateToEffect(e) and sc or nil
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND|LOCATION_DECK|LOCATION_GRAVE,0,1,1,exc,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--When your opponent activates a card or effect in response to the activation of your Synchro Monster's effect: Negate that opponent's effect
		Duel.NegateEffect(event_value)
	end
	local c=e:GetHandler()
	--You cannot Special Summon from the Extra Deck for the rest of this turn, except Synchro Monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,3))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(function(e,c) return c:IsLocation(LOCATION_EXTRA) and not c:IsSynchroMonster() end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--"Clock Lizard" check
	aux.addTempLizardCheck(c,tp,function(e,c) return not c:IsOriginalType(TYPE_SYNCHRO) end)
end